module uim.sap.pre.models.model;

import uim.sap.pre;

mixin(ShowModule!());

@safe:

/// A trained recommendation model.
struct PREModel {
  string modelId;
  UUID tenantId;
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

Json moJson(const ref PREModel m) {
  Json hyperparameters = Json.emptyObject;
  foreach (k, v; m.hyperparameters)
    hyperparameters[k] = v;

  Json metrics = Json.emptyObject;
  foreach (k, v; m.metrics)
    metrics[k] = v;

  Json json = Json.emptyObject;
  json["modelId"] = m.modelId;
  json["tenantId"] = m.tenantId;
  json["name"] = m.name;
  json["description"] = m.description;
  json["modelType"] = m.modelType.to!string;
  json["scenarioType"] = m.scenarioType.to!string;
  json["status"] = m.status.to!string;
  json["hyperparameters"] = hyperparameters;
  json["metrics"] = metrics;
  json["itemCount"] = cast(long)m.itemCount;
  json["userCount"] = cast(long)m.userCount;
  json["interactionCount"] = cast(long)m.interactionCount;
  json["createdAt"] = m.createdAt;
  json["updatedAt"] = m.updatedAt;
  json["trainedAt"] = m.trainedAt;
  return json;
}
}
PREModel modelFromJson(Json j) {
  PREModel m = new PREModel(j);
  m.modelId = j.getString("modelId", "");
  m.tenantId = j.getString("tenantId", "");
  m.name = j["name"].get!string;
  m.description = j.getString("description", "");
  if ("hyperparameters" in j) {
    foreach (string k, v; j["hyperparameters"].toMap)
      m.hyperparameters[k] = v.get!string;
  }
  if ("metrics" in j) {
    foreach (string k, v; j["metrics"].toMap)
      m.metrics[k] = v.get!string;
  }
  // m.itemCount = j.getLong("itemCount", 0);
  // m.userCount = j.getLong("userCount", 0);
  // m.interactionCount = j.getLong("interactionCount", 0);
  // m.createdAt = j.getString("createdAt", "");
  // m.updatedAt = j.getString("updatedAt", "");
  // m.trainedAt = j.getString("trainedAt", "");
  return m;
}
