module uim.sap.mob.models.usagereport;

import uim.sap.mob;

mixin(ShowModule!());

@safe:

/// Usage analytics report for an application
struct MOBUsageReport {
  string appId;
  size_t totalUsers;
  size_t activeUsers;
  size_t lockedUsers;
  size_t wipedUsers;
  size_t totalSessions;
  size_t totalPushSent;
  size_t totalPushDelivered;
  size_t totalPushFailed;
  size_t totalVersions;
  string activeVersion;
  size_t offlineSyncCount;

  override Json toJson() {
    return super.toJson()
      .set("app_id", appId)
      .set("total_users", cast(long)totalUsers)
      .set("active_users", cast(long)activeUsers)
      .set("locked_users", cast(long)lockedUsers)
      .set("wiped_users", cast(long)wipedUsers)
      .set("total_sessions", cast(long)totalSessions)
      .set("total_push_sent", cast(long)totalPushSent)
      .set("total_push_delivered", cast(long)totalPushDelivered)
      .set("total_push_failed", cast(long)totalPushFailed)
      .set("total_versions", cast(long)totalVersions)
      .set("active_version", activeVersion)
      .set("offline_sync_count", cast(long)offlineSyncCount);
  }
}

/// Global metrics across all apps
struct MOBGlobalMetrics {
  size_t totalApplications;
  size_t activeApplications;
  size_t totalUsers;
  size_t totalPushSent;
  size_t totalVersions;

  override Json toJson() {
    return super.toJson()
      .set("total_applications", cast(long)totalApplications)
      .set("active_applications", cast(long)activeApplications)
      .set("total_users", cast(long)totalUsers)
      .set("total_push_sent", cast(long)totalPushSent)
      .set("total_versions", cast(long)totalVersions);
  }
}
