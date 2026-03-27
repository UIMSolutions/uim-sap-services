module uim.sap.agentry.models.runtime;
import uim.sap.agentry;

mixin(ShowModule!());

@safe:
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
      instanceId = UUID(initData["instance_id"].get!string);
    }
    if ("app_id" in initData && initData["app_id"].isString) {
      appId = UUID(initData["app_id"].get!string);
    }
    if ("target_environment" in initData && initData["target_environment"].isString) {
      targetEnvironment = initData["target_environment"].getString;
    }
    if ("deployed_version_id" in initData && initData["deployed_version_id"].isString) {
      deployedVersionId = UUID(initData["deployed_version_id"].get!string);
    }
    if ("status" in initData && initData["status"].isString) {
      status = toLower(initData["status"].get!string);
    }

    return true;
  }

  override Json toJson() {
    return super.toJson()
      .set("instance_id", instanceId.toJson)
      .set("app_id", appId.toJson)
      .set("target_environment", targetEnvironment)
      .set("deployed_version_id", deployedVersionId.toJson)
      .set("status", status);
  }

  static AGTRuntimeInstance opCall(UUID tenantId, Json request) {
    AGTRuntimeInstance instance = new AGTRuntimeInstance(request);
    instance.tenantId = tenantId;
    instance.instanceId = randomUUID();
    instance.targetEnvironment = "prod";
    instance.updatedAt = Clock.currTime();

    return instance;
  }
}
