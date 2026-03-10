module uim.sap.obs.models.objectversion;

import std.datetime : SysTime;

import vibe.data.json : Json;

@safe:

/// Object version entry (when versioning is enabled)
struct OBSObjectVersion {
    string versionId;
    string objectId;
    string bucketId;
    string key;
    size_t sizeBytes;
    string etag;
    string contentType;
    bool isLatest;
    bool isDeleteMarker;
    SysTime createdAt;

    Json toJson() const {
        import std.conv : to;
        Json j = Json.emptyObject;
        j["version_id"] = versionId;
        j["object_id"] = objectId;
        j["bucket_id"] = bucketId;
        j["key"] = key;
        j["size_bytes"] = sizeBytes.to!long;
        j["etag"] = etag;
        j["content_type"] = contentType;
        j["is_latest"] = isLatest;
        j["is_delete_marker"] = isDeleteMarker;
        j["created_at"] = createdAt.toISOExtString();
        return j;
    }
}
