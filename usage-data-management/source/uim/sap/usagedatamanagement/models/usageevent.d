module uim.sap.usagedatamanagement.models.usageevent;

import std.datetime : Clock, SysTime;

import uim.sap.usagedatamanagement;

mixin(ShowModule!());

@safe:

class UsageEvent : SAPTenantObject {
mixin(SAPObjectTemplate!UsageEvent); 

  UUID usageEventId;
  UUID accountId;
  UUID directoryId;
  UUID subaccountId;
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

  override Json toJson()  {
    return super.toJson
    .set("usage_event_id", usageEventId)
    .set("account_id", accountId)
    .set("directory_id", directoryId)
    .set("subaccount_id", subaccountId)
    .set("region", region)
    .set("service_name", serviceName)
    .set("plan_name", planName)
    .set("metric", metric)
    .set("quantity", quantity)
    .set("unit", unit)
    .set("billable", billable)
    .set("unit_price", unitPrice)
    .set("currency", currency)
    .set("occurred_at", occurredAt);
  }

  static UsageEvent fromJson(UUID tenantId, Json request) {
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
    eventItem.billable = optionalBoolean("billable", false);
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
