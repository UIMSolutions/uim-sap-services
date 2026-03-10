module uim.sap.obs.models.bucket;

import std.datetime : Clock, SysTime;

import vibe.data.json : Json;

import uim.sap.obs.enumerations;

@safe:

/// Object store bucket (S3 bucket / Azure Blob container / GCS bucket)
struct OBSBucket {
    string bucketId;
    string name;
    string tenantId;
    OBSProvider provider = OBSProvider.awsS3;
    OBSBucketStatus status = OBSBucketStatus.active;
    OBSAccessLevel accessLevel = OBSAccessLevel.private_;
    OBSStorageClass storageClass = OBSStorageClass.standard;
    string region;               // e.g. "eu-west-1", "westeurope"
    bool versioningEnabled;
    bool encryptionEnabled = true;
    size_t replicationFactor = 3;
    string[string] tags;
    string[string] metadata;
    SysTime createdAt;
    SysTime updatedAt;

    Json toJson() const {
        Json j = Json.emptyObject;
        j["bucket_id"] = bucketId;
        j["name"] = name;
        j["tenant_id"] = tenantId;
        j["provider"] = cast(string) provider;
        j["status"] = cast(string) status;
        j["access_level"] = cast(string) accessLevel;
        j["storage_class"] = cast(string) storageClass;
        j["region"] = region;
        j["versioning_enabled"] = versioningEnabled;
        j["encryption_enabled"] = encryptionEnabled;

        import std.conv : to;
        j["replication_factor"] = replicationFactor.to!long;

        if (tags.length > 0) {
            Json t = Json.emptyObject;
            foreach (k, v; tags) t[k] = v;
            j["tags"] = t;
        }
        if (metadata.length > 0) {
            Json m = Json.emptyObject;
            foreach (k, v; metadata) m[k] = v;
            j["metadata"] = m;
        }
        j["created_at"] = createdAt.toISOExtString();
        j["updated_at"] = updatedAt.toISOExtString();
        return j;
    }
}

OBSBucket bucketFromJson(string bucketId, Json req) {
    OBSBucket b;
    b.bucketId = bucketId;
    b.createdAt = Clock.currTime();
    b.updatedAt = b.createdAt;

    if ("name" in req && req["name"].isString)
        b.name = req["name"].get!string;
    else
        b.name = bucketId;
    if ("tenant_id" in req && req["tenant_id"].isString)
        b.tenantId = req["tenant_id"].get!string;
    if ("provider" in req && req["provider"].isString)
        b.provider = parseProvider(req["provider"].get!string);
    if ("access_level" in req && req["access_level"].isString)
        b.accessLevel = parseAccessLevel(req["access_level"].get!string);
    if ("storage_class" in req && req["storage_class"].isString)
        b.storageClass = parseStorageClass(req["storage_class"].get!string);
    if ("region" in req && req["region"].isString)
        b.region = req["region"].get!string;
    if ("versioning_enabled" in req && req["versioning_enabled"].type == Json.Type.bool_)
        b.versioningEnabled = req["versioning_enabled"].get!bool;
    if ("encryption_enabled" in req && req["encryption_enabled"].type == Json.Type.bool_)
        b.encryptionEnabled = req["encryption_enabled"].get!bool;
    if ("tags" in req && req["tags"].type == Json.Type.object) {
        foreach (string k, v; req["tags"])
            if (v.isString) b.tags[k] = v.get!string;
    }
    if ("metadata" in req && req["metadata"].type == Json.Type.object) {
        foreach (string k, v; req["metadata"])
            if (v.isString) b.metadata[k] = v.get!string;
    }
    return b;
}

private OBSProvider parseProvider(string s) {
    switch (s) {
        case "aws_s3": return OBSProvider.awsS3;
        case "azure_blob": return OBSProvider.azureBlob;
        case "gcp_storage": return OBSProvider.gcpStorage;
        default: return OBSProvider.awsS3;
    }
}

private OBSAccessLevel parseAccessLevel(string s) {
    switch (s) {
        case "private": return OBSAccessLevel.private_;
        case "public_read": return OBSAccessLevel.publicRead;
        case "public_read_write": return OBSAccessLevel.publicReadWrite;
        default: return OBSAccessLevel.private_;
    }
}

private OBSStorageClass parseStorageClass(string s) {
    switch (s) {
        case "standard": return OBSStorageClass.standard;
        case "nearline": return OBSStorageClass.nearline;
        case "coldline": return OBSStorageClass.coldline;
        case "archive": return OBSStorageClass.archive;
        default: return OBSStorageClass.standard;
    }
}
