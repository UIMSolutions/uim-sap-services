/**
 * Models for SAP IDOC operations
 *
 * Copyright: Copyright © 2018-2026, Ozan Nurettin Süel
 * License: Apache-2.0
 * Authors: Ozan Nurettin Süel
 */
module uim.sap.idoc.models;

import vibe.data.json : Json;
import std.datetime : SysTime;

struct SAPIDocControlRecord {
    string messageType;
    string idocType;
    string senderPort;
    string senderPartner;
    string receiverPort;
    string receiverPartner;

    Json toJson() const {
        Json data = Json.emptyObject;
        if (messageType.length > 0) data["messageType"] = Json(messageType);
        if (idocType.length > 0) data["idocType"] = Json(idocType);
        if (senderPort.length > 0) data["senderPort"] = Json(senderPort);
        if (senderPartner.length > 0) data["senderPartner"] = Json(senderPartner);
        if (receiverPort.length > 0) data["receiverPort"] = Json(receiverPort);
        if (receiverPartner.length > 0) data["receiverPartner"] = Json(receiverPartner);
        return data;
    }
}

struct SAPIDocSubmitRequest {
    SAPIDocControlRecord control;
    Json segments = Json.emptyArray;
    bool testRun;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["control"] = control.toJson();
        payload["segments"] = segments;
        payload["testRun"] = Json(testRun);
        return payload;
    }
}

struct SAPIDocResponse {
    bool success;
    int statusCode;
    string documentNumber;
    string status;
    string errorMessage;
    Json data = Json.emptyObject;
    string[string] headers;
    SysTime timestamp;

    bool isSuccess() const pure nothrow @safe @nogc {
        return success;
    }
}
