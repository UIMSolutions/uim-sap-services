/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.agentry.models.device;
import uim.sap.agentry;

mixin(ShowModule!());

@safe:
class AGTDevice : SAPTenantObject {
  mixin(SAPTenantObjectTemplate!AGTDevice);

  override bool initialize(Json[string] initData) {
    if (!super.initialize(initData)) {
      return false;
    } 

    if ("device_id" in initData && initData["device_id"].isString) {
      deviceId = UUID(initData["device_id"].get!string);
    }
    if ("app_id" in initData && initData["app_id"].isString) {
      appId = UUID(initData["app_id"].get!string);
    }
    if ("user_id" in initData && initData["user_id"].isString) {
      userId = UUID(initData["user_id"].get!string);
    }
    if ("platform" in initData && initData["platform"].isString) {
      platform = toLower(initData["platform"].get!string);
    }
    if ("app_version_id" in initData && initData["app_version_id"].isString) {
      appVersionId = UUID(initData["app_version_id"].get!string);
    }

    return true;
  }

  UUID deviceId;
  UUID appId;
  UUID userId;
  string platform;
  UUID appVersionId;
  SysTime lastSyncAt;

  override Json toJson() {
    return super.toJson
      .set("device_id", deviceId.toJson)
      .set("app_id", appId.toJson)
      .set("user_id", userId.toJson)
      .set("platform", platform.toJson)
      .set("app_version_id", appVersionId.toJson)
      .set("last_sync_at", lastSyncAt.toISOExtString().toJson);
  }

  static AGTDevice opCall(UUID tenantId, Json request) {
    AGTDevice device = new AGTDevice(request);
    
    device.tenantId = tenantId;
    device.deviceId = randomUUID();
    device.platform = "ios";
    device.lastSyncAt = Clock.currTime();

    return device;
  }
}
