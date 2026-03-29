/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.agentry.models.device;
import uim.sap.agentry;

mixin(ShowModule!());

@safe:
class AGTDevice : SAPTenantEntity {
  mixin(SAPTenantEntityTemplate!AGTDevice);

  override bool initialize(Json[string] initData) {
    if (!super.initialize(initData)) {
      return false;
    }

    deviceId = randomUUID();
    if ("device_id" in initData && initData["device_id"].isString) {
      deviceId = UUID(initData["device_id"].get!string);
    }

    if ("app_id" in initData && initData["app_id"].isString) {
      appId = UUID(initData["app_id"].get!string);
    }
    if ("user_id" in initData && initData["user_id"].isString) {
      userId = UUID(initData["user_id"].get!string);
    }

    platform = toLower(initData.getString("platform", "ios"));

    if ("app_version_id" in initData && initData["app_version_id"].isString) {
      appVersionId = UUID(initData["app_version_id"].get!string);
    }

    lastSyncAt = Clock.currTime();
    if ("last_sync_at" in initData && initData["last_sync_at"].isString) {
      lastSyncAt = Clock.parseTime(initData["last_sync_at"].get!string);
    }

    return true;
  }

  protected UUID _deviceId;
  @property UUID deviceId() {
    return _deviceId;
  }

  @property void deviceId(UUID value) {
    _deviceId = value;
  }

  protected UUID _appId;
  @property UUID appId() {
    return _appId;
  }

  @property void appId(UUID value) {
    _appId = value;
  }

  protected UUID _userId;
  @property UUID userId() {
    return _userId;
  }

  @property void userId(UUID value) {
    _userId = value;
  }

  protected string _platform;
  @property string platform() {
    return _platform;
  }

  @property void platform(string value) {
    _platform = value;
  }

  protected UUID _appVersionId;
  @property UUID appVersionId() {
    return _appVersionId;
  }

  @property void appVersionId(UUID value) {
    _appVersionId = value;
  }

  protected SysTime _lastSyncAt;
  @property SysTime lastSyncAt() {
    return _lastSyncAt;
  }

  @property void lastSyncAt(SysTime value) {
    _lastSyncAt = value;
  }

  override Json toJson() {
    return super.toJson
      .set("device_id", deviceId)
      .set("app_id", appId)
      .set("user_id", userId)
      .set("platform", platform)
      .set("app_version_id", appVersionId)
      .set("last_sync_at", lastSyncAt.toISOExtString());
  }
}
