module uim.sap.agentry.models.runtime;

class AGTRuntimeInstance : SAPTenantObject {
  mixin(SAPObjectTemplate!AGTRuntimeInstance);

  UUID instanceId;
  UUID appId;
  string targetEnvironment;
  UUID deployedVersionId;
  string status = "running";

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    if ("instance_id" in initData && initData["instance_id"].isString) {
      instance.instanceId = initData["instance_id"].get!string;
    }
    if ("app_id" in initData && initData["app_id"].isString) {
      instance.appId = initData["app_id"].get!string;
    }
    if ("target_environment" in initData && initData["target_environment"].isString) {
      instance.targetEnvironment = initData["target_environment"].get!string;
    }
    if ("deployed_version_id" in initData && initData["deployed_version_id"].isString) {
      instance.deployedVersionId = initData["deployed_version_id"].get!string;
    }
    if ("status" in initData && initData["status"].isString) {
      instance.status = toLower(initData["status"].get!string);
    }

    return true;
  }

  override Json toJson() {
    return super.toJson()
      .set("instance_id", instanceId)
      .set("app_id", appId)
      .set("target_environment", targetEnvironment)
      .set("deployed_version_id", deployedVersionId)
      .set("status", status);
  }

  static AGTRuntimeInstance opCall(string tenantId, Json request) {
    AGTRuntimeInstance instance = new AGTRuntimeInstance(request);
    instance.tenantId = UUID(tenantId);
    instance.instanceId = randomUUID().toString();
    instance.targetEnvironment = "prod";
    instance.updatedAt = Clock.currTime();

    return instance;
  }
}
