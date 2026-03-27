module uim.sap.pre.models.model;

import uim.sap.pre;

mixin(ShowModule!());

@safe:

/// A trained recommendation model.
class PREModel : SAPTenantObject {
  mixin(SAPtenantObject!PREModel);

  override bool initialize(Json[string] initData) {
    if (!super.initialize(initData)) {
      return false;
    }

    if ("modelId" in request && request["modelId"].isString) {
      modelId = UUID(request["modelId"].getString);
    }
    if ("name" in request && request["name"].isString) {
      name = request["name"].getString;
    }
    if ("description" in request && request["description"].isString) {
      description = request["description"].getString;
    }
    if ("modelType" in request && request["modelType"].isString) {
      modelType = PREModelType.fromString(request["modelType"].getString);
    }
    if ("scenarioType" in request && request["scenarioType"].isString) {
      scenarioType = PREScenarioType.fromString(request["scenarioType"].getString);
    }
    if ("status" in request && request["status"].isString) {
      status = PREModelStatus.fromString(request["status"].getString);
    }
    if ("hyperparameters" in request) {
      foreach (string k, v; request["hyperparameters"].toMap)
        hyperparameters[k] = v.getString;
    }
    if ("metrics" in request) {
      foreach (string k, v; request["metrics"].toMap)
        metrics[k] = v.getString;
    }
    // itemCount = request.getLong("itemCount", 0);
    // userCount = request.getLong("userCount", 0);
    // interactionCount = request.getLong("interactionCount", 0);
    // createdAt = request.getString("createdAt", "");
    // updatedAt = request.getString("updatedAt", "");
    // trainedAt = request.getString("trainedAt", "");

    m.modelId = j.getString("modelId", "");
    m.tenantId = j.getString("tenantId", "");
    m.name = j["name"].getString;
    m.description = j.getString("description", "");
    if ("hyperparameters" in j) {
      foreach (string k, v; j["hyperparameters"].toMap)
        m.hyperparameters[k] = v.getString;
    }
    if ("metrics" in j) {
      foreach (string k, v; j["metrics"].toMap)
        m.metrics[k] = v.getString;
    }
    // m.itemCount = j.getLong("itemCount", 0);
    // m.userCount = j.getLong("userCount", 0);
    // m.interactionCount = j.getLong("interactionCount", 0);
    // m.createdAt = j.getString("createdAt", "");
    // m.updatedAt = j.getString("updatedAt", "");
    // m.trainedAt = j.getString("trainedAt", "");

    return true;
  }

  UUID modelId;
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
  string trainedAt;

  Json moJson(const ref PREModel m) {
    Json hyperparameters = Json.emptyObject;
    foreach (k, v; m.hyperparameters)
      hyperparameters[k] = v;

    Json metrics = Json.emptyObject;
    foreach (k, v; m.metrics)
      metrics[k] = v;

    return Json.emptyObject
      .set("modelId", m.modelId)
      .set("tenantId", m.tenantId)
      .set("name", m.name)
      .set("description", m.description)
      .set("modelType", m.modelType.to!string)
      .set("scenarioType", m.scenarioType.to!string)
      .set("status", m.status.to!string)
      .set("hyperparameters", hyperparameters)
      .set("metrics", metrics)
      .set("itemCount", cast(long)m.itemCount)
      .set("userCount", cast(long)m.userCount)
      .set("interactionCount", cast(long)m.interactionCount)
      .set("createdAt", m.createdAt)
      .set("updatedAt", m.updatedAt)
      .set("trainedAt", m.trainedAt);
  }

  static PREModel modelFromJson(Json j) {
    PREModel m = new PREModel(j);
    return m;
  }

}
