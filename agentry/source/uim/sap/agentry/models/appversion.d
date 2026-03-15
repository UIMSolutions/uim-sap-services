module uim.sap.agentry.models.appversion;

struct AgentryAppVersion {
  UUID tenantId;
  UUID appId;
  UUID versionId;
  string versionLabel;
  string changeLog;
  string buildStatus = "built";
  SysTime createdAt;

  override Json toJson()  {
    Json result = Json.emptyObject;
    result["tenant_id"] = tenantId;
    result["app_id"] = appId;
    result["version_id"] = versionId;
    result["version_label"] = versionLabel;
    result["change_log"] = changeLog;
    result["build_status"] = buildStatus;
    result["created_at"] = createdAt.toISOExtString();
    return result;
  }
}

AgentryAppVersion versionFromJson(string tenantId, string appId, Json request) {
  AgentryAppVersion appVersion = new AgentryAppVersion;
  appVersion.tenantId = UUID(tenantId);
  appVersion.appId = appId;
  appVersion.versionId = randomUUID().toString();
  appVersion.versionLabel = "1.0.0";
  appVersion.createdAt = Clock.currTime();

  if ("version_id" in request && request["version_id"].isString) {
    appVersion.versionId = request["version_id"].get!string;
  }
  if ("version_label" in request && request["version_label"].isString) {
    appVersion.versionLabel = request["version_label"].get!string;
  }
  if ("change_log" in request && request["change_log"].isString) {
    appVersion.changeLog = request["change_log"].get!string;
  }
  if ("build_status" in request && request["build_status"].isString) {
    appVersion.buildStatus = toLower(request["build_status"].get!string);
  }

  return appVersion;
}
