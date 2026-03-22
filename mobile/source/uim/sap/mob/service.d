module uim.sap.mob.service;

import uim.sap.mob;

mixin(ShowModule!());

@safe:

/**
 * Main service class for SAP Mobile Services.
 *
 * Manages mobile application lifecycle, push notifications,
 * offline data configuration, security policies, user connections,
 * app versions/updates, and usage analytics.
 */
class MOBService : SAPService {
  mixin(SAPServiceTemplate!MOBService);

  private MOBStore _store;
  private MOBConfig _config;

  this(MOBConfig config) {
    super(config);
    _store = new MOBStore;
  }

  override Json health() {
    Json info = super.health();
    auto m = _store.globalMetrics();
    info["applications"] = cast(long)m.totalApplications;
    info["users"] = cast(long)m.totalUsers;
    return info;
  }

  override Json ready() {
    Json info = super.ready();
    info["applications"] = cast(long)_store.appCount();
    return info;
  }

  Json getMetrics() {
    return _store.globalMetrics().toJson();
  }

  // ══════════════════════════════════════
  //  Applications
  // ══════════════════════════════════════

  Json createApp(string appId, Json request) {
    validateAppId(appId);
    if (_store.hasApp(appId))
      throw new MOBConflictException("Application", appId);
    if (_store.appCount() >= _config.maxApplications)
      throw new MOBQuotaExceededException("applications", _config.maxApplications);

    auto app = applicationFromJson(appId, request);
    _store.upsertApp(app);

    Json payload = Json.emptyObject;
    payload["success"] = true;
    payload["application"] = app.toJson();
    return payload;
  }

  Json updateApp(string appId, Json request) {
    requireApp(appId);
    auto existing = _store.getApp(appId);
    auto app = applicationFromJson(appId, request);
    app.createdAt = existing.createdAt;
    app.updatedAt = Clock.currTime();
    app.activeVersion = existing.activeVersion;
    _store.upsertApp(app);

    Json payload = Json.emptyObject;
    payload["success"] = true;
    payload["application"] = app.toJson();
    return payload;
  }

  Json getApp(string appId) {
    requireApp(appId);
    auto app = _store.getApp(appId);

    Json payload = Json.emptyObject;
    payload["application"] = app.toJson();
    payload["user_count"] = cast(long)_store.userCount(appId);
    payload["version_count"] = cast(long)_store.versionCount(appId);
    payload["push_configured"] = _store.hasPushConfig(appId);
    payload["offline_configured"] = _store.hasOfflineConfig(appId);
    return payload;
  }

  Json listApps() {
    auto apps = _store.listApps();
    Json resources = Json.emptyArray;
    foreach (ref app; apps)
      resources.appendArrayElement(app.toJson());

    Json payload = Json.emptyObject;
    payload["resources"] = resources;
    payload["total_results"] = cast(long)apps.length;
    return payload;
  }

  Json deleteApp(string appId) {
    if (!_store.deleteApp(appId))
      throw new MOBNotFoundException("Application", appId);

    return Json.emptyObject
      .set("success", true)
      .set("message", "Application and all related resources deleted")
      .set("app_id", appId);
  }

  // ══════════════════════════════════════
  //  App Versions / Updates
  // ══════════════════════════════════════

  Json createVersion(string appId, string versionId, Json request) {
    requireApp(appId);
    if (_store.getVersion(appId, versionId).versionId.length > 0)
      throw new MOBConflictException("Version", versionId);
    if (_store.versionCount(appId) >= _config.maxVersionsPerApp)
      throw new MOBQuotaExceededException("versions for app " ~ appId, _config.maxVersionsPerApp);

    auto ver = appVersionFromJson(appId, versionId, request);
    _store.upsertVersion(ver);

    return Json.emptyObject
      .set("success", true)
      .set("version", ver.toJson());
  }

  Json getVersion(string appId, string versionId) {
    requireApp(appId);
    auto ver = _store.getVersion(appId, versionId);
    if (ver.versionId.length == 0)
      throw new MOBNotFoundException("Version", versionId);

    Json payload = Json.emptyObject;
    payload["version"] = ver.toJson();
    return payload;
  }

  Json listVersions(string appId) {
    requireApp(appId);
    auto vers = _store.listVersions(appId);
    Json resources = Json.emptyArray;
    foreach (ref v; vers)
      resources.appendArrayElement(v.toJson());

    return Json.emptyObject
      .set("resources", resources)
      .set("total_results", cast(long)vers.length);
  }

  Json deleteVersion(string appId, string versionId) {
    requireApp(appId);
    if (!_store.deleteVersion(appId, versionId))
      throw new MOBNotFoundException("Version", versionId);

    return Json.emptyObject
      .set("success", true)
      .set("message", "Version deleted")
      .set("app_id", appId)
      .set("version_id", versionId);
  }

  Json activateVersion(string appId, string versionId) {
    requireApp(appId);
    auto ver = _store.getVersion(appId, versionId);
    if (ver.versionId.length == 0)
      throw new MOBNotFoundException("Version", versionId);

    ver.status = MOBVersionStatus.ACTIVE;
    ver.activatedAt = Clock.currTime();
    _store.upsertVersion(ver);

    // Update the app's active version
    auto app = _store.getApp(appId);
    app.activeVersion = versionId;
    app.updatedAt = Clock.currTime();
    _store.upsertApp(app);

    // Deprecate previous active versions
    auto allVersions = _store.listVersions(appId);
    foreach (ref v; allVersions) {
      if (v.versionId != versionId && v.status == MOBVersionStatus.ACTIVE) {
        v.status = MOBVersionStatus.DEPRECATED;
        _store.upsertVersion(v);
      }
    }

    return Json.emptyObject
      .set("success", true)
      .set("message", "Version activated")
      .set("version", ver.toJson());
  }

  // ══════════════════════════════════════
  //  Push Configuration & Notifications
  // ══════════════════════════════════════

  Json setPushConfig(string appId, Json request) {
    requireApp(appId);
    auto existing = _store.getPushConfig(appId);
    auto pc = pushConfigFromJson(appId, request);
    if (existing.appId.length > 0)
      pc.createdAt = existing.createdAt;
    pc.updatedAt = Clock.currTime();
    _store.upsertPushConfig(pc);

    return Json.emptyObject
      .set("success", true)
      .set("push_config", pc.toJson());
  }

  Json getPushConfig(string appId) {
    requireApp(appId);
    if (!_store.hasPushConfig(appId))
      throw new MOBNotFoundException("Push configuration", appId);

    return Json.emptyObject
      .set("push_config", _store.getPushConfig(appId).toJson());
  }

  Json sendNotification(string appId, Json request) {
    requireApp(appId);
    if (!_store.hasPushConfig(appId))
      throw new MOBValidationException("Push not configured for app " ~ appId);

    auto pc = _store.getPushConfig(appId);
    if (!pc.enabled)
      throw new MOBValidationException("Push notifications are disabled for app " ~ appId);

    if (!("title" in request) || !request["title"].isString)
      throw new MOBValidationException("title (string) is required");

    auto n = notificationFromJson(appId, request);

    // Simulate delivery to connected users
    auto users = _store.listUsers(appId);
    foreach (ref u; users) {
      if (u.status == MOBConnectionStatus.ACTIVE && u.pushToken.length > 0) {
        if (n.targetUsers.length == 0 || isTargeted(u.userId, n.targetUsers))
          n.deliveredCount++;
      }
    }

    _store.recordNotification(n);

    return Json.emptyObject
      .set("success", true)
      .set("notification", n.toJson());
  }

  Json listNotifications(string appId) {
    requireApp(appId);
    auto notifs = _store.listNotifications(appId);
    Json resources = Json.emptyArray;
    foreach (ref n; notifs)
      resources.appendArrayElement(n.toJson());

    return Json.emptyObject
      .set("resources", resources)
      .set("total_results", cast(long)notifs.length);
  }

  // ══════════════════════════════════════
  //  Offline Configuration
  // ══════════════════════════════════════

  Json setOfflineConfig(string appId, Json request) {
    requireApp(appId);
    auto existing = _store.getOfflineConfig(appId);
    auto oc = offlineConfigFromJson(appId, request);
    if (existing.appId.length > 0)
      oc.createdAt = existing.createdAt;
    if (oc.syncIntervalSecs == 0)
      oc.syncIntervalSecs = _config.defaultSyncIntervalSecs;
    oc.updatedAt = Clock.currTime();
    _store.upsertOfflineConfig(oc);

    return Json.emptyObject
      .set("success", true)
      .set("offline_config", oc.toJson());
  }

  Json getOfflineConfig(string appId) {
    requireApp(appId);
    if (!_store.hasOfflineConfig(appId))
      throw new MOBNotFoundException("Offline configuration", appId);

    return Json.emptyObject
      .set("offline_config", _store.getOfflineConfig(appId).toJson());
  }

  // ══════════════════════════════════════
  //  Security Policies
  // ══════════════════════════════════════

  Json setSecurityPolicy(string appId, Json request) {
    requireApp(appId);
    auto existing = _store.getSecurityPolicy(appId);
    auto sp = securityPolicyFromJson(appId, request);
    if (existing.appId.length > 0)
      sp.createdAt = existing.createdAt;
    sp.updatedAt = Clock.currTime();
    _store.upsertSecurityPolicy(sp);

    return Json.emptyObject
      .set("success", true)
      .set("security_policy", sp.toJson());
  }

  Json getSecurityPolicy(string appId) {
    requireApp(appId);
    if (!_store.hasSecurityPolicy(appId))
      throw new MOBNotFoundException("Security policy", appId);

    return Json.emptyObject
      .set("security_policy", _store.getSecurityPolicy(appId).toJson());
  }

  // ══════════════════════════════════════
  //  User Management
  // ══════════════════════════════════════

  Json registerUser(string appId, string userId, Json request) {
    requireApp(appId);
    if (_store.getUser(appId, userId).userId.length > 0)
      throw new MOBConflictException("User connection", userId);
    if (_store.userCount(appId) >= _config.maxUsersPerApp)
      throw new MOBQuotaExceededException("users for app " ~ appId, _config.maxUsersPerApp);

    auto uc = userConnectionFromJson(appId, userId, request);
    _store.upsertUser(uc);

    return Json.emptyObject
      .set("success", true)
      .set("user", uc.toJson());
  }

  Json getUser(string appId, string userId) {
    requireApp(appId);
    auto uc = _store.getUser(appId, userId);
    if (uc.userId.length == 0)
      throw new MOBNotFoundException("User connection", userId);

    return Json.emptyObject
      .set("user", uc.toJson());
  }

  Json listUsers(string appId) {
    requireApp(appId);
    auto users = _store.listUsers(appId);
    Json resources = Json.emptyArray;
    foreach (ref u; users)
      resources.appendArrayElement(u.toJson());

    return Json.emptyObject
      .set("resources", resources)
      .set("total_results", cast(long)users.length);
  }

  Json lockUser(string appId, string userId) {
    requireApp(appId);
    auto uc = _store.getUser(appId, userId);
    if (uc.userId.length == 0)
      throw new MOBNotFoundException("User connection", userId);

    uc.status = MOBConnectionStatus.LOCKED;
    _store.upsertUser(uc);

    return Json.emptyObject
      .set("success", true)
      .set("message", "User locked")
      .set("user", uc.toJson());
  }

  Json unlockUser(string appId, string userId) {
    requireApp(appId);
    auto uc = _store.getUser(appId, userId);
    if (uc.userId.length == 0)
      throw new MOBNotFoundException("User connection", userId);

    uc.status = MOBConnectionStatus.ACTIVE;
    _store.upsertUser(uc);

    return Json.emptyObject
      .set("success", true)
      .set("message", "User unlocked")
      .set("user", uc.toJson());
  }

  Json wipeUser(string appId, string userId) {
    requireApp(appId);
    auto uc = _store.getUser(appId, userId);
    if (uc.userId.length == 0)
      throw new MOBNotFoundException("User connection", userId);

    uc.status = MOBConnectionStatus.WIPED;
    _store.upsertUser(uc);

    return Json.emptyObject
      .set("success", true)
      .set("message", "User data wiped")
      .set("user", uc.toJson());
  }

  Json deleteUser(string appId, string userId) {
    requireApp(appId);
    if (!_store.deleteUser(appId, userId))
      throw new MOBNotFoundException("User connection", userId);

    return Json.emptyObject
      .set("success", true)
      .set("message", "User connection deleted")
      .set("app_id", appId)
      .set("user_id", userId);
  }

  // ══════════════════════════════════════
  //  Usage Analytics
  // ══════════════════════════════════════

  Json getAppAnalytics(string appId) {
    requireApp(appId);
    return _store.appUsageReport(appId).toJson();
  }

  // ══════════════════════════════════════
  //  SDK Information
  // ══════════════════════════════════════

  Json listSdks() {
    Json resources = Json.emptyArray;

    Json mdk = Json.emptyObject
    mdk["type"] = "mdk";
    mdk["name"] = "Mobile Development Kit";
    mdk["description"] = "Cross-platform development using metadata-driven approach";
    mdk["platforms"] = jsonArray(["ios", "android", "web"]);
    mdk["latest_version"] = "23.12.0";
    resources.appendArrayElement(mdk);

    Json ios = Json.emptyObject;
    ios["type"] = "ios";
    ios["name"] = "SAP BTP SDK for iOS";
    ios["description"] = "Native iOS development with Swift and SwiftUI";
    ios["platforms"] = jsonArray(["ios"]);
    ios["latest_version"] = "10.2.0";
    resources.appendArrayElement(ios);

    Json android = Json.emptyObject;
    android["type"] = "android";
    android["name"] = "SAP BTP SDK for Android";
    android["description"] = "Native Android development with Kotlin and Jetpack Compose";
    android["platforms"] = jsonArray(["android"]);
    android["latest_version"] = "7.1.0";
    resources.appendArrayElement(android);

    Json payload = Json.emptyObject;
    payload["resources"] = resources;
    payload["total_results"] = 3;
    return payload;
  }

  Json getSdk(string sdkType) {
    auto sdks = listSdks();
    foreach (size_t i, ref sdk; sdks["resources"]) {
      if (sdk["type"].get!string == sdkType) {
        Json payload = Json.emptyObject;
        payload["sdk"] = sdk;
        return payload;
      }
    }
    throw new MOBNotFoundException("SDK", sdkType);
  }

  // ── Private helpers ──

  private void requireApp(string appId) {
    if (!_store.hasApp(appId))
      throw new MOBNotFoundException("Application", appId);
  }

  private void validateAppId(string appId) {
    if (!isValidAppId(appId))
      throw new MOBValidationException(
        "Invalid app ID '" ~ appId ~ "': must be alphanumeric with hyphens/dots/underscores, 1-253 chars"
      );
  }

  private static bool isTargeted(string userId, const string[] targets) {
    foreach (t; targets)
      if (t == userId)
        return true;
    return false;
  }

  private static Json jsonArray(string[] items) {
    Json arr = Json.emptyArray;
    foreach (s; items)
      arr.appendArrayElement(Json(s));
    return arr;
  }
}
