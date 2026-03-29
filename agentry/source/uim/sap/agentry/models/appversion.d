/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.agentry.models.appversion;

import uim.sap.agentry;

mixin(ShowModule!());

@safe:

/**
  * Represents a specific version of a mobile application, including its version label, change log, and build status.
  *
  * This class is used to manage different versions of a mobile application within the Agentry platform, allowing for version tracking and deployment management.
  *
  * Properties:
  * - `versionId`: A unique identifier for the app version.
  * - `appId`: The identifier of the mobile application this version belongs to.
  * - `versionLabel`: A human-readable label for the version (e.g., "1.0.0").
  * - `changeLog`: A description of the changes included in this version.
  * - `buildStatus`: The current build status of the version (e.g., "built", "failed").
  * Methods:
  * - `initialize`: Initializes the app version object from a JSON input.
  * - `toJson`: Serializes the app version object to JSON format.
  */
class AGTAppVersion : SAPTenantEntity {
  mixin(SAPTenantEntityTemplate!AGTAppVersion);

  override bool initialize(Json[string] initData) {
    if (!super.initialize(initData)) {
      return false;
    }

    if ("app_id" in initData && initData["app_id"].isString) {
      appId = UUID(initData["app_id"].get!string);
    }

    versionId = randomUUID();
    if ("version_id" in initData && initData["version_id"].isString) {
      versionId = UUID(initData["version_id"].get!string);
    }
    if ("version_label" in initData && initData["version_label"].isString) {
      versionLabel = initData.getString("version_label", "1.0.0");
    }
    if ("change_log" in initData && initData["change_log"].isString) {
      changeLog = initData["change_log"].getString;
    }
    if ("build_status" in initData && initData["build_status"].isString) {
      buildStatus = toLower(initData["build_status"].get!string);
    }

    return true;
  }

  UUID versionId;
  UUID appId;
  string versionLabel;
  string changeLog;
  string buildStatus = "built";

  override Json toJson() {
    return super.toJson()
      .set("app_id", appId)
      .set("version_id", versionId)
      .set("version_label", versionLabel)
      .set("change_log", changeLog)
      .set("build_status", buildStatus);
  }

  static AGTAppVersion opCall(UUID tenantId, UUID appId, Json request) {
    AGTAppVersion appVersion = new AGTAppVersion(request);

    appVersion.tenantId = tenantId;
    appVersion.appId = UUID(appId);

    return appVersion;
  }
}
