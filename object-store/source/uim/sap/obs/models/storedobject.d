module uim.sap.obs.models.storedobject;

import std.datetime : Clock, SysTime;

import vibe.data.json : Json;

import uim.sap.obs.enumerations;

@safe:

/// Stored object within a bucket
struct OBSStoredObject {
    string objectId;
    string bucketId;
    string key;             // object key / path (e.g. "images/photo.png")
    string contentType;     // MIME type
    size_t sizeBytes;
    string etag;            // content hash
    OBSObjectStatus status = OBSObjectStatus.active;
    OBSStorageClass storageClass = OBSStorageClass.standard;
    string versionId;       // when versioning enabled
    bool isLatest = true;
    string ownerId;
    string[string] userMetadata;
    SysTime createdAt;
    SysTime updatedAt;

    /// Simulated content (in-memory representation)
    string contentBase64;

    Json toJson() const {
        import std.conv : to;
        Json j = Json.emptyObject;
        j["object_id"] = objectId;
        j["bucket_id"] = bucketId;
        j["key"] = key;
        j["content_type"] = contentType;
        j["size_bytes"] = sizeBytes.to!long;
        j["etag"] = etag;
        j["status"] = cast(string) status;
        j["storage_class"] = cast(string) storageClass;
        j["version_id"] = versionId;
        j["is_latest"] = isLatest;
        j["owner_id"] = ownerId;
        if (userMetadata.length > 0) {
            Json m = Json.emptyObject;
            foreach (k, v; userMetadata) m[k] = v;
            j["user_metadata"] = m;
        }
        j["created_at"] = createdAt.toISOExtString();
        j["updated_at"] = updatedAt.toISOExtString();
        return j;
    }

    /// Include content in response (for download)
    Json toJsonWithContent() const {
        Json j = toJson();
        j["content_base64"] = contentBase64;
        return j;
    }
}

OBSStoredObject objectFromJson(string objectId, string bucketId, Json req) {
    OBSStoredObject o;
    o.objectId = objectId;
    o.bucketId = bucketId;
    o.createdAt = Clock.currTime();
    o.updatedAt = o.createdAt;

    if ("key" in req && req["key"].isString)
        o.key = req["key"].get!string;
    if ("content_type" in req && req["content_type"].isString)
        o.contentType = req["content_type"].get!string;
    else
        o.contentType = "application/octet-stream";
    if ("content_base64" in req && req["content_base64"].isString) {
        o.contentBase64 = req["content_base64"].get!string;
        o.sizeBytes = o.contentBase64.length * 3 / 4; // approximate decoded size
    }
    if ("storage_class" in req && req["storage_class"].isString)
        o.storageClass = parseObjStorageClass(req["storage_class"].get!string);
    if ("owner_id" in req && req["owner_id"].isString)
        o.ownerId = req["owner_id"].get!string;
    if ("user_metadata" in req && req["user_metadata"].type == Json.Type.object) {
        foreach (string k, v; req["user_metadata"])
            if (v.isString) o.userMetadata[k] = v.get!string;
    }
    return o;
}

private OBSStorageClass parseObjStorageClass(string s) {
    switch (s) {
        case "STANDARD": return OBSStorageClass.standard;
        case "NEARLINE": return OBSStorageClass.nearline;
        case "COLDLINE": return OBSStorageClass.coldline;
        case "ARCHIVE": return OBSStorageClass.archive;
        default: return OBSStorageClass.standard;
    }
}
