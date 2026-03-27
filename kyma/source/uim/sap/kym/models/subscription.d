module uim.sap.kym.models.subscription;

import uim.sap.kym;

mixin(ShowModule!());

@safe:

/// An event subscription linking an event type to a consumer (function or microservice)
class KYMSubscription : SAPObject {
  mixin(SAPObject!KYMSubscription);

  override bool initialize(Json[string] initData) {
    if (!super.initialize(initData)) {
      return false;
    }

    if ("event_type" in initData && initData["event_type"].isString)
      eventType = initData["event_type"].get!string;
    if ("source" in initData && initData["source"].isString)
      source = initData["source"].get!string;
    if ("trigger_type" in initData && initData["trigger_type"].isString)
      triggerType = parseTriggerType(initData["trigger_type"].get!string);
    if ("consumer_name" in initData && initData["consumer_name"].isString)
      consumerName = initData["consumer_name"].get!string;
    if ("consumer_kind" in initData && initData["consumer_kind"].isString)
      consumerKind = initData["consumer_kind"].get!string;
    if ("active" in initData && initData["active"].isBool)
      active = initData["active"].get!bool;
    if ("filters" in initData && initData["filters"].isObject)
      filters = initData["filters"];
    else
      filters = Json.emptyObject;

    return true;
  }

  string id;
  string namespace;
  string eventType;
  string source;
  KYMTriggerType triggerType = KYMTriggerType.EVENT;
  string consumerName;
  string consumerKind = "function";
  bool active = true;
  Json filters;
  long deliveredCount = 0;

  override Json toJson() {
    return super.toJson()
      .set("id", id)
      .set("namespace", namespace)
      .set("event_type", eventType)
      .set("source", source)
      .set("trigger_type", cast(string)triggerType)
      .set("consumer_name", consumerName)
      .set("consumer_kind", consumerKind)
      .set("active", active)
      .set("filters", filters)
      .set("delivered_count", deliveredCount);
  }

  static KYMSubscription subscriptionFromJson(string namespace, Json request) {
    KYMSubscription sub = new KYMSubscription();
    sub.Id = randomUUID();
    sub.namespace = namespace;
    sub.createdAt = Clock.currTime();
    sub.updatedAt = sub.createdAt;

    return sub;
  }

}
