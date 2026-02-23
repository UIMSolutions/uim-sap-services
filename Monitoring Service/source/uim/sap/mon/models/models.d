module uim.sap.mon.models.models;

import std.datetime : Clock, SysTime;
import std.uuid : randomUUID;

import vibe.data.json : Json;



struct MONAvailabilityCheck {
    string checkId;
    string targetType;
    string targetId;
    string endpoint;
    int intervalSeconds;
    int timeoutSeconds;
    int expectedStatus;
    bool enabled;
    SysTime createdAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["check_id"] = checkId;
        payload["target_type"] = targetType;
        payload["target_id"] = targetId;
        payload["endpoint"] = endpoint;
        payload["interval_seconds"] = intervalSeconds;
        payload["timeout_seconds"] = timeoutSeconds;
        payload["expected_status"] = expectedStatus;
        payload["enabled"] = enabled;
        payload["created_at"] = createdAt.toISOExtString();
        return payload;
    }
}

struct MONAlertEmailChannel {
    bool enabled;
    string[] recipients;
    string sender;
    string subjectPrefix;
    SysTime updatedAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        Json recipientList = Json.emptyArray;
        foreach (item; recipients) {
            recipientList ~= item;
        }
        payload["enabled"] = enabled;
        payload["recipients"] = recipientList;
        payload["sender"] = sender;
        payload["subject_prefix"] = subjectPrefix;
        payload["updated_at"] = updatedAt.toISOExtString();
        return payload;
    }
}

struct MONAlertWebhookChannel {
    bool enabled;
    string url;
    string secret;
    string method = "POST";
    SysTime updatedAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["enabled"] = enabled;
        payload["url"] = url;
        payload["method"] = method;
        payload["secret"] = secret;
        payload["updated_at"] = updatedAt.toISOExtString();
        return payload;
    }
}

struct MONJMXCheck {
    string checkId;
    string targetId;
    string mbean;
    string attribute;
    string comparator;
    double threshold;
    bool enabled;
    SysTime createdAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["check_id"] = checkId;
        payload["target_id"] = targetId;
        payload["mbean"] = mbean;
        payload["attribute"] = attribute;
        payload["comparator"] = comparator;
        payload["threshold"] = threshold;
        payload["enabled"] = enabled;
        payload["created_at"] = createdAt.toISOExtString();
        return payload;
    }
}

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
