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
    Json j = Json.emptyObject;
    j["upload_id"] = uploadId;
    j["bucket_id"] = bucketId;
    j["object_key"] = objectKey;
    j["status"] = cast(string)status;
    j["content_type"] = contentType;

    Json partsArr = Json.emptyArray;
    foreach (ref p; parts)
      partsArr ~= p.toJson();
    j["parts"] = partsArr;

    import std.conv : to;

    j["total_parts"] = cast(long)parts.length;

    if (userMetadata.length > 0) {
      Json m = Json.emptyObject;
      foreach (k, v; userMetadata)
        m[k] = v;
      j["user_metadata"] = m;
    }
    j["initiated_at"] = initiatedAt.toISOExtString();
    return j;
  }
}
