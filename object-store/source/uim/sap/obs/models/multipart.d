/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
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

  override Json toJson() {
    import std.conv : to;

    return super.toJson()
      .set("part_number", partNumber)
      .set("size_bytes", sizeBytes.to!long)
      .set("etag", etag)
      .set("uploaded_at", uploadedAt.toISOExtString());
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

  override Json toJson() {
    import std.conv : to;

    Json partsArr = Json.emptyArray;
    foreach (ref p; parts)
      partsArr ~= p.toJson();

    Json json = super.toJson()
      .set("upload_id", uploadId)
      .set("bucket_id", bucketId)
      .set("object_key", objectKey)
      .set("status", cast(string)status)
      .set("content_type", contentType)
      .set("parts", partsArr)
      .set("total_parts", cast(long)parts.length)
      .set("initiated_at", initiatedAt.toISOExtString());

    if (userMetadata.length > 0) {
      Json meta = Json.emptyObject;
      foreach (k, v; userMetadata)
        meta[k] = v;
      json["user_metadata"] = meta;
    }

    return json;
  }
}
