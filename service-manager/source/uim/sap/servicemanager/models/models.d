module uim.sap.servicemanager.models.models;

import std.datetime : Clock, SysTime;

import uim.sap.servicemanager;

mixin(ShowModule!());

@safe:

struct SVMPlatform {
  UUID tenantId;
  string platformId;
  string name;
  string runtimeType;
  string apiEndpoint;
  string status;
  SysTime createdAt;

  Json toJson() const {
    Json payload = Json.emptyObject;
    payload["tenant_id"] = tenantId;
    payload["platform_id"] = platformId;
    payload["name"] = name;
    payload["runtime_type"] = runtimeType;
    payload["api_endpoint"] = apiEndpoint;
    payload["status"] = status;
    payload["created_at"] = createdAt.toISOExtString();
    return payload;
  }
}

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

  Json toJson() const {
    Json shares = Json.emptyArray;
    foreach (envId; sharedToEnvironments) {
      shares ~= envId;
    }

    Json payload = Json.emptyObject;
    payload["tenant_id"] = tenantId;
    payload["instance_id"] = instanceId;
    payload["offering_name"] = offeringName;
    payload["plan_name"] = planName;
    payload["environment_id"] = environmentId;
    payload["platform_id"] = platformId;
    payload["status"] = status;
    payload["shared_from_environment"] = sharedFromEnvironment;
    payload["shared_to_environments"] = shares;
    payload["created_at"] = createdAt.toISOExtString();
    payload["updated_at"] = updatedAt.toISOExtString();
    return payload;
  }
}

struct SVMServiceBinding {
  UUID tenantId;
  string bindingId;
  UUID instanceId;
  string name;
  string environmentId;
  string credentialsRef;
  SysTime createdAt;

  Json toJson() const {
    Json payload = Json.emptyObject;
    payload["tenant_id"] = tenantId;
    payload["binding_id"] = bindingId;
    payload["instance_id"] = instanceId;
    payload["name"] = name;
    payload["environment_id"] = environmentId;
    payload["credentials_ref"] = credentialsRef;
    payload["created_at"] = createdAt.toISOExtString();
    return payload;
  }
}

SVMPlatform parsePlatform(string tenantId, Json request) {
  SVMPlatform platform;
  platform.tenantId = tenantId;
  platform.platformId = request.getString("platform_id", createId());
  platform.name = request.getString("name", "");
  platform.runtimeType = request.getString("runtime_type", "kubernetes");
  platform.apiEndpoint = request.getString("api_endpoint", "");
  platform.status = request.getString("status", "connected");
  platform.createdAt = Clock.currTime();
  return platform;
}

SVMServiceInstance parseServiceInstance(string tenantId, Json request) {
  SVMServiceInstance instanceItem;
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
        auto value = item.get!string;
        if (value.length > 0) {
          instanceItem.sharedToEnvironments ~= value;
        }
      }
    }
  }

  return instanceItem;
}

SVMServiceBinding parseServiceBinding(string tenantId, Json request) {
  SVMServiceBinding binding;
  binding.tenantId = tenantId;
  binding.bindingId = request.getString("binding_id", createId());
  binding.instanceId = request.getString("instance_id", "");
  binding.name = request.getString("name", "");
  binding.environmentId = request.getString("environment_id", "");
  binding.credentialsRef = request.getString("credentials_ref", "secret://" ~ binding.bindingId);
  binding.createdAt = Clock.currTime();
  return binding;
}
