/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.har.models.models;

import std.datetime : SysTime;
import std.string : toLower;

import vibe.data.json : Json;

enum Visibility {
    privateAccess,
    publicAccess
}

struct TenantContext {
    string tenantId;
    string spaceId;
    string consumerTenantId;
    string consumerSpaceId;
}

struct UploadedAsset {
    string path;
    string contentBase64;
    string contentType;
}

struct AppVersionInfo {
    string tenantId;
    string spaceId;
    string appId;
    string versionId;
    Visibility visibility;
    bool active;
    string createdAt;
    string updatedAt;
    long sizeBytes;
    long fileCount;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["tenant_id"] = tenantId;
        payload["space_id"] = spaceId;
        payload["app_id"] = appId;
        payload["version"] = versionId;
        payload["visibility"] = visibilityToString(visibility);
        payload["active"] = active;
        payload["created_at"] = createdAt;
        payload["updated_at"] = updatedAt;
        payload["size_bytes"] = sizeBytes;
        payload["file_count"] = fileCount;
        return payload;
    }

    static AppVersionInfo fromJson(Json payload) {
        AppVersionInfo item;
        item.tenantId = getString(payload, "tenant_id", "");
        item.spaceId = getString(payload, "space_id", "");
        item.appId = getString(payload, "app_id", "");
        item.versionId = getString(payload, "version", "");
        item.visibility = visibilityFromString(getString(payload, "visibility", "private"));
        item.active = getBoolean(payload, "active", false);
        item.createdAt = getString(payload, "created_at", "");
        item.updatedAt = getString(payload, "updated_at", "");
        item.sizeBytes = getLong(payload, "size_bytes", 0L);
        item.fileCount = getLong(payload, "file_count", 0L);
        return item;
    }
}

struct RuntimeAsset {
    string tenantId;
    string spaceId;
    string appId;
    string versionId;
    string path;
    string contentType;
    bool isPublic;
    string etag;
    ubyte[] content;
}

Visibility visibilityFromString(string value) {
    return toLower(value) == "public" ? Visibility.publicAccess : Visibility.privateAccess;
}

string visibilityToString(Visibility visibility) {
    return visibility == Visibility.publicAccess ? "public" : "private";
}

private string getString(Json payload, string key, string fallback) {
    if (key in payload && payload[key].isString) {
        return payload[key].get!string;
    }
    return fallback;
}

private bool getBoolean(Json payload, string key, bool fallback) {
    if (key in payload && payload[key].isBoolean) {
        return payload[key].get!bool;
    }
    return fallback;
}

private long getLong(Json payload, string key, long fallback) {
    if (!(key in payload)) {
        return fallback;
    }
    if (payload[key].isInteger) {
        return payload[key].get!long;
    }
    return fallback;
}
