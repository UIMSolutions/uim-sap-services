/**
 * Hybrid Runtime model — Hybrid Integration
 *
 * Represents an on-premise or private-landscape runtime agent.
 */
module uim.sap.integrationsuite.models.hybrid_runtime;

import uim.sap.integrationsuite;

mixin(ShowModule!());

@safe:

struct ISHybridRuntime {
    string tenantId;
    string runtimeId;
    string name;
    string description;
    string location;                     // e.g. datacenter name or region
    string runtimeType = "integration";  // integration | api_management
    string status = "online";            // online | offline | error | maintenance
    string version_ = "1.0.0";
    long iflowCount = 0;
    long apiProxyCount = 0;
    string lastHeartbeat;
    string createdAt;
    string updatedAt;

    Json toJson() const {
        Json j = Json.emptyObject;
        j["tenant_id"] = tenantId;
        j["runtime_id"] = runtimeId;
        j["name"] = name;
        j["description"] = description;
        j["location"] = location;
        j["runtime_type"] = runtimeType;
        j["status"] = status;
        j["version"] = version_;
        j["iflow_count"] = iflowCount;
        j["api_proxy_count"] = apiProxyCount;
        j["last_heartbeat"] = lastHeartbeat;
        j["created_at"] = createdAt;
        j["updated_at"] = updatedAt;
        return j;
    }
}

ISHybridRuntime hybridRuntimeFromJson(string tenantId, Json request) {
    ISHybridRuntime r;
    r.tenantId = tenantId;
    r.runtimeId = randomUUID().toString();

    if ("name" in request && request["name"].type == Json.Type.string)
        r.name = request["name"].get!string;
    if ("description" in request && request["description"].type == Json.Type.string)
        r.description = request["description"].get!string;
    if ("location" in request && request["location"].type == Json.Type.string)
        r.location = request["location"].get!string;
    if ("runtime_type" in request && request["runtime_type"].type == Json.Type.string)
        r.runtimeType = request["runtime_type"].get!string;
    if ("version" in request && request["version"].type == Json.Type.string)
        r.version_ = request["version"].get!string;

    r.createdAt = Clock.currTime().toISOExtString();
    r.updatedAt = r.createdAt;
    return r;
}
