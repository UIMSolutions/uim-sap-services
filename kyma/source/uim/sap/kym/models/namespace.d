module uim.sap.kym.models.namespace;

import uim.sap.kym;

mixin(ShowModule!());

@safe:

/// A Kyma namespace isolates workloads like a Kubernetes namespace
class KYMNamespace : SAPObject {
  mixin(SAPObject!KYMNamespace);

  override bool initialize(Json[string] initData) {
    if (!super.initialize(initData)) {
      return false;
    }

    if ("description" in initData && initData["description"].isString) {
      description = initData["description"].getString;
    }
    if ("labels" in initData && initData["labels"].isObject) {
      labels = initData["labels"];
    } else {
      labels = Json.emptyObject;
    }

    return true;
  }

  string name;
  string description;
  Json labels;
  KYMResourceStatus status = KYMResourceStatus.RUNNING;

  override Json toJson() {
    return super.toJson()
      .set("name", name)
      .set("description", description)
      .set("labels", labels)
      .set("status", cast(string)status);
  }
}

KYMNamespace namespaceFromJson(string name, Json request) {
  KYMNamespace ns = new KYMNamespace(request);
  ns.name = name;
  ns.createdAt = Clock.currTime();
  ns.updatedAt = ns.createdAt;
  ns.status = KYMResourceStatus.RUNNING;

  return ns;
}
