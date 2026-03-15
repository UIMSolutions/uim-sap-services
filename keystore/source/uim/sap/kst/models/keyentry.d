/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.kst.models.keyentry;

import uim.sap.kst;

mixin(ShowModule!());

@safe:

/// Represents a cryptographic key entry (private key, secret key, or key pair)
struct KSTKeyEntry {
  string alias_;
  KSTEntryType entryType = KSTEntryType.PRIVATE_KEY;
  KSTAlgorithm algorithm = KSTAlgorithm.RSA;
  size_t keySize = 2048;
  KSTFormat format = KSTFormat.PEM;
  KSTEncryptedPayload encryptedMaterial;
  string[] keyUsage;
  Json metadata;
  SysTime createdAt;
  SysTime updatedAt;

  override Json toJson()  {
    Json info = super.toJson;
    payload["alias"] = alias_;
    payload["entry_type"] = cast(string)entryType;
    payload["algorithm"] = cast(string)algorithm;
    payload["key_size"] = cast(long)keySize;
    payload["format"] = cast(string)format;
    payload["key_usage"] = keyUsage.map!(u => Json(u)).array.Json;
    payload["metadata"] = metadata;
    payload["created_at"] = createdAt.toISOExtString();
    payload["updated_at"] = updatedAt.toISOExtString();
    return payload;
  }
}

KSTKeyEntry keyEntryFromJson(string alias_, Json request) {
  KSTKeyEntry entry;
  entry.alias_ = alias_;
  entry.createdAt = Clock.currTime();
  entry.updatedAt = entry.createdAt;

  if ("entry_type" in request && request["entry_type"].isString)
    entry.entryType = parseEntryType(request["entry_type"].get!string);
  if ("algorithm" in request && request["algorithm"].isString)
    entry.algorithm = parseAlgorithm(request["algorithm"].get!string);
  if ("key_size" in request && request["key_size"].isInteger)
    entry.keySize = cast(size_t)request["key_size"].get!long;
  if ("format" in request && request["format"].isString)
    entry.format = parseFormat(request["format"].get!string);
  if ("key_usage" in request && request["key_usage"].isArray) {
    foreach (item; request["key_usage"].toArray) {
      if (item.isString)
        entry.keyUsage ~= item.get!string;
    }
  }
  if ("metadata" in request && request["metadata"].isObject)
    entry.metadata = request["metadata"];
  else
    entry.metadata = Json.emptyObject;
  return entry;
}
