/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.agentry.models.appversion;
import uim.sap.agentry;

mixin(ShowModule!());

@safe:
class AGTAppVersion : SAPTenantObject {
  mixin(SAPObjectTemplate!AGTAppVersion);

  UUID appId;
  UUID versionId;
  string versionLabel;
  string changeLog;
  string buildStatus = "built";
  SysTime createdAt;

  override Json toJson() {
    Json result = super.toJson;
    result["app_id"] = appId;
    result["version_id"] = versionId;
    result["version_label"] = versionLabel;
    result["change_log"] = changeLog;
    result["build_status"] = buildStatus;
    result["created_at"] = createdAt.toISOExtString();
    return result;
  }

  static AGTAppVersion opCall(string tenantId, string appId, Json request) {
    AGTAppVersion appVersion = new AGTAppVersion;
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
}
