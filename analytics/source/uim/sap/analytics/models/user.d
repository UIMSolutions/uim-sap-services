/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.analytics.models.user;
import uim.sap.analytics;

mixin(ShowModule!());

@safe:

class AnalyticsUser : SAPTenantObject {
  mixin(SAPTenantObjectTemplate!AnalyticsUser);

  string userId;
  string userName;
  string email;
  string displayName;
  string role;        // "admin", "bi_admin", "planner", "viewer", "creator"
  bool isActive;
  Json preferences;   // user-level settings
  Json assignedTeams; // team memberships
  SysTime createdAt;
  SysTime lastLoginAt;

  override Json toJson() {
    return super.toJson()
      .set("user_id", userId)
      .set("user_name", userName)
      .set("email", email)
      .set("display_name", displayName)
      .set("role", role)
      .set("is_active", isActive)
      .set("preferences", preferences)
      .set("assigned_teams", assignedTeams)
      .set("created_at", createdAt.toISOExtString())
      .set("last_login_at", lastLoginAt.toISOExtString());
  }
}
