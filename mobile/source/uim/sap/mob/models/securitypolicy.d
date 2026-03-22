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

  override Json toJson()  {
    return super.toJson()
    j["app_id"] = appId;
    j["auth_type"] = cast(string)authType;
    j["passcode_enabled"] = passcodeEnabled;
    j["passcode_min_length"] = cast(long)passcodeMinLength;
    j["passcode_expiry_days"] = cast(long)passcodeExpiryDays;
    j["max_failed_attempts"] = cast(long)maxFailedAttempts;
    j["biometric_enabled"] = biometricEnabled;
    j["jailbreak_detection"] = jailbreakDetection;
    j["data_encryption"] = dataEncryption;
    j["certificate_pinning"] = certificatePinning;
    Json domains = Json.emptyArray;
    foreach (d; allowedDomains)
      domains.appendArrayElement(Json(d));
    j["allowed_domains"] = domains;
    j["session_timeout_mins"] = cast(long)sessionTimeoutMins;
    j["offline_access_allowed"] = offlineAccessAllowed;
    j["created_at"] = createdAt.toISOExtString();
    j["updated_at"] = updatedAt.toISOExtString();
    return j;
  }
}

MOBSecurityPolicy securityPolicyFromJson(string appId, Json req) {
  MOBSecurityPolicy sp;
  sp.appId = appId;
  sp.createdAt = Clock.currTime();
  sp.updatedAt = sp.createdAt;

  if ("auth_type" in req && req["auth_type"].isString)
    sp.authType = parseAuthType(req["auth_type"].get!string);
  if ("passcode_enabled" in req && req["passcode_enabled"].type == Json.Type.bool_)
    sp.passcodeEnabled = req["passcode_enabled"].get!bool;
  if ("passcode_min_length" in req && req["passcode_min_length"].isInteger)
    sp.passcodeMinLength = cast(size_t)req["passcode_min_length"].get!long;
  if ("passcode_expiry_days" in req && req["passcode_expiry_days"].isInteger)
    sp.passcodeExpiryDays = cast(size_t)req["passcode_expiry_days"].get!long;
  if ("max_failed_attempts" in req && req["max_failed_attempts"].isInteger)
    sp.maxFailedAttempts = cast(size_t)req["max_failed_attempts"].get!long;
  if ("biometric_enabled" in req && req["biometric_enabled"].type == Json.Type.bool_)
    sp.biometricEnabled = req["biometric_enabled"].get!bool;
  if ("jailbreak_detection" in req && req["jailbreak_detection"].type == Json.Type.bool_)
    sp.jailbreakDetection = req["jailbreak_detection"].get!bool;
  if ("data_encryption" in req && req["data_encryption"].type == Json.Type.bool_)
    sp.dataEncryption = req["data_encryption"].get!bool;
  if ("certificate_pinning" in req && req["certificate_pinning"].type == Json.Type.bool_)
    sp.certificatePinning = req["certificate_pinning"].get!bool;
  if ("allowed_domains" in req && req["allowed_domains"].type == Json.Type.array) {
    foreach (v; req["allowed_domains"])
      if (v.isString)
        sp.allowedDomains ~= v.get!string;
  }
  if ("session_timeout_mins" in req && req["session_timeout_mins"].isInteger)
    sp.sessionTimeoutMins = cast(size_t)req["session_timeout_mins"].get!long;
  if ("offline_access_allowed" in req && req["offline_access_allowed"].type == Json.Type.bool_)
    sp.offlineAccessAllowed = req["offline_access_allowed"].get!bool;
  return sp;
}
