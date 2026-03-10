module uim.sap.mob.models.usagereport;

import std.datetime : SysTime;

import vibe.data.json : Json;

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

    Json toJson() const {
        Json j = Json.emptyObject;
        j["app_id"] = appId;
        j["total_users"] = cast(long) totalUsers;
        j["active_users"] = cast(long) activeUsers;
        j["locked_users"] = cast(long) lockedUsers;
        j["wiped_users"] = cast(long) wipedUsers;
        j["total_sessions"] = cast(long) totalSessions;
        j["total_push_sent"] = cast(long) totalPushSent;
        j["total_push_delivered"] = cast(long) totalPushDelivered;
        j["total_push_failed"] = cast(long) totalPushFailed;
        j["total_versions"] = cast(long) totalVersions;
        j["active_version"] = activeVersion;
        j["offline_sync_count"] = cast(long) offlineSyncCount;
        return j;
    }
}

/// Global metrics across all apps
struct MOBGlobalMetrics {
    size_t totalApplications;
    size_t activeApplications;
    size_t totalUsers;
    size_t totalPushSent;
    size_t totalVersions;

    Json toJson() const {
        Json j = Json.emptyObject;
        j["total_applications"] = cast(long) totalApplications;
        j["active_applications"] = cast(long) activeApplications;
        j["total_users"] = cast(long) totalUsers;
        j["total_push_sent"] = cast(long) totalPushSent;
        j["total_versions"] = cast(long) totalVersions;
        return j;
    }
}
