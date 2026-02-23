module uim.sap.con.models;

import std.algorithm.searching : canFind;
import std.datetime : Clock, SysTime;
import std.string : toLower;

import vibe.data.json : Json;

enum string[] CON_SUPPORTED_PROTOCOLS = ["http", "rfc", "tcp", "jdbc", "odbc"];

bool isSupportedProtocol(string protocol) {
    return CON_SUPPORTED_PROTOCOLS.canFind(normalizeProtocol(protocol));
}

string normalizeProtocol(string protocol) {
    return toLower(protocol);
}

ushort defaultPortForProtocol(string protocol) {
    final switch (normalizeProtocol(protocol)) {
        case "http": return 80;
        case "rfc": return 3300;
        case "tcp": return 443;
        case "jdbc": return 5432;
        case "odbc": return 1433;
    }
}

struct CONDestination {
    string tenantId;
    string name;
    string protocol;
    string targetHost;
    ushort targetPort;
    string targetPath;

    bool onPremise = true;
    bool cloudDatabase = false;
    bool identityPropagationEnabled = true;

    Json metadata;
    SysTime createdAt;
    SysTime updatedAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["tenant_id"] = tenantId;
        payload["name"] = name;
        payload["protocol"] = protocol;
        payload["target_host"] = targetHost;
        payload["target_port"] = cast(long)targetPort;
        payload["target_path"] = targetPath;
        payload["on_premise"] = onPremise;
        payload["cloud_database"] = cloudDatabase;
        payload["identity_propagation_enabled"] = identityPropagationEnabled;
        payload["metadata"] = metadata;
        payload["created_at"] = createdAt.toISOExtString();
        payload["updated_at"] = updatedAt.toISOExtString();
        return payload;
    }
}

struct CONTenantSummary {
    string tenantId;
    size_t destinations;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["tenant_id"] = tenantId;
        payload["destinations"] = cast(long)destinations;
        return payload;
    }
}

CONDestination destinationFromJson(string tenantId, string name, Json request) {
    CONDestination destination;
    destination.tenantId = tenantId;
    destination.name = name;
    destination.createdAt = Clock.currTime();
    destination.updatedAt = destination.createdAt;
    destination.targetPath = "/";

    if ("protocol" in request && request["protocol"].type == Json.Type.string) {
        destination.protocol = normalizeProtocol(request["protocol"].get!string);
    }
    if ("target_host" in request && request["target_host"].type == Json.Type.string) {
        destination.targetHost = request["target_host"].get!string;
    }
    if ("target_port" in request && request["target_port"].type == Json.Type.int_) {
        auto value = request["target_port"].get!long;
        if (value > 0 && value <= ushort.max) {
            destination.targetPort = cast(ushort)value;
        }
    }
    if ("target_path" in request && request["target_path"].type == Json.Type.string) {
        destination.targetPath = request["target_path"].get!string;
    }
    if ("on_premise" in request && request["on_premise"].type == Json.Type.bool_) {
        destination.onPremise = request["on_premise"].get!bool;
    }
    if ("cloud_database" in request && request["cloud_database"].type == Json.Type.bool_) {
        destination.cloudDatabase = request["cloud_database"].get!bool;
    }
    if ("identity_propagation_enabled" in request && request["identity_propagation_enabled"].type == Json.Type.bool_) {
        destination.identityPropagationEnabled = request["identity_propagation_enabled"].get!bool;
    }
    if ("metadata" in request && request["metadata"].type == Json.Type.object) {
        destination.metadata = request["metadata"];
    } else {
        destination.metadata = Json.emptyObject;
    }

    if (destination.protocol == "jdbc" || destination.protocol == "odbc") {
        destination.cloudDatabase = true;
    }

    if (destination.targetPort == 0 && destination.protocol.length > 0) {
        destination.targetPort = defaultPortForProtocol(destination.protocol);
    }

    return destination;
}
