module uim.sap.mob.models.userconnection;
import uim.sap.mob;

mixin(ShowModule!());

@safe:

/// User connection to a mobile application
struct MOBUserConnection {
  string userId;
  string appId;
  MOBConnectionStatus status = MOBConnectionStatus.ACTIVE;
  string deviceId;
  string deviceModel;
  string osVersion;
  string appVersion;
  MOBPlatform platform = MOBPlatform.IOS;
  string pushToken; // device push token
  SysTime lastAccessAt;
  SysTime registeredAt;
  size_t sessionCount;

  override Json toJson() {
    return super.toJson()
      .set("user_id", userId)
      .set("app_id", appId)
      .set("status", cast(string)status)
      .set("device_id", deviceId)
      .set("device_model", deviceModel)
      .set("os_version", osVersion)
      .set("app_version", appVersion)
      .set("platform", cast(string)platform)
      .set("last_access_at", lastAccessAt.toISOExtString())
      .set("registered_at", registeredAt.toISOExtString())
      .set("session_count", cast(long)sessionCount);
  }
}

MOBUserConnection userConnectionFromJson(string appId, string userId, Json req) {
  MOBUserConnection uc;
  uc.userId = userId;
  uc.appId = appId;
  uc.registeredAt = Clock.currTime();
  uc.lastAccessAt = uc.registeredAt;

  if ("device_id" in req && req["device_id"].isString)
    uc.deviceId = req["device_id"].getString;
  if ("device_model" in req && req["device_model"].isString)
    uc.deviceModel = req["device_model"].getString;
  if ("os_version" in req && req["os_version"].isString)
    uc.osVersion = req["os_version"].getString;
  if ("app_version" in req && req["app_version"].isString)
    uc.appVersion = req["app_version"].getString;
  if ("platform" in req && req["platform"].isString)
    uc.platform = parsePlatform(req["platform"].get!string);
  if ("push_token" in req && req["push_token"].isString)
    uc.pushToken = req["push_token"].getString;
  return uc;
}
