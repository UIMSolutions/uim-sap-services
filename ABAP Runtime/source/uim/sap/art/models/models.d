/**
 * Models for SAP ABAP Runtime (ART)
 */
module uim.sap.art.models.models;

import std.datetime : SysTime;

import vibe.data.json : Json;

struct SAPABAPProgramRequest {
    string program;
    string user;
    string client;
    string language = "EN";
    Json parameters = Json.emptyObject;
    string correlationId;

    static SAPABAPProgramRequest fromJson(Json payload) {
        SAPABAPProgramRequest request;

        if ("program" in payload && payload["program"].type == Json.Type.string) {
            request.program = payload["program"].get!string;
        }

        if ("user" in payload && payload["user"].type == Json.Type.string) {
            request.user = payload["user"].get!string;
        }

        if ("client" in payload && payload["client"].type == Json.Type.string) {
            request.client = payload["client"].get!string;
        }

        if ("language" in payload && payload["language"].type == Json.Type.string) {
            request.language = payload["language"].get!string;
        }

        if ("parameters" in payload) {
            request.parameters = payload["parameters"];
        }

        if ("correlationId" in payload && payload["correlationId"].type == Json.Type.string) {
            request.correlationId = payload["correlationId"].get!string;
        }

        return request;
    }

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["program"] = program;
        payload["user"] = user;
        payload["client"] = client;
        payload["language"] = language;
        payload["parameters"] = parameters;
        payload["correlationId"] = correlationId;
        return payload;
    }
}

struct SAPABAPProgramResult {
    bool success;
    string message;
    int statusCode = 200;
    Json data = Json.emptyObject;
    string program;
    SysTime timestamp;
    string correlationId;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["success"] = success;
        payload["message"] = message;
        payload["statusCode"] = statusCode;
        payload["data"] = data;
        payload["program"] = program;
        payload["timestamp"] = timestamp.toISOExtString();
        payload["correlationId"] = correlationId;
        return payload;
    }
}

struct SAPABAPRuntimeHealth {
    bool ok;
    string runtimeName;
    string runtimeVersion;
    size_t registeredPrograms;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["ok"] = ok;
        payload["runtimeName"] = runtimeName;
        payload["runtimeVersion"] = runtimeVersion;
        payload["registeredPrograms"] = cast(long)registeredPrograms;
        return payload;
    }
}
