module uim.sap.servicemanager.models.models;

import std.datetime : Clock, SysTime;

import uim.sap.servicemanager;

mixin(ShowModule!());

@safe:

class SVMPlatform : SAPTenantObject {
  mixin(SAPtenantObject!SVMPlatform);

  UUID platformId;
  string name;
  string runtimeType;
  string apiEndpoint;
  string status;

  override Json toJson()  {
    return super.toJson
    .set("platform_id", platformId)
    .set("name", name)
    .set("runtime_type", runtimeType)
    .set("api_endpoint", apiEndpoint)
    .set("status", status);
  }
}



SVMPlatform parsePlatform(UUID tenantId, Json request) {
  SVMPlatform platform = new SVMPlatform(request);
  platform.tenantId = tenantId;
  platform.platformId = request.getString("platform_id", createId());
  platform.name = request.getString("name", "");
  platform.runtimeType = request.getString("runtime_type", "kubernetes");
  platform.apiEndpoint = request.getString("api_endpoint", "");
  platform.status = request.getString("status", "connected");
  platform.createdAt = Clock.currTime();
  return platform;
}



SVMServiceBinding parseServiceBinding(UUID tenantId, Json request) {
  SVMServiceBinding binding = new SVMServiceBinding(request);
  binding.tenantId = tenantId;
  binding.bindingId = request.getString("binding_id", createId());
  binding.instanceId = request.getString("instance_id", "");
  binding.name = request.getString("name", "");
  binding.environmentId = request.getString("environment_id", "");
  binding.credentialsRef = request.getString("credentials_ref", "secret://" ~ binding.bindingId);
  binding.createdAt = Clock.currTime();
  return binding;
}
