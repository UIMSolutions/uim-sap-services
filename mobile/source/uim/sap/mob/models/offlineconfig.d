module uim.sap.mob.models.offlineconfig;

import uim.sap.mob;

mixin(ShowModule!());

@safe:

/// Offline/OData synchronization configuration per application
class MOBOfflineConfig : SAPObject {
  mixin(SAPObjectTemplate!MOBOfflineConfig);

  UUID appId;
  bool enabled;
  MOBSyncStrategy syncStrategy = MOBSyncStrategy.DELTA;
  size_t syncIntervalSecs = 300;
  string[] entitySets; // OData entity sets available offline
  size_t maxOfflineStoreMB = 50; // max local DB size
  bool encryptLocalStore = true;
  bool conflictDetection = true;
  string odataServiceUrl; // e.g. /sap/opu/odata/…
  SysTime createdAt;
  SysTime updatedAt;

  override Json toJson() {
    Json es = Json.emptyArray;
    foreach (e; entitySets)
      es.appendArrayElement(Json(e));

    return super.toJson()
      .set("app_id", appId)
      .set("enabled", enabled)
      .set("sync_strategy", cast(string)syncStrategy)
      .set("sync_interval_secs", cast(long)syncIntervalSecs)
      .set("entity_sets", es)
      .set("max_offline_store_mb", cast(long)maxOfflineStoreMB)
      .set("encrypt_local_store", encryptLocalStore)
      .set("conflict_detection", conflictDetection)
      .set("odata_service_url", odataServiceUrl);
  }

  static MOBOfflineConfig opCall(string appId, Json req) {
  MOBOfflineConfig oc = new MOBOfflineConfig();
  oc.appId = appId;
  oc.createdAt = Clock.currTime();
  oc.updatedAt = oc.createdAt;

  if ("enabled" in req && req["enabled"].isBoolean)
    oc.enabled = req["enabled"].get!bool;
  if ("sync_strategy" in req && req["sync_strategy"].isString)
    oc.syncStrategy = parseSyncStrategy(req["sync_strategy"].get!string);
  if ("sync_interval_secs" in req && req["sync_interval_secs"].isInteger)
    oc.syncIntervalSecs = cast(size_t)req["sync_interval_secs"].get!long;
  if ("entity_sets" in req && req["entity_sets"].isArray) {
    foreach (v; req["entity_sets"])
      if (v.isString)
        oc.entitySets ~= v.get!string;
  }
  if ("max_offline_store_mb" in req && req["max_offline_store_mb"].isInteger)
    oc.maxOfflineStoreMB = cast(size_t)req["max_offline_store_mb"].get!long;
  if ("encrypt_local_store" in req && req["encrypt_local_store"].isBoolean)
    oc.encryptLocalStore = req["encrypt_local_store"].get!bool;
  if ("conflict_detection" in req && req["conflict_detection"].isBoolean)
    oc.conflictDetection = req["conflict_detection"].get!bool;
  if ("odata_service_url" in req && req["odata_service_url"].isString)
    oc.odataServiceUrl = req["odata_service_url"].get!string;
  return oc;
}
}


