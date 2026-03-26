module uim.sap.kym.models.subscription;

import uim.sap.kym;

mixin(ShowModule!());

@safe:

/// An event subscription linking an event type to a consumer (function or microservice)
struct KYMSubscription {
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
    SysTime createdAt;
    SysTime updatedAt;

    override Json toJson()  {
        Json payload = Json.emptyObject;
        payload["id"] = id;
        payload["namespace"] = namespace;
        payload["event_type"] = eventType;
        payload["source"] = source;
        payload["trigger_type"] = cast(string) triggerType;
        payload["consumer_name"] = consumerName;
        payload["consumer_kind"] = consumerKind;
        payload["active"] = active;
        payload["filters"] = filters;
        payload["delivered_count"] = deliveredCount;
        payload["created_at"] = createdAt.toISOExtString();
        payload["updated_at"] = updatedAt.toISOExtString();
        return payload;
    }
}

KYMSubscription subscriptionFromJson(string namespace, Json request) {
    KYMSubscription sub;
    sub.Id = randomUUID();
    sub.namespace = namespace;
    sub.createdAt = Clock.currTime();
    sub.updatedAt = sub.createdAt;

    if ("event_type" in request && request["event_type"].isString)
        sub.eventType = request["event_type"].get!string;
    if ("source" in request && request["source"].isString)
        sub.source = request["source"].get!string;
    if ("trigger_type" in request && request["trigger_type"].isString)
        sub.triggerType = parseTriggerType(request["trigger_type"].get!string);
    if ("consumer_name" in request && request["consumer_name"].isString)
        sub.consumerName = request["consumer_name"].get!string;
    if ("consumer_kind" in request && request["consumer_kind"].isString)
        sub.consumerKind = request["consumer_kind"].get!string;
    if ("active" in request && request["active"].isBool)
        sub.active = request["active"].get!bool;
    if ("filters" in request && request["filters"].isObject)
        sub.filters = request["filters"];
    else
        sub.filters = Json.emptyObject;
    return sub;
}
