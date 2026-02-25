module uim.sap.aas.models.app;

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