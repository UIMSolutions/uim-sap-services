module uim.sap.obs.models.multipart;

import std.datetime : Clock, SysTime;

import vibe.data.json : Json;

import uim.sap.obs.enumerations;

@safe:

/// A part in a multipart upload
struct OBSUploadPart {
    int partNumber;
    size_t sizeBytes;
    string etag;
    SysTime uploadedAt;

    Json toJson() const {
        import std.conv : to;
        Json j = Json.emptyObject;
        j["part_number"] = partNumber;
        j["size_bytes"] = sizeBytes.to!long;
        j["etag"] = etag;
        j["uploaded_at"] = uploadedAt.toISOExtString();
        return j;
    }
}

/// Multipart upload session
struct OBSMultipartUpload {
    string uploadId;
    string bucketId;
    string objectKey;
    OBSUploadStatus status = OBSUploadStatus.initiated;
    string contentType;
    OBSUploadPart[] parts;
    string[string] userMetadata;
    SysTime initiatedAt;

    Json toJson() const {
        Json j = Json.emptyObject;
        j["upload_id"] = uploadId;
        j["bucket_id"] = bucketId;
        j["object_key"] = objectKey;
        j["status"] = cast(string) status;
        j["content_type"] = contentType;

        Json partsArr = Json.emptyArray;
        foreach (ref p; parts) partsArr ~= p.toJson();
        j["parts"] = partsArr;

        import std.conv : to;
        j["total_parts"] = cast(long) parts.length;

        if (userMetadata.length > 0) {
            Json m = Json.emptyObject;
            foreach (k, v; userMetadata) m[k] = v;
            j["user_metadata"] = m;
        }
        j["initiated_at"] = initiatedAt.toISOExtString();
        return j;
    }
}
