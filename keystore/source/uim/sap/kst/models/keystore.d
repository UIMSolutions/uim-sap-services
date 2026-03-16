/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.kst.models.keystore;

import uim.sap.kst;

mixin(ShowModule!());

@safe:

/**
  * Represents a keystore containing key entries and certificates.
  * The KSTKeystore struct encapsulates the properties and metadata of a keystore, including its name, description,
  * contained keys and certificates, and timestamps for creation and last update. It also provides methods for
  * converting the keystore data into JSON format for API responses.
  *
  * The `keystoreFromJson` function is a helper function that creates a KSTKeystore instance from a JSON request payload,
  * initializing its properties based on the provided data and setting the creation and update timestamps to the current time.
  *
  * This struct is a core part of the keystore management system, allowing for structured storage and retrieval of
  * keystore information within the application.
  *
  * Example usage:
  * ```
  * Json request = ...; // JSON payload from API request
  * KSTKeystore ks = keystoreFromJson("myKeystore", request);
  * // Now ks contains the keystore information initialized from the request
  * ```
  */
class KSTKeystore : SAPStore {
  mixin(SAPStoreTemplate!KSTKeystore);

  override bool initialize(Json[string] initData) {
    if (!super.initialize(initData)) {
      return false;
    }

    if ("description" in request && initData["description"].isString) {
      description = initData["description"].get!string;
    }
    metadata = initData.getObject("metadata", Json.emptyObject);

    return true;
  }

  string name;
  string description;
  KSTKeyEntry[string] keys;
  KSTCertificate[string] certificates;
  Json metadata;
  SysTime createdAt;
  SysTime updatedAt;

  override Json toJson() {
    return super.toJson
      .set("name", name)
      .set("description", description)
      .set("key_count", cast(long)keys.length)
      .set("certificate_count", cast(long)certificates.length)
      .set("metadata", metadata)
      .set("created_at", createdAt.toISOExtString())
      .set("updated_at", updatedAt.toISOExtString());
  }

  Json toJsonDetailed() const {
    Json keyList = keys.byValue.map!(key => keyList.appendArrayElement(key.toJson()).array.toJson;
        Json certList = certificates.byValue.map!(
          cert => certList.appendArrayElement(cert.toJson()).array.toJson; Json payload = toJson();
          payload["keys"] = keyList; payload["certificates"] = certList; return payload;
  }
}

KSTKeystore keystoreFromJson(string name, Json request) {
  KSTKeystore ks = new KSTKeystore(request); ks.name = name; ks.createdAt = Clock.currTime();
    ks.updatedAt = ks.createdAt; return ks;}
