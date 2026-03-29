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
class KSTKeyEntry : SAPEntity {
  mixin(SAPEntityTemplate!KSTKeyEntry);

  string alias_;
  KSTEntryType entryType = KSTEntryType.PRIVATE_KEY;
  KSTAlgorithm algorithm = KSTAlgorithm.RSA;
  size_t keySize = 2048;
  KSTFormat format = KSTFormat.PEM;
  KSTEncryptedPayload encryptedMaterial;
  string[] keyUsage;
  Json metadata;

  override Json toJson()  {
    return super.toJson
    .set("alias", alias_)
    .set("entry_type", cast(string)entryType)
    .set("algorithm", cast(string)algorithm)
    .set("key_size", cast(long)keySize)
    .set("format", cast(string)format)
    .set("key_usage", keyUsage.map!(u => Json(u)).array.Json)
    .set("metadata", metadata);
  }
}

KSTKeyEntry keyEntryFromJson(string alias_, Json request) {
  KSTKeyEntry entry  = new KSTKeyEntry(request);
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
        entry.keyUsage ~= item.getString;
    }
  }
  
  entry.metadata = request.getObject("metadata", Json.emptyObject);
  return entry;
}
