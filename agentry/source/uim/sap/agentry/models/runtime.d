module uim.sap.agentry.models.runtime;

struct AgentryRuntimeInstance {
  string tenantId;
  string instanceId;
  string appId;
  string targetEnvironment;
  string deployedVersionId;
  string status = "running";
  SysTime updatedAt;

  Json toJson() const {
    Json result = Json.emptyObject;
    result["tenant_id"] = tenantId;
    result["instance_id"] = instanceId;
    result["app_id"] = appId;
    result["target_environment"] = targetEnvironment;
    result["deployed_version_id"] = deployedVersionId;
    result["status"] = status;
    result["updated_at"] = updatedAt.toISOExtString();
    return result;
  }
}

AgentryRuntimeInstance instanceFromJson(string tenantId, Json request) {
  AgentryRuntimeInstance instance;
  instance.tenantId = tenantId;
  instance.instanceId = randomUUID().toString();
  instance.targetEnvironment = "prod";
  instance.updatedAt = Clock.currTime();

  if ("instance_id" in request && request["instance_id"].isString) {
    instance.instanceId = request["instance_id"].get!string;
  }
  if ("app_id" in request && request["app_id"].isString) {
    instance.appId = request["app_id"].get!string;
  }
  if ("target_environment" in request && request["target_environment"].isString) {
    instance.targetEnvironment = request["target_environment"].get!string;
  }
  if ("deployed_version_id" in request && request["deployed_version_id"].isString) {
    instance.deployedVersionId = request["deployed_version_id"].get!string;
  }
  if ("status" in request && request["status"].isString) {
    instance.status = toLower(request["status"].get!string);
  }

  return instance;
}