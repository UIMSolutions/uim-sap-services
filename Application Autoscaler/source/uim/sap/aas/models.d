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
    final switch (value) {
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

    if ("name" in payload && payload["name"].type == Json.Type.string) {
        app.name = payload["name"].get!string;
    }
    if ("organization" in payload && payload["organization"].type == Json.Type.string) {
        app.organization = payload["organization"].get!string;
    }
    if ("space" in payload && payload["space"].type == Json.Type.string) {
        app.space = payload["space"].get!string;
    }
    if ("current_instances" in payload && payload["current_instances"].type.isIntegral) {
        app.currentInstances = cast(uint)payload["current_instances"].get!long;
    }
    if ("min_instances" in payload && payload["min_instances"].type.isIntegral) {
        app.minInstances = cast(uint)payload["min_instances"].get!long;
    }
    if ("max_instances" in payload && payload["max_instances"].type.isIntegral) {
        app.maxInstances = cast(uint)payload["max_instances"].get!long;
    }
    if ("instance_hourly_cost" in payload && payload["instance_hourly_cost"].type.isNumeric) {
        app.instanceHourlyCost = payload["instance_hourly_cost"].get!double;
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

    if ("metric_type" in payload && payload["metric_type"].type == Json.Type.string) {
        policy.metricType = metricTypeFromString(payload["metric_type"].get!string);
    }
    if ("custom_metric_name" in payload && payload["custom_metric_name"].type == Json.Type.string) {
        policy.customMetricName = payload["custom_metric_name"].get!string;
    }
    if ("scale_out_threshold" in payload && payload["scale_out_threshold"].type.isNumeric) {
        policy.scaleOutThreshold = payload["scale_out_threshold"].get!double;
    }
    if ("scale_in_threshold" in payload && payload["scale_in_threshold"].type.isNumeric) {
        policy.scaleInThreshold = payload["scale_in_threshold"].get!double;
    }
    if ("scale_out_step" in payload && payload["scale_out_step"].type.isIntegral) {
        policy.scaleOutStep = cast(uint)payload["scale_out_step"].get!long;
    }
    if ("scale_in_step" in payload && payload["scale_in_step"].type.isIntegral) {
        policy.scaleInStep = cast(uint)payload["scale_in_step"].get!long;
    }
    if ("min_instances" in payload && payload["min_instances"].type.isIntegral) {
        policy.minInstances = cast(uint)payload["min_instances"].get!long;
    }
    if ("max_instances" in payload && payload["max_instances"].type.isIntegral) {
        policy.maxInstances = cast(uint)payload["max_instances"].get!long;
    }
    if ("cooldown_seconds" in payload && payload["cooldown_seconds"].type.isIntegral) {
        policy.cooldownSeconds = cast(uint)payload["cooldown_seconds"].get!long;
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

    if ("cpu_percent" in payload && payload["cpu_percent"].type.isNumeric) {
        snapshot.cpuPercent = payload["cpu_percent"].get!double;
    }
    if ("memory_percent" in payload && payload["memory_percent"].type.isNumeric) {
        snapshot.memoryPercent = payload["memory_percent"].get!double;
    }
    if ("response_time_ms" in payload && payload["response_time_ms"].type.isNumeric) {
        snapshot.responseTimeMs = payload["response_time_ms"].get!double;
    }
    if ("throughput_rps" in payload && payload["throughput_rps"].type.isNumeric) {
        snapshot.throughputRps = payload["throughput_rps"].get!double;
    }

    if ("custom" in payload && payload["custom"].type == Json.Type.object) {
        foreach (key, value; payload["custom"].byKeyValue) {
            if (value.type.isNumeric) {
                snapshot.custom[key] = value.get!double;
            }
        }
    }

    return snapshot;
}
