module uim.sap.usagedatamanagement.models.usageevent;

import std.datetime : Clock, SysTime;

import uim.sap.usagedatamanagement;

mixin(ShowModule!());

@safe:

struct UsageEvent {
  string tenantId;
  string usageEventId;
  string accountId;
  string directoryId;
  string subaccountId;
  string region;
  string serviceName;
  string planName;
  string metric;
  double quantity;
  string unit;
  bool billable;
  double unitPrice;
  string currency;
  string occurredAt;
  SysTime createdAt;

  Json toJson() const {
    Json payload = Json.emptyObject;
    payload["tenant_id"] = tenantId;
    payload["usage_event_id"] = usageEventId;
    payload["account_id"] = accountId;
    payload["directory_id"] = directoryId;
    payload["subaccount_id"] = subaccountId;
    payload["region"] = region;
    payload["service_name"] = serviceName;
    payload["plan_name"] = planName;
    payload["metric"] = metric;
    payload["quantity"] = quantity;
    payload["unit"] = unit;
    payload["billable"] = billable;
    payload["unit_price"] = unitPrice;
    payload["currency"] = currency;
    payload["occurred_at"] = occurredAt;
    payload["created_at"] = createdAt.toISOExtString();
    return payload;
  }

  static UsageEvent fromJson(string tenantId, Json request) {
    UsageEvent eventItem;
    eventItem.tenantId = tenantId;
    eventItem.usageEventId = request.getString("usage_event_id", createId());
    eventItem.accountId = request.getString("account_id", "");
    eventItem.directoryId = request.getString("directory_id", "");
    eventItem.subaccountId = request.getString("subaccount_id", "");
    eventItem.region = request.getString("region", "");
    eventItem.serviceName = request.getString("service_name", "");
    eventItem.planName = request.getString("plan_name", "");
    eventItem.metric = request.getString("metric", "");
    eventItem.quantity = 0.0;
    if ("quantity" in request) {
      if (request["quantity"].isFloat) {
        eventItem.quantity = request["quantity"].get!double;
      } else if (request["quantity"].isInteger) {
        eventItem.quantity = cast(double)request["quantity"].get!long;
      }
    }

    eventItem.unit = request.getString("unit", "count");
    eventItem.billable = request.getBoolean("billable", false);
    eventItem.currency = request.getString("currency", "EUR");
    eventItem.unitPrice = 0.0;
    if ("unit_price" in request) {
      if (request["unit_price"].isFloat) {
        eventItem.unitPrice = request["unit_price"].get!double;
      } else if (request["unit_price"].isInteger) {
        eventItem.unitPrice = cast(double)request["unit_price"].get!long;
      }
    }

    eventItem.occurredAt = request.getString("occurred_at", Clock.currTime().toISOExtString());
    eventItem.createdAt = Clock.currTime();
    return eventItem;
  }
}
