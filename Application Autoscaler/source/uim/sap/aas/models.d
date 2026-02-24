/**
 * Models for AAS service
 */
module uim.sap.aas.models;

import std.algorithm.comparison : max, min;
import std.datetime : Clock, SysTime;
import std.uuid : randomUUID;

import vibe.data.json : Json;

enum AASMetricType {
    cpu,
    memory,
    responseTime,
    throughput,
    custom
}

struct AASApp {
    string id;
    string name;
    string organization;
    string space;
    uint currentInstances;
    uint minInstances;
    uint maxInstances;
    double instanceHourlyCost;
    SysTime createdAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["id"] = id;
        payload["name"] = name;
        payload["organization"] = organization;
        payload["space"] = space;
        payload["current_instances"] = cast(long)currentInstances;
        payload["min_instances"] = cast(long)minInstances;
        payload["max_instances"] = cast(long)maxInstances;
        payload["instance_hourly_cost"] = instanceHourlyCost;
        payload["estimated_hourly_cost"] = instanceHourlyCost * currentInstances;
        payload["created_at"] = createdAt.toISOExtString();
        return payload;
    }
}

struct AASScalingPolicy {
    string id;
    string appId;
    AASMetricType metricType;
    string customMetricName;
    double scaleOutThreshold;
    double scaleInThreshold;
    uint scaleOutStep = 1;
    uint scaleInStep = 1;
    uint minInstances;
    uint maxInstances;
    uint cooldownSeconds = 60;
    SysTime createdAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["id"] = id;
        payload["app_id"] = appId;
        payload["metric_type"] = metricTypeToString(metricType);
        payload["custom_metric_name"] = customMetricName;
        payload["scale_out_threshold"] = scaleOutThreshold;
        payload["scale_in_threshold"] = scaleInThreshold;
        payload["scale_out_step"] = cast(long)scaleOutStep;
        payload["scale_in_step"] = cast(long)scaleInStep;
        payload["min_instances"] = cast(long)minInstances;
        payload["max_instances"] = cast(long)maxInstances;
        payload["cooldown_seconds"] = cast(long)cooldownSeconds;
        payload["created_at"] = createdAt.toISOExtString();
        return payload;
    }
}

struct AASMetricSnapshot {
    double cpuPercent;
    double memoryPercent;
    double responseTimeMs;
    double throughputRps;
    double[string] custom;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["cpu_percent"] = cpuPercent;
        payload["memory_percent"] = memoryPercent;
        payload["response_time_ms"] = responseTimeMs;
        payload["throughput_rps"] = throughputRps;

        Json customJson = Json.emptyObject;
        foreach (key, value; custom) {
            customJson[key] = value;
        }
        payload["custom"] = customJson;
        return payload;
    }
}

struct AASScaleDecision {
    string appId;
    uint currentInstances;
    uint desiredInstances;
    string direction;
    string reason;
    double currentHourlyCost;
    double desiredHourlyCost;
    SysTime evaluatedAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["app_id"] = appId;
        payload["current_instances"] = cast(long)currentInstances;
        payload["desired_instances"] = cast(long)desiredInstances;
        payload["direction"] = direction;
        payload["reason"] = reason;
        payload["current_hourly_cost"] = currentHourlyCost;
        payload["desired_hourly_cost"] = desiredHourlyCost;
        payload["evaluated_at"] = evaluatedAt.toISOExtString();
        return payload;
    }
}

AASMetricType metricTypeFromString(string value) {
    switch (value) {
        case "cpu": return AASMetricType.cpu;
        case "memory": return AASMetricType.memory;
        case "response_time": return AASMetricType.responseTime;
        case "throughput": return AASMetricType.throughput;
        case "custom": return AASMetricType.custom;
        default: return AASMetricType.custom;
    }
}

string metricTypeToString(AASMetricType metricType) {
    final switch (metricType) {
        case AASMetricType.cpu: return "cpu";
        case AASMetricType.memory: return "memory";
        case AASMetricType.responseTime: return "response_time";
        case AASMetricType.throughput: return "throughput";
        case AASMetricType.custom: return "custom";
    }
}

AASApp appFromJson(Json payload) {
    AASApp app;
    app.id = randomUUID().toString();
    app.createdAt = Clock.currTime();

    string textValue;
    long integerValue;
    double numberValue;

    if (tryGetString(payload, "name", textValue)) {
        app.name = textValue;
    }
    if (tryGetString(payload, "organization", textValue)) {
        app.organization = textValue;
    }
    if (tryGetString(payload, "space", textValue)) {
        app.space = textValue;
    }
    if (tryGetLong(payload, "current_instances", integerValue)) {
        app.currentInstances = cast(uint)integerValue;
    }
    if (tryGetLong(payload, "min_instances", integerValue)) {
        app.minInstances = cast(uint)integerValue;
    }
    if (tryGetLong(payload, "max_instances", integerValue)) {
        app.maxInstances = cast(uint)integerValue;
    }
    if (tryGetDouble(payload, "instance_hourly_cost", numberValue)) {
        app.instanceHourlyCost = numberValue;
    }

    if (app.minInstances == 0) {
        app.minInstances = 1;
    }
    if (app.maxInstances == 0) {
        app.maxInstances = max(3u, app.minInstances);
    }
    if (app.currentInstances == 0) {
        app.currentInstances = app.minInstances;
    }
    app.currentInstances = min(max(app.currentInstances, app.minInstances), app.maxInstances);

    if (app.instanceHourlyCost <= 0) {
        app.instanceHourlyCost = 0.05;
    }

    return app;
}

AASScalingPolicy policyFromJson(Json payload, string appId) {
    AASScalingPolicy policy;
    policy.id = randomUUID().toString();
    policy.appId = appId;
    policy.createdAt = Clock.currTime();

    string textValue;
    long integerValue;
    double numberValue;

    if (tryGetString(payload, "metric_type", textValue)) {
        policy.metricType = metricTypeFromString(textValue);
    }
    if (tryGetString(payload, "custom_metric_name", textValue)) {
        policy.customMetricName = textValue;
    }
    if (tryGetDouble(payload, "scale_out_threshold", numberValue)) {
        policy.scaleOutThreshold = numberValue;
    }
    if (tryGetDouble(payload, "scale_in_threshold", numberValue)) {
        policy.scaleInThreshold = numberValue;
    }
    if (tryGetLong(payload, "scale_out_step", integerValue)) {
        policy.scaleOutStep = cast(uint)integerValue;
    }
    if (tryGetLong(payload, "scale_in_step", integerValue)) {
        policy.scaleInStep = cast(uint)integerValue;
    }
    if (tryGetLong(payload, "min_instances", integerValue)) {
        policy.minInstances = cast(uint)integerValue;
    }
    if (tryGetLong(payload, "max_instances", integerValue)) {
        policy.maxInstances = cast(uint)integerValue;
    }
    if (tryGetLong(payload, "cooldown_seconds", integerValue)) {
        policy.cooldownSeconds = cast(uint)integerValue;
    }

    if (policy.scaleOutStep == 0) {
        policy.scaleOutStep = 1;
    }
    if (policy.scaleInStep == 0) {
        policy.scaleInStep = 1;
    }

    return policy;
}

AASMetricSnapshot metricsFromJson(Json payload) {
    AASMetricSnapshot snapshot;

    double numberValue;
    if (tryGetDouble(payload, "cpu_percent", numberValue)) {
        snapshot.cpuPercent = numberValue;
    }
    if (tryGetDouble(payload, "memory_percent", numberValue)) {
        snapshot.memoryPercent = numberValue;
    }
    if (tryGetDouble(payload, "response_time_ms", numberValue)) {
        snapshot.responseTimeMs = numberValue;
    }
    if (tryGetDouble(payload, "throughput_rps", numberValue)) {
        snapshot.throughputRps = numberValue;
    }

    if ("custom" in payload && payload["custom"].type == Json.Type.object) {
        foreach (key, value; payload["custom"].byKeyValue) {
            try {
                snapshot.custom[key] = value.get!double;
            } catch (Exception) {
            }
        }
    }

    return snapshot;
}

private bool tryGetString(Json payload, string key, out string value) {
    if (!(key in payload)) {
        return false;
    }
    try {
        value = payload[key].get!string;
        return true;
    } catch (Exception) {
        return false;
    }
}

private bool tryGetLong(Json payload, string key, out long value) {
    if (!(key in payload)) {
        return false;
    }
    try {
        value = payload[key].get!long;
        return true;
    } catch (Exception) {
        return false;
    }
}

private bool tryGetDouble(Json payload, string key, out double value) {
    if (!(key in payload)) {
        return false;
    }
    try {
        value = payload[key].get!double;
        return true;
    } catch (Exception) {
        return false;
    }
}
