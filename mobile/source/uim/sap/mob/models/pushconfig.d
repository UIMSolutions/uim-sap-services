module uim.sap.mob.models.pushconfig;

import uim.sap.mob;

mixin(ShowModule!());

@safe:

/// Push notification configuration per application
struct MOBPushConfig {
  UUID appId;
  bool enabled;
  MOBPushProvider provider = MOBPushProvider.FCM;
  string serverKey; // FCM server key or APNs certificate ref
  UUID senderId; // FCM sender ID
  UUID apnsTeamId;
  UUID apnsKeyId;
  UUID apnsBundleId;
  bool sandbox; // use APNs sandbox environment
  SysTime createdAt;
  SysTime updatedAt;

  override Json toJson() {
    return super.toJson()
      .set("app_id", appId)
      .set("enabled", enabled)
      .set("provider", cast(string)provider)
      .set("sender_id", senderId)
      .set("sandbox", sandbox)
      .set("created_at", createdAt.toISOExtString())
      .set("updated_at", updatedAt.toISOExtString())
      .set("server_key_set", serverKey.length > 0) // Omit sensitive keys from default serialization
      .set("apns_team_id", apnsTeamId)
      .set("apns_key_id", apnsKeyId)
      .set("apns_bundle_id", apnsBundleId);
  }
}

MOBPushConfig pushConfigFromJson(string appId, Json req) {
  MOBPushConfig pc;
  pc.appId = appId;
  pc.createdAt = Clock.currTime();
  pc.updatedAt = pc.createdAt;

  if ("enabled" in req && req["enabled"].isBoolean)
    pc.enabled = req["enabled"].get!bool;
  if ("provider" in req && req["provider"].isString)
    pc.provider = parsePushProvider(req["provider"].get!string);
  if ("server_key" in req && req["server_key"].isString)
    pc.serverKey = req["server_key"].getString;
  if ("sender_id" in req && req["sender_id"].isString)
    pc.senderId = req["sender_id"].getString;
  if ("apns_team_id" in req && req["apns_team_id"].isString)
    pc.apnsTeamId = req["apns_team_id"].getString;
  if ("apns_key_id" in req && req["apns_key_id"].isString)
    pc.apnsKeyId = req["apns_key_id"].getString;
  if ("apns_bundle_id" in req && req["apns_bundle_id"].isString)
    pc.apnsBundleId = req["apns_bundle_id"].getString;
  if ("sandbox" in req && req["sandbox"].isBoolean)
    pc.sandbox = req["sandbox"].get!bool;
  return pc;
}
