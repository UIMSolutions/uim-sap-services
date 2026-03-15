module uim.sap.agentry.models.device;

struct AgentryDevice {
  string tenantId;
  string deviceId;
  string appId;
  string userId;
  string platform;
  string appVersionId;
  SysTime lastSyncAt;

  Json toJson() const {
    Json result = Json.emptyObject;
    result["tenant_id"] = tenantId;
    result["device_id"] = deviceId;
    result["app_id"] = appId;
    result["user_id"] = userId;
    result["platform"] = platform;
    result["app_version_id"] = appVersionId;
    result["last_sync_at"] = lastSyncAt.toISOExtString();
    return result;
  }
}

AgentryDevice deviceFromJson(string tenantId, Json request) {
  AgentryDevice device;
  device.tenantId = tenantId;
  device.deviceId = randomUUID().toString();
  device.platform = "ios";
  device.lastSyncAt = Clock.currTime();

  if ("device_id" in request && request["device_id"].isString) {
    device.deviceId = request["device_id"].get!string;
  }
  if ("app_id" in request && request["app_id"].isString) {
    device.appId = request["app_id"].get!string;
  }
  if ("user_id" in request && request["user_id"].isString) {
    device.userId = request["user_id"].get!string;
  }
  if ("platform" in request && request["platform"].isString) {
    device.platform = toLower(request["platform"].get!string);
  }
  if ("app_version_id" in request && request["app_version_id"].isString) {
    device.appVersionId = request["app_version_id"].get!string;
  }

  return device;
}