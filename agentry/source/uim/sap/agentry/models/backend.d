module uim.sap.agentry.models.backend;

class AGTBackendSystem : SAPTenantObject {
  mixin(SAPObjectTemplate!AgentryBackendSystem);

  UUID backendId;
  string systemType;
  string endpoint;
  string authMode;
  bool enabled = true;
  SysTime updatedAt;

  override Json toJson()  {
    Json result = Json.emptyObject;
    result["tenant_id"] = tenantId;
    result["backend_id"] = backendId;
    result["system_type"] = systemType;
    result["endpoint"] = endpoint;
    result["auth_mode"] = authMode;
    result["enabled"] = enabled;
    result["updated_at"] = updatedAt.toISOExtString();
    return result;
  }
}

AgentryBackendSystem backendFromJson(string tenantId, Json request) {
  AgentryBackendSystem backend;
  backend.tenantId = UUID(tenantId);
  backend.backendId = randomUUID().toString();
  backend.systemType = "s4hana";
  backend.authMode = "oauth2";
  backend.updatedAt = Clock.currTime();

  if ("backend_id" in request && request["backend_id"].isString) {
    backend.backendId = request["backend_id"].get!string;
  }
  if ("system_type" in request && request["system_type"].isString) {
    backend.systemType = toLower(request["system_type"].get!string);
  }
  if ("endpoint" in request && request["endpoint"].isString) {
    backend.endpoint = request["endpoint"].get!string;
  }
  if ("auth_mode" in request && request["auth_mode"].isString) {
    backend.authMode = toLower(request["auth_mode"].get!string);
  }
  if ("enabled" in request && request["enabled"].isBoolean) {
    backend.enabled = request["enabled"].get!bool;
  }

  return backend;
}