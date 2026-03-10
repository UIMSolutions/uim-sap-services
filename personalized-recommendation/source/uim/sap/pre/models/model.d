module uim.sap.pre.models.model;

import uim.sap.pre;

mixin(ShowModule!());

@safe:

/// A trained recommendation model.
struct PREModel {
    string modelId;
    string tenantId;
    string name;
    string description;
    PREModelType modelType = PREModelType.collaborative_filtering;
    PREScenarioType scenarioType = PREScenarioType.ecommerce;
    PREModelStatus status = PREModelStatus.created;
    string[string] hyperparameters;
    string[string] metrics;
    size_t itemCount;
    size_t userCount;
    size_t interactionCount;
    string createdAt;
    string updatedAt;
    string trainedAt;
}

Json modelToJson(const ref PREModel m) {
    Json j = Json.emptyObject;
    j["modelId"] = m.modelId;
    j["tenantId"] = m.tenantId;
    j["name"] = m.name;
    j["description"] = m.description;
    j["modelType"] = m.modelType.to!string;
    j["scenarioType"] = m.scenarioType.to!string;
    j["status"] = m.status.to!string;
    {
        Json obj = Json.emptyObject;
        foreach (k, v; m.hyperparameters)
            obj[k] = v;
        j["hyperparameters"] = obj;
    }
    {
        Json obj = Json.emptyObject;
        foreach (k, v; m.metrics)
            obj[k] = v;
        j["metrics"] = obj;
    }
    j["itemCount"] = cast(long) m.itemCount;
    j["userCount"] = cast(long) m.userCount;
    j["interactionCount"] = cast(long) m.interactionCount;
    j["createdAt"] = m.createdAt;
    j["updatedAt"] = m.updatedAt;
    j["trainedAt"] = m.trainedAt;
    return j;
}

PREModel modelFromJson(Json j) {
    PREModel m;
    m.modelId = j.getOrDefault!string("modelId", "");
    m.tenantId = j.getOrDefault!string("tenantId", "");
    m.name = j["name"].get!string;
    m.description = j.getOrDefault!string("description", "");
    if ("hyperparameters" in j) {
        foreach (string k, v; j["hyperparameters"])
            m.hyperparameters[k] = v.get!string;
    }
    return m;
}
