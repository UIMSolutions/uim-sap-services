module uim.sap.obs.models.object_;

import std.datetime : Clock, SysTime;

import vibe.data.json : Json;

import uim.sap.obs.enumerations;

@safe:

/// Stored object within a bucket
struct OBSObject {
    string objectId;
    string bucketId;
    string key;                  // object key / path
    size_t sizeBytes;
    string contentType;          // MIME type
    string etag;                 // content hash
    OBSObjectStatus status = OBSObjectStatus.active;
    OBSStorageClass storageClass = OBSStorageClass.standard;
    string versionId;            // for versioned buckets
    bool isLatest = true;
    string[string] userMetadata;
    SysTime createdAt;
    SysTime updatedAt;

    Json toJson() const {
        Json j = Json.emptyObject;
        j["object_id"] = objectId;
        j["bucket_id"] = bucketId;
        j["key"] = key;

        import std.conv : to;
        j["size_bytes"] = sizeBytes.to!long;

        j["content_type"] = contentType;
        j["etag"] = etag;
        j["status"] = cast(string) status;
        j["storage_class"] = cast(string) storageClass;
        j["version_id"] = versionId;
        j["is_latest"] = isLatest;

        if (userMetadata.length > 0) {
            Json m = Json.emptyObject;
            foreach (k, v; userMetadata) m[k] = v;
            j["user_metadata"] = m;
        }
        j["created_at"] = createdAt.toISOExtString();
        j["updated_at"] = updatedAt.toISOExtString();
        return j;
    }
}

OBSObject objectFromJson(string objectId, string bucketId, Json req) {
    OBSObject o;
    o.objectId = objectId;
    o.bucketId = bucketId;
    o.createdAt = Clock.currTime();
    o.updatedAt = o.createdAt;

    if ("key" in req && req["key"].isString)
        o.key = req["key"].get!string;
    if ("size_bytes" in req && req["size_bytes"].type == Json.Type.int_)
        o.sizeBytes = cast(size_t) req["size_bytes"].get!long;
    if ("content_type" in req && req["content_type"].isString)
        o.contentType = req["content_type"].get!string;
    else
        o.contentType = "application/octet-stream";
    if ("storage_class" in req && req["storage_class"].isString) {
        switch (req["storage_class"].get!string) {
            case "nearline": o.storageClass = OBSStorageClass.nearline; break;
            case "coldline": o.storageClass = OBSStorageClass.coldline; break;
            case "archive": o.storageClass = OBSStorageClass.archive; break;
            default: o.storageClass = OBSStorageClass.standard; break;
        }
    }
    if ("user_metadata" in req && req["user_metadata"].type == Json.Type.object) {
        foreach (string k, v; req["user_metadata"])
            if (v.isString) o.userMetadata[k] = v.get!string;
    }
    return o;
}
