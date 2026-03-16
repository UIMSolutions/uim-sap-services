module uim.sap.cdc.models.profile;

import uim.sap.cdc;

mixin(ShowModule!());

@safe:

struct CDCProfile {
  string tenantId;
  string userId;
  string email;
  string phone;
  string firstName;
  string lastName;
  string region;
  string siteGroupId;
  string passwordSecret;
  bool active = true;
  bool emailVerified = false;
  Json preferences;
  Json customAttributes;
  size_t failedLoginAttempts;
  bool hasLockedUntil;
  SysTime lockedUntil;
  SysTime createdAt;
  SysTime updatedAt;

  override Json toJson()  {
    Json info = super.toJson;
    payload["tenant_id"] = tenantId;
    payload["user_id"] = userId;
    payload["email"] = email;
    payload["phone"] = phone;
    payload["first_name"] = firstName;
    payload["last_name"] = lastName;
    payload["region"] = region;
    payload["site_group_id"] = siteGroupId;
    payload["active"] = active;
    payload["email_verified"] = emailVerified;
    payload["preferences"] = preferences;
    payload["custom_attributes"] = customAttributes;
    payload["failed_login_attempts"] = cast(long)failedLoginAttempts;
    payload["locked_until"] = hasLockedUntil ? lockedUntil.toISOExtString() : null;
    payload["created_at"] = createdAt.toISOExtString();
    payload["updated_at"] = updatedAt.toISOExtString();
    return payload;
  }
}
