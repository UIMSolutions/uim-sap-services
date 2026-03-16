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
  mixin(SAPObjectTemplate!AGTDevice);

  UUID deviceId;
  UUID appId;
  UUID userId;
  string platform;
  UUID appVersionId;
  SysTime lastSyncAt;

  override Json toJson() {
    Json result = super.toJson;

    result["device_id"] = deviceId.toJson;
    result["app_id"] = appId.toJson;
    result["user_id"] = userId.toJson;
    result["platform"] = platform.toJson;
    result["app_version_id"] = appVersionId.toJson;
    result["last_sync_at"] = lastSyncAt.toISOExtString().toJson;

    return result;
  }

  static AGTDevice opCall(string tenantId, Json request) {
    AGTDevice device = new AGTDevice(request);
    device.tenantId = UUID(tenantId);
    device.deviceId = randomUUID();
    device.platform = "ios";
    device.lastSyncAt = Clock.currTime();

  if ("device_id" in request && request["device_id"].isString) {
    device.deviceId = UUID(request["device_id"].get!string);
  }
  if ("app_id" in request && request["app_id"].isString) {
    device.appId = UUID(request["app_id"].get!string);
  }
  if ("user_id" in request && request["user_id"].isString) {
    device.userId = UUID(request["user_id"].get!string);
  }
  if ("platform" in request && request["platform"].isString) {
    device.platform = toLower(request["platform"].get!string);
  }
  if ("app_version_id" in request && request["app_version_id"].isString) {
    device.appVersionId = UUID(request["app_version_id"].get!string);
  }

  return device;
}
}


