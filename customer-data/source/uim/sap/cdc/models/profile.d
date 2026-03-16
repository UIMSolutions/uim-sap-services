module uim.sap.cdc.models.profile;

import uim.sap.cdc;

mixin(ShowModule!());

@safe:


class CDCProfile : SAPTenantObject {
  mixin(SAPObjectTemplate!CDCProfile);

  UUID userId;
  string email;
  string phone;
  string firstName;
  string lastName;
  string region;
  UUID siteGroupId;
  string passwordSecret;
  bool active = true;
  bool emailVerified = false;
  Json preferences;
  Json customAttributes;
  size_t failedLoginAttempts;
  bool hasLockedUntil;
  SysTime lockedUntil;

  override Json toJson()  {
    return super.toJson
      .set("user_id", userId)
      .set("email", email)
      .set("phone", phone)
      .set("first_name", firstName)
      .set("last_name", lastName)
      .set("region", region)
      .set("site_group_id", siteGroupId)
      .set("active", active)
      .set("email_verified", emailVerified)
      .set("preferences", preferences)
      .set("custom_attributes", customAttributes)
      .set("failed_login_attempts", cast(long)failedLoginAttempts)
      .set("locked_until", hasLockedUntil ? lockedUntil.toISOExtString() : null);
  }
}
