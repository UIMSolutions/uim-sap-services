module uim.sap.aas.models.scalingpolicy;

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