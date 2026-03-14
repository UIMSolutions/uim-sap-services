module uim.sap.mob.models.offlineconfig;


import uim.sap.mob;

mixin(ShowModule!());

@safe:


/// Offline/OData synchronization configuration per application
struct MOBOfflineConfig {
    string appId;
    bool enabled;
    MOBSyncStrategy syncStrategy = MOBSyncStrategy.DELTA;
    size_t syncIntervalSecs = 300;
    string[] entitySets;          // OData entity sets available offline
    size_t maxOfflineStoreMB = 50; // max local DB size
    bool encryptLocalStore = true;
    bool conflictDetection = true;
    string odataServiceUrl;       // e.g. /sap/opu/odata/…
    SysTime createdAt;
    SysTime updatedAt;

    Json toJson() const {
        Json j = Json.emptyObject;
        j["app_id"] = appId;
        j["enabled"] = enabled;
        j["sync_strategy"] = cast(string) syncStrategy;
        j["sync_interval_secs"] = cast(long) syncIntervalSecs;
        Json es = Json.emptyArray;
        foreach (e; entitySets) es.appendArrayElement(Json(e));
        j["entity_sets"] = es;
        j["max_offline_store_mb"] = cast(long) maxOfflineStoreMB;
        j["encrypt_local_store"] = encryptLocalStore;
        j["conflict_detection"] = conflictDetection;
        j["odata_service_url"] = odataServiceUrl;
        j["created_at"] = createdAt.toISOExtString();
        j["updated_at"] = updatedAt.toISOExtString();
        return j;
    }
}

MOBOfflineConfig offlineConfigFromJson(string appId, Json req) {
    MOBOfflineConfig oc;
    oc.appId = appId;
    oc.createdAt = Clock.currTime();
    oc.updatedAt = oc.createdAt;

    if ("enabled" in req && req["enabled"].type == Json.Type.bool_)
        oc.enabled = req["enabled"].get!bool;
    if ("sync_strategy" in req && req["sync_strategy"].isString)
        oc.syncStrategy = parseSyncStrategy(req["sync_strategy"].get!string);
    if ("sync_interval_secs" in req && req["sync_interval_secs"].isInteger)
        oc.syncIntervalSecs = cast(size_t) req["sync_interval_secs"].get!long;
    if ("entity_sets" in req && req["entity_sets"].type == Json.Type.array) {
        foreach (v; req["entity_sets"])
            if (v.isString) oc.entitySets ~= v.get!string;
    }
    if ("max_offline_store_mb" in req && req["max_offline_store_mb"].isInteger)
        oc.maxOfflineStoreMB = cast(size_t) req["max_offline_store_mb"].get!long;
    if ("encrypt_local_store" in req && req["encrypt_local_store"].type == Json.Type.bool_)
        oc.encryptLocalStore = req["encrypt_local_store"].get!bool;
    if ("conflict_detection" in req && req["conflict_detection"].type == Json.Type.bool_)
        oc.conflictDetection = req["conflict_detection"].get!bool;
    if ("odata_service_url" in req && req["odata_service_url"].isString)
        oc.odataServiceUrl = req["odata_service_url"].get!string;
    return oc;
}
