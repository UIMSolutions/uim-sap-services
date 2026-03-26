module uim.sap.usagedatamanagement.service;

import std.algorithm.sorting : sort;
import std.array : array;
import std.datetime : Clock;
import std.string : toLower;

import uim.sap.usagedatamanagement;

mixin(ShowModule!());

@safe:

private struct MonthlyUsageAggregate {
  string entityType;
  UUID entityId;
  string metric;
  string unit;
  double quantity;
}

private struct DailyUsageAggregate {
  string day;
  string entityType;
  UUID entityId;
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

    return Json.emptyObject
      .set("service", "usage-data-management")
      .set("version", UIM_USAGE_DATA_MANAGEMENT_VERSION)
      .set("endpoints", endpoints)
      .set("total_results", cast(long)endpoints.length);
  }

  Json ingestUsageEvent(UUID tenantId, Json request) {
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

    if ("tenant_id" in request || !request["tenant_id"].isString || request["tenant_id"].get!string != tenantId
      .toString) {
      throw new UDMValidationException("tenant_id in path and body must match");
    }
    if (eventItem.subaccountId.length == 0) {
      throw new UDMValidationException("subaccount_id is required");
    }

    auto saved = _store.appendEvent(eventItem);

    return Json.emptyObject
      .set("success", true)
      .set("event", saved.toJson());
  }

  Json listUsageEvents(UUID tenantId) {
    validateTenant(tenantId);

    Json resources = _store.listEvents(tenantId).map!(eventItem => eventItem.toJson()).array;

    return Json.emptyObject
      .set("tenant_id", tenantId)
      .set("resources", resources)
      .set("total_results", cast(long)resources.length);
  }

  Json listTenants() {
    Json resources = Json.emptyArray;
    foreach (tenantId; _store.listTenants()) {
      resources ~= Json.emptyObject
        .set("tenant_id", tenantId)
        .set("events_total", _store.countEvents(tenantId));
    }

    return Json.emptyObject
      .set("resources", resources)
      .set("total_results", cast(long)resources.length);
  }

  Json monthlyUsageReport(UUID tenantId, Json request) {
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
      resources ~= Json.emptyObject
        .set("entity_type", row.entityType)
        .set("entity_id", row.entityId)
        .set("metric", row.metric)
        .set("unit", row.unit)
        .set("total_quantity", row.quantity);
    }

    return Json.emptyObject
      .set("tenant_id", tenantId)
      .set("interval", "monthly")
      .set("month", month)
      .set("entity_type", entityType)
      .set("resources", resources)
      .set("total_results", cast(long)resources.length);
  }

  Json subaccountUsageReport(UUID tenantId, Json request) {
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
      resources ~= Json.emptyObject
        .set("day", row.day)
        .set("entity_type", row.entityType)
        .set("entity_id", row.entityId)
        .set("metric", row.metric)
        .set("unit", row.unit)
        .set("total_quantity", row.quantity);
    }

    return Json.emptyObject
      .set("tenant_id", tenantId)
      .set("interval", "daily")
      .set("from_date", fromDate)
      .set("to_date", toDate)
      .set("entity_type", entityType)
      .set("resources", resources)
      .set("total_results", cast(long)resources.length);
  }

  Json monthlySubaccountCostsReport(UUID tenantId, Json request) {
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

      auto key = eventItem.subaccountId ~ "|" ~ toLower(eventItem.metric) ~ "|" ~ eventItem
        .currency;
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
      resources ~= Json.emptyObject
        .set("subaccount_id", row.subaccountId)
        .set("metric", row.metric)
        .set("currency", row.currency)
        .set("total_quantity", row.quantity)
        .set("unit_price", row.unitPrice)
        .set("total_cost", row.totalCost);
    }

    return Json.emptyObject
      .set("tenant_id", tenantId)
      .set("interval", "monthly")
      .set("month", month)
      .set("commercial_model", "CPEA")
      .set("resources", resources)
      .set("total_results", cast(long)resources.length);
  }

  private Json endpoint(string method, string path, string description) {
    Json row = Json.emptyObject;
    row["method"] = method;
    row["path"] = path;
    row["description"] = description;
    return row;
  }

  private string normalizeEntityType(string value) {
    auto lowered = toLower(value);
    if (lowered == "account" || lowered == "directory" || lowered == "region" || lowered == "subaccount") {
      return lowered;
    }
    throw new UDMValidationException(
      "entity_type must be one of: account, directory, region, subaccount");
  }

  private string entityValue(const UsageEvent eventItem, string entityType) {
    switch (entityType) {
    case "account":
      return fallback(eventItem.accountId, "unknown-account");
    case "directory":
      return fallback(eventItem.directoryId, "unknown-directory");
    case "region":
      return fallback(eventItem.region, "unknown-region");
    case "subaccount":
      return fallback(eventItem.subaccountId, "unknown-subaccount");
    default:
      throw new UDMValidationException("Unsupported entity_type: " ~ entityType);
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
