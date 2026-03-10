module uim.sap.obs.models.lifecycle;

import std.datetime : Clock, SysTime;

import vibe.data.json : Json;

import uim.sap.obs.enumerations;

@safe:

/// Lifecycle rule for automatic object transitions or expiration
struct OBSLifecycleRule {
    string ruleId;
    string bucketId;
    string prefix;               // object key prefix filter
    bool enabled = true;
    OBSLifecycleAction action = OBSLifecycleAction.transition;
    OBSStorageClass targetClass; // for transition actions
    size_t daysAfterCreation;    // trigger after N days
    SysTime createdAt;

    Json toJson() const {
        import std.conv : to;
        Json j = Json.emptyObject;
        j["rule_id"] = ruleId;
        j["bucket_id"] = bucketId;
        j["prefix"] = prefix;
        j["enabled"] = enabled;
        j["action"] = cast(string) action;
        j["target_class"] = cast(string) targetClass;
        j["days_after_creation"] = daysAfterCreation.to!long;
        j["created_at"] = createdAt.toISOExtString();
        return j;
    }
}

OBSLifecycleRule lifecycleRuleFromJson(string ruleId, string bucketId, Json req) {
    OBSLifecycleRule r;
    r.ruleId = ruleId;
    r.bucketId = bucketId;
    r.createdAt = Clock.currTime();

    if ("prefix" in req && req["prefix"].isString)
        r.prefix = req["prefix"].get!string;
    if ("enabled" in req && req["enabled"].type == Json.Type.bool_)
        r.enabled = req["enabled"].get!bool;
    if ("action" in req && req["action"].isString) {
        switch (req["action"].get!string) {
            case "expiration": r.action = OBSLifecycleAction.expiration; break;
            default: r.action = OBSLifecycleAction.transition; break;
        }
    }
    if ("target_class" in req && req["target_class"].isString) {
        switch (req["target_class"].get!string) {
            case "nearline": r.targetClass = OBSStorageClass.nearline; break;
            case "coldline": r.targetClass = OBSStorageClass.coldline; break;
            case "archive": r.targetClass = OBSStorageClass.archive; break;
            default: r.targetClass = OBSStorageClass.nearline; break;
        }
    }
    if ("days_after_creation" in req && req["days_after_creation"].type == Json.Type.int_)
        r.daysAfterCreation = cast(size_t) req["days_after_creation"].get!long;
    return r;
}
