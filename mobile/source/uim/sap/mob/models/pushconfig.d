module uim.sap.mob.models.pushconfig;

import uim.sap.mob;

mixin(ShowModule!());

@safe:

/// Push notification configuration per application
struct MOBPushConfig {
  string appId;
  bool enabled;
  MOBPushProvider provider = MOBPushProvider.FCM;
  string serverKey; // FCM server key or APNs certificate ref
  string senderId; // FCM sender ID
  string apnsTeamId;
  string apnsKeyId;
  string apnsBundleId;
  bool sandbox; // use APNs sandbox environment
  SysTime createdAt;
  SysTime updatedAt;

  override Json toJson()  {
    return super.toJson()
    j["app_id"] = appId;
    j["enabled"] = enabled;
    j["provider"] = cast(string)provider;
    j["sender_id"] = senderId;
    j["sandbox"] = sandbox;
    j["created_at"] = createdAt.toISOExtString();
    j["updated_at"] = updatedAt.toISOExtString();
    // Omit sensitive keys from default serialization
    j["server_key_set"] = serverKey.length > 0;
    j["apns_team_id"] = apnsTeamId;
    j["apns_key_id"] = apnsKeyId;
    j["apns_bundle_id"] = apnsBundleId;
    return j;
  }
}

MOBPushConfig pushConfigFromJson(string appId, Json req) {
  MOBPushConfig pc;
  pc.appId = appId;
  pc.createdAt = Clock.currTime();
  pc.updatedAt = pc.createdAt;

  if ("enabled" in req && req["enabled"].type == Json.Type.bool_)
    pc.enabled = req["enabled"].get!bool;
  if ("provider" in req && req["provider"].isString)
    pc.provider = parsePushProvider(req["provider"].get!string);
  if ("server_key" in req && req["server_key"].isString)
    pc.serverKey = req["server_key"].get!string;
  if ("sender_id" in req && req["sender_id"].isString)
    pc.senderId = req["sender_id"].get!string;
  if ("apns_team_id" in req && req["apns_team_id"].isString)
    pc.apnsTeamId = req["apns_team_id"].get!string;
  if ("apns_key_id" in req && req["apns_key_id"].isString)
    pc.apnsKeyId = req["apns_key_id"].get!string;
  if ("apns_bundle_id" in req && req["apns_bundle_id"].isString)
    pc.apnsBundleId = req["apns_bundle_id"].get!string;
  if ("sandbox" in req && req["sandbox"].type == Json.Type.bool_)
    pc.sandbox = req["sandbox"].get!bool;
  return pc;
}
