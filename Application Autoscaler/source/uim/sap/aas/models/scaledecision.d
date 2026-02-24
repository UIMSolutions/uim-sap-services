module uim.sap.aas.models.scaledecision;

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
