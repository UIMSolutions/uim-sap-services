module uim.sap.pre.models.scenario;

import uim.sap.pre;

mixin(ShowModule!());

@safe:

/// A business scenario that ties a model to a recommendation use-case.
struct PREScenario {
    string scenarioId;
    string tenantId;
    string name;
    string description;
    PREScenarioType scenarioType = PREScenarioType.ecommerce;
    string modelId;
    bool active = true;
    string[string] config;
    string createdAt;
    string updatedAt;
}

Json scenarioToJson(const ref PREScenario s) {
    Json j = Json.emptyObject;
    j["scenarioId"] = s.scenarioId;
    j["tenantId"] = s.tenantId;
    j["name"] = s.name;
    j["description"] = s.description;
    j["scenarioType"] = s.scenarioType.to!string;
    j["modelId"] = s.modelId;
    j["active"] = s.active;
    {
        Json obj = Json.emptyObject;
        foreach (k, v; s.config)
            obj[k] = v;
        j["config"] = obj;
    }
    j["createdAt"] = s.createdAt;
    j["updatedAt"] = s.updatedAt;
    return j;
}

PREScenario scenarioFromJson(Json j) {
    PREScenario s;
    s.scenarioId = j.getOrDefault!string("scenarioId", "");
    s.tenantId = j.getOrDefault!string("tenantId", "");
    s.name = j["name"].get!string;
    s.description = j.getOrDefault!string("description", "");
    if ("modelId" in j)
        s.modelId = j["modelId"].get!string;
    if ("active" in j)
        s.active = j["active"].get!bool;
    if ("config" in j) {
        foreach (string k, v; j["config"])
            s.config[k] = v.get!string;
    }
    return s;
}
