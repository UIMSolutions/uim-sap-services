/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.har.models.models;

import std.datetime : SysTime;
import std.string : toLower;

import vibe.data.json : Json;



struct TenantContext {
  UUID tenantId;
  UUID spaceId;
  UUID consumerTenantId;
  UUID consumerSpaceId;
}

struct UploadedAsset {
  string path;
  string contentBase64;
  string contentType;
}




Visibility visibilityFromString(string value) {
  return toLower(value) == "public" ? Visibility.publicAccess : Visibility.privateAccess;
}

string visibilityToString(Visibility visibility) {
  return visibility == Visibility.publicAccess ? "public" : "private";
}

private string getString(Json payload, string key, string fallback) {
  if (key in payload && payload[key].isString) {
    return payload[key].getString;
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
