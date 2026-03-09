module uim.sap.tkc.models.provider;

import std.datetime : SysTime;

import vibe.data.json : Json;

@safe:

struct TKCProvider {
    string providerId;
    string name;
    string providerType;
    string endpoint;
    bool active = true;
    SysTime createdAt;
    SysTime updatedAt;
    bool hasLastSync;
    SysTime lastSyncAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["provider_id"] = providerId;
        payload["name"] = name;
        payload["provider_type"] = providerType;
        payload["endpoint"] = endpoint;
        payload["active"] = active;
        payload["created_at"] = createdAt.toISOExtString();
        payload["updated_at"] = updatedAt.toISOExtString();
        payload["last_sync_at"] = hasLastSync ? lastSyncAt.toISOExtString() : null;
        return payload;
    }
}
