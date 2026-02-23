module uim.sap.mon.models.models;

import std.datetime : Clock, SysTime;
import std.uuid : randomUUID;

import vibe.data.json : Json;








struct MONCustomCheck {
    string checkId;
    string name;
    string targetType;
    string targetId;
    string endpoint;
    string method;
    int expectedStatus;
    SysTime createdAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["check_id"] = checkId;
        payload["name"] = name;
        payload["target_type"] = targetType;
        payload["target_id"] = targetId;
        payload["endpoint"] = endpoint;
        payload["method"] = method;
        payload["expected_status"] = expectedStatus;
        payload["created_at"] = createdAt.toISOExtString();
        return payload;
    }
}

string newCheckId(string prefix) {
    return prefix ~ "-" ~ randomUUID().toString();
}

MONMetricSample metricSample(string targetType, string targetId, string metricKind, double value, string unit) {
    MONMetricSample sample;
    sample.targetType = targetType;
    sample.targetId = targetId;
    sample.metricKind = metricKind;
    sample.value = value;
    sample.unit = unit;
    sample.collectedAt = Clock.currTime();
    return sample;
}
