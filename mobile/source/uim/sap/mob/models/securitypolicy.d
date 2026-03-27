module uim.sap.mob.models.securitypolicy;

import uim.sap.mob;

mixin(ShowModule!());

@safe:

/// Security policy for a mobile application
struct MOBSecurityPolicy {
  string appId;
  MOBAuthType authType = MOBAuthType.OAUTH2;
  bool passcodeEnabled;
  size_t passcodeMinLength = 8;
  size_t passcodeExpiryDays = 90;
  size_t maxFailedAttempts = 5;
  bool biometricEnabled;
  bool jailbreakDetection = true;
  bool dataEncryption = true;
  bool certificatePinning;
  string[] allowedDomains;
  size_t sessionTimeoutMins = 30;
  bool offlineAccessAllowed = true;
  SysTime createdAt;
  SysTime updatedAt;

  override Json toJson() {
    Json domains = Json.emptyArray;
    foreach (d; allowedDomains)
      domains.appendArrayElement(Json(d));

    return super.toJson()
      .set("app_id", appId)
      .set("auth_type", cast(string)authType)
      .set("passcode_enabled", passcodeEnabled)
      .set("passcode_min_length", cast(long)passcodeMinLength)
      .set("passcode_expiry_days", cast(long)passcodeExpiryDays)
      .set("max_failed_attempts", cast(long)maxFailedAttempts)
      .set("biometric_enabled", biometricEnabled)
      .set("jailbreak_detection", jailbreakDetection)
      .set("data_encryption", dataEncryption)
      .set("certificate_pinning", certificatePinning)
      .set("allowed_domains", domains)
      .set("session_timeout_mins", cast(long)sessionTimeoutMins)
      .set("offline_access_allowed", offlineAccessAllowed)
      .set("created_at", createdAt.toISOExtString())
      .set("updated_at", updatedAt.toISOExtString());
  }
}

MOBSecurityPolicy securityPolicyFromJson(string appId, Json req) {
  MOBSecurityPolicy sp;
  sp.appId = appId;
  sp.createdAt = Clock.currTime();
  sp.updatedAt = sp.createdAt;

  if ("auth_type" in req && req["auth_type"].isString)
    sp.authType = parseAuthType(req["auth_type"].get!string);
  if ("passcode_enabled" in req && req["passcode_enabled"].isBoolean)
    sp.passcodeEnabled = req["passcode_enabled"].get!bool;
  if ("passcode_min_length" in req && req["passcode_min_length"].isInteger)
    sp.passcodeMinLength = cast(size_t)req["passcode_min_length"].get!long;
  if ("passcode_expiry_days" in req && req["passcode_expiry_days"].isInteger)
    sp.passcodeExpiryDays = cast(size_t)req["passcode_expiry_days"].get!long;
  if ("max_failed_attempts" in req && req["max_failed_attempts"].isInteger)
    sp.maxFailedAttempts = cast(size_t)req["max_failed_attempts"].get!long;
  if ("biometric_enabled" in req && req["biometric_enabled"].isBoolean)
    sp.biometricEnabled = req["biometric_enabled"].get!bool;
  if ("jailbreak_detection" in req && req["jailbreak_detection"].isBoolean)
    sp.jailbreakDetection = req["jailbreak_detection"].get!bool;
  if ("data_encryption" in req && req["data_encryption"].isBoolean)
    sp.dataEncryption = req["data_encryption"].get!bool;
  if ("certificate_pinning" in req && req["certificate_pinning"].isBoolean)
    sp.certificatePinning = req["certificate_pinning"].get!bool;
  if ("allowed_domains" in req && req["allowed_domains"].isArray) {
    foreach (v; req["allowed_domains"])
      if (v.isString)
        sp.allowedDomains ~= v.getString;
  }
  if ("session_timeout_mins" in req && req["session_timeout_mins"].isInteger)
    sp.sessionTimeoutMins = cast(size_t)req["session_timeout_mins"].get!long;
  if ("offline_access_allowed" in req && req["offline_access_allowed"].isBoolean)
    sp.offlineAccessAllowed = req["offline_access_allowed"].get!bool;
  return sp;
}
