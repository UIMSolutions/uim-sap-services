module uim.sap.servicemanager.models.serviceinstance;

struct SVMServiceInstance {
  UUID tenantId;
  UUID instanceId;
  string offeringName;
  string planName;
  string environmentId;
  string platformId;
  string status;
  string sharedFromEnvironment;
  string[] sharedToEnvironments;
  SysTime createdAt;
  SysTime updatedAt;

  override Json toJson()  {
    Json shares = Json.emptyArray;
    foreach (envId; sharedToEnvironments) {
      shares ~= envId;
    }

    return super.toJson
      .set("tenant_id", tenantId)
      .set("instance_id", instanceId)
      .set("offering_name", offeringName)
      .set("plan_name", planName)
      .set("environment_id", environmentId)
      .set("platform_id", platformId)
      .set("status", status)
      .set("shared_from_environment", sharedFromEnvironment)
      .set("shared_to_environments", shares)
      .set("created_at", createdAt.toISOExtString())
      .set("updated_at", updatedAt.toISOExtString());
  }
}

SVMServiceInstance parseServiceInstance(UUID tenantId, Json request) {
  SVMServiceInstance instanceItem = new SVMServiceInstance(request);
  instanceItem.tenantId = tenantId;
  instanceItem.instanceId = request.getString("instance_id", createId());
  instanceItem.offeringName = request.getString("offering_name", "");
  instanceItem.planName = request.getString("plan_name", "");
  instanceItem.environmentId = request.getString("environment_id", "");
  instanceItem.platformId = request.getString("platform_id", "");
  instanceItem.status = request.getString("status", "provisioned");
  instanceItem.sharedFromEnvironment = request.getString("shared_from_environment", "");
  instanceItem.createdAt = Clock.currTime();
  instanceItem.updatedAt = instanceItem.createdAt;

  if ("shared_to_environments" in request && request["shared_to_environments"].isArray) {
    foreach (item; request["shared_to_environments"].toArray) {
      if (item.isString) {
        auto value = item.getString;
        if (value.length > 0) {
          instanceItem.sharedToEnvironments ~= value;
        }
      }
    }
  }

  return instanceItem;
}