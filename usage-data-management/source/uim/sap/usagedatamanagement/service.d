module uim.sap.usagedatamanagement.service;

import std.algorithm : sort;
import std.array : array;
import std.datetime : Clock;
import std.string : toLower;

import uim.sap.usagedatamanagement;

mixin(ShowModule!());

@safe:

private struct MonthlyUsageAggregate {
  string entityType;
  string entityId;
  string metric;
  string unit;
  double quantity;
}

private struct DailyUsageAggregate {
  string day;
  string entityType;
  string entityId;
  string metric;
  string unit;
  double quantity;
}

private struct MonthlyCostAggregate {
  string subaccountId;
  string metric;
  string currency;
  double quantity;
  double unitPrice;
  double totalCost;
}

class UDMService : SAPService {
  mixin(SAPServiceTemplate!UDMService);

  private UDMStore _store;

  this(UDMConfig config) {
    super(config);
    _store = new UDMStore();
  }

  override Json health() {
    Json payload = super.health();
    payload["events_total"] = _store.countEvents();
    return payload;
  }

  Json discovery() {
    Json endpoints = Json.emptyArray;
    endpoints ~= endpoint("POST", "/v1/tenants/{tenantId}/usage-events", "Ingest a usage event");
    endpoints ~= endpoint("GET", "/v1/tenants/{tenantId}/usage-events", "List usage events for a tenant");
    endpoints ~= endpoint("POST", "/v1/tenants/{tenantId}/reports/monthly-usage", "Monthly aggregated usage per entity and metric");
    endpoints ~= endpoint("POST", "/v1/tenants/{tenantId}/reports/subaccount-usage", "Daily aggregated usage per entity and metric");
    endpoints ~= endpoint("POST", "/v1/tenants/{tenantId}/reports/monthly-subaccount-costs", "Monthly distributed costs per subaccount and billable metric");

    Json payload = Json.emptyObject;
    payload["service"] = "usage-data-management";
    payload["version"] = UIM_USAGE_DATA_MANAGEMENT_VERSION;
    payload["endpoints"] = endpoints;
    payload["total_results"] = cast(long)endpoints.length;
    return payload;
  }

  Json ingestUsageEvent(string tenantId, Json request) {
    validateTenant(tenantId);

    auto eventItem = UsageEvent.fromJson(tenantId, request);

    if (eventItem.metric.length == 0) {
      throw new UDMValidationException("metric is required");
    }
    if (eventItem.quantity <= 0.0) {
      throw new UDMValidationException("quantity must be greater than 0");
    }
    if (eventItem.accountId.length == 0) {
      throw new UDMValidationException("account_id is required");
    }
    if (eventItem.subaccountId.length == 0) {
      throw new UDMValidationException("subaccount_id is required");
    }

    auto saved = _store.appendEvent(eventItem);

    Json payload = Json.emptyObject;
    payload["success"] = true;
    payload["event"] = saved.toJson();
    return payload;
  }

  Json listUsageEvents(string tenantId) {
    validateTenant(tenantId);

    Json resources = Json.emptyArray;
    foreach (eventItem; _store.listEvents(tenantId)) {
      resources ~= eventItem.toJson();
    }

    Json payload = Json.emptyObject;
    payload["tenant_id"] = tenantId;
    payload["resources"] = resources;
    payload["total_results"] = cast(long)resources.length;
    return payload;
  }

  Json listTenants() {
    Json resources = Json.emptyArray;
    foreach (tenantId; _store.listTenants()) {
      Json row = Json.emptyObject;
      row["tenant_id"] = tenantId;
      row["events_total"] = _store.countEvents(tenantId);
      resources ~= row;
    }

    Json payload = Json.emptyObject;
    payload["resources"] = resources;
    payload["total_results"] = cast(long)resources.length;
    return payload;
  }

  Json monthlyUsageReport(string tenantId, Json request) {
    validateTenant(tenantId);

    auto month = request.getString("month", currentMonth());
    validateMonth(month);

    auto entityType = normalizeEntityType(request.getString("entity_type", "account"));
    auto metricFilter = normalizedMetricFilter(request);

    MonthlyUsageAggregate[string] aggregate;

    foreach (eventItem; _store.listEvents(tenantId)) {
      if (monthFromTimestamp(eventItem.occurredAt) != month) {
        continue;
      }
      if (!metricAllowed(eventItem.metric, metricFilter)) {
        continue;
      }

      auto entityId = entityValue(eventItem, entityType);
      auto key = entityId ~ "|" ~ toLower(eventItem.metric);

      if (auto existing = key in aggregate) {
        existing.quantity += eventItem.quantity;
      } else {
        MonthlyUsageAggregate row;
        row.entityType = entityType;
        row.entityId = entityId;
        row.metric = eventItem.metric;
        row.unit = eventItem.unit;
        row.quantity = eventItem.quantity;
        aggregate[key] = row;
      }
    }

    Json resources = Json.emptyArray;
    foreach (_, row; aggregate) {
      Json item = Json.emptyObject;
      item["entity_type"] = row.entityType;
      item["entity_id"] = row.entityId;
      item["metric"] = row.metric;
      item["unit"] = row.unit;
      item["total_quantity"] = row.quantity;
      resources ~= item;
    }

    Json payload = Json.emptyObject;
    payload["tenant_id"] = tenantId;
    payload["interval"] = "monthly";
    payload["month"] = month;
    payload["entity_type"] = entityType;
    payload["resources"] = resources;
    payload["total_results"] = cast(long)resources.length;
    return payload;
  }

  Json subaccountUsageReport(string tenantId, Json request) {
    validateTenant(tenantId);

    auto fromDate = request.getString("from_date", "");
    auto toDate = request.getString("to_date", "");
    if (fromDate.length == 0 || toDate.length == 0) {
      throw new UDMValidationException("from_date and to_date are required");
    }
    validateDate(fromDate);
    validateDate(toDate);

    auto entityType = normalizeEntityType(request.getString("entity_type", "subaccount"));
    auto metricFilter = normalizedMetricFilter(request);

    DailyUsageAggregate[string] aggregate;

    foreach (eventItem; _store.listEvents(tenantId)) {
      auto day = dayFromTimestamp(eventItem.occurredAt);
      if (!dateInRange(day, fromDate, toDate)) {
        continue;
      }
      if (!metricAllowed(eventItem.metric, metricFilter)) {
        continue;
      }

      auto entityId = entityValue(eventItem, entityType);
      auto key = day ~ "|" ~ entityId ~ "|" ~ toLower(eventItem.metric);

      if (auto existing = key in aggregate) {
        existing.quantity += eventItem.quantity;
      } else {
        DailyUsageAggregate row;
        row.day = day;
        row.entityType = entityType;
        row.entityId = entityId;
        row.metric = eventItem.metric;
        row.unit = eventItem.unit;
        row.quantity = eventItem.quantity;
        aggregate[key] = row;
      }
    }

    Json resources = Json.emptyArray;
    foreach (_, row; aggregate) {
      Json item = Json.emptyObject;
      item["day"] = row.day;
      item["entity_type"] = row.entityType;
      item["entity_id"] = row.entityId;
      item["metric"] = row.metric;
      item["unit"] = row.unit;
      item["total_quantity"] = row.quantity;
      resources ~= item;
    }

    Json payload = Json.emptyObject;
    payload["tenant_id"] = tenantId;
    payload["interval"] = "daily";
    payload["from_date"] = fromDate;
    payload["to_date"] = toDate;
    payload["entity_type"] = entityType;
    payload["resources"] = resources;
    payload["total_results"] = cast(long)resources.length;
    return payload;
  }

  Json monthlySubaccountCostsReport(string tenantId, Json request) {
    validateTenant(tenantId);

    auto month = request.getString("month", currentMonth());
    validateMonth(month);

    auto metricFilter = normalizedMetricFilter(request);
    auto requiredCurrency = request.getString("currency", "");

    MonthlyCostAggregate[string] aggregate;

    foreach (eventItem; _store.listEvents(tenantId)) {
      if (monthFromTimestamp(eventItem.occurredAt) != month) {
        continue;
      }
      if (!eventItem.billable) {
        continue;
      }
      if (!metricAllowed(eventItem.metric, metricFilter)) {
        continue;
      }
      if (requiredCurrency.length > 0 && eventItem.currency != requiredCurrency) {
        continue;
      }

      auto key = eventItem.subaccountId ~ "|" ~ toLower(eventItem.metric) ~ "|" ~ eventItem.currency;
      auto rowCost = eventItem.quantity * eventItem.unitPrice;

      if (auto existing = key in aggregate) {
        existing.quantity += eventItem.quantity;
        existing.totalCost += rowCost;
      } else {
        MonthlyCostAggregate row;
        row.subaccountId = eventItem.subaccountId;
        row.metric = eventItem.metric;
        row.currency = eventItem.currency;
        row.quantity = eventItem.quantity;
        row.unitPrice = eventItem.unitPrice;
        row.totalCost = rowCost;
        aggregate[key] = row;
      }
    }

    Json resources = Json.emptyArray;
    foreach (_, row; aggregate) {
      Json item = Json.emptyObject;
      item["subaccount_id"] = row.subaccountId;
      item["metric"] = row.metric;
      item["currency"] = row.currency;
      item["total_quantity"] = row.quantity;
      item["unit_price"] = row.unitPrice;
      item["total_cost"] = row.totalCost;
      resources ~= item;
    }

    Json payload = Json.emptyObject;
    payload["tenant_id"] = tenantId;
    payload["interval"] = "monthly";
    payload["month"] = month;
    payload["commercial_model"] = "CPEA";
    payload["resources"] = resources;
    payload["total_results"] = cast(long)resources.length;
    return payload;
  }

  private Json endpoint(string method, string path, string description) {
    Json row = Json.emptyObject;
    row["method"] = method;
    row["path"] = path;
    row["description"] = description;
    return row;
  }

  private void validateTenant(string tenantId) {
    if (tenantId.length == 0) {
      throw new UDMValidationException("tenantId cannot be empty");
    }
  }

  private string normalizeEntityType(string value) {
    auto lowered = toLower(value);
    if (lowered == "account" || lowered == "directory" || lowered == "region" || lowered == "subaccount") {
      return lowered;
    }
    throw new UDMValidationException("entity_type must be one of: account, directory, region, subaccount");
  }

  private string entityValue(const UsageEvent eventItem, string entityType) {
    final switch (entityType) {
      case "account":
        return fallback(eventItem.accountId, "unknown-account");
      case "directory":
        return fallback(eventItem.directoryId, "unknown-directory");
      case "region":
        return fallback(eventItem.region, "unknown-region");
      case "subaccount":
        return fallback(eventItem.subaccountId, "unknown-subaccount");
    }
  }

  private string fallback(string value, string replacement) {
    return value.length > 0 ? value : replacement;
  }

  private void validateMonth(string value) {
    if (value.length != 7 || value[4] != '-') {
      throw new UDMValidationException("month must be in YYYY-MM format");
    }
  }

  private void validateDate(string value) {
    if (value.length != 10 || value[4] != '-' || value[7] != '-') {
      throw new UDMValidationException("date must be in YYYY-MM-DD format");
    }
  }

  private string currentMonth() {
    auto now = Clock.currTime().toISOExtString();
    return monthFromTimestamp(now);
  }

  private string monthFromTimestamp(string value) {
    if (value.length >= 7) {
      return value[0 .. 7];
    }
    return "";
  }

  private string dayFromTimestamp(string value) {
    if (value.length >= 10) {
      return value[0 .. 10];
    }
    return "";
  }

  private bool dateInRange(string day, string fromDate, string toDate) {
    return day.length == 10 && day >= fromDate && day <= toDate;
  }

  private bool metricAllowed(string metric, string[] filter) {
    if (filter.length == 0) {
      return true;
    }

    auto normalized = toLower(metric);
    foreach (allowed; filter) {
      if (allowed == normalized) {
        return true;
      }
    }
    return false;
  }

  private string[] normalizedMetricFilter(Json request) {
    string[] filter;
    if (!("metrics" in request) || !request["metrics"].isArray) {
      return filter;
    }

    foreach (item; request["metrics"].toArray) {
      if (!item.isString) {
        continue;
      }
      auto metric = toLower(item.get!string);
      if (metric.length > 0) {
        filter ~= metric;
      }
    }

    return sort(filter).array;
  }
}
