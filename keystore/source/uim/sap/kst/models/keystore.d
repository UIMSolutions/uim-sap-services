/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.kst.models.keystore;

import uim.sap.kst;

mixin(ShowModule!());

@safe:

/// Represents a named keystore containing keys and certificates
struct KSTKeystore {
    string name;
    string description;
    KSTKeyEntry[string] keys;
    KSTCertificate[string] certificates;
    Json metadata;
    SysTime createdAt;
    SysTime updatedAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["name"] = name;
        payload["description"] = description;
        payload["key_count"] = cast(long) keys.length;
        payload["certificate_count"] = cast(long) certificates.length;
        payload["metadata"] = metadata;
        payload["created_at"] = createdAt.toISOExtString();
        payload["updated_at"] = updatedAt.toISOExtString();
        return payload;
    }

    Json toJsonDetailed() const {
        Json payload = toJson();

        Json keyList = Json.emptyArray;
        foreach (ref k; keys.byValue) {
            keyList.appendArrayElement(k.toJson());
        }
        payload["keys"] = keyList;

        Json certList = Json.emptyArray;
        foreach (ref c; certificates.byValue) {
            certList.appendArrayElement(c.toJson());
        }
        payload["certificates"] = certList;

        return payload;
    }
}

KSTKeystore keystoreFromJson(string name, Json request) {
    KSTKeystore ks;
    ks.name = name;
    ks.createdAt = Clock.currTime();
    ks.updatedAt = ks.createdAt;

    if ("description" in request && request["description"].isString)
        ks.description = request["description"].get!string;
    if ("metadata" in request && request["metadata"].isObject)
        ks.metadata = request["metadata"];
    else
        ks.metadata = Json.emptyObject;
    return ks;
}
