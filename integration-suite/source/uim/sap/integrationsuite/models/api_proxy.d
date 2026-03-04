/**
 * API Proxy model — API Management
 *
 * Represents a managed API proxy that fronts a backend service.
 */
module uim.sap.integrationsuite.models.api_proxy;

import uim.sap.integrationsuite;

mixin(ShowModule!());

@safe:

struct ISApiProxy {
    string tenantId;
    string proxyId;
    string name;
    string description;
    string basePath;
    string targetUrl;
    string version_ = "1.0.0";
    string status = "active";       // active | deprecated | revoked
    string authScheme = "none";     // none | apikey | oauth2 | basic
    long callCount = 0;
    long errorCount = 0;
    string[] policies;
    string createdAt;
    string updatedAt;

    Json toJson() const {
        Json j = Json.emptyObject;
        j["tenant_id"] = tenantId;
        j["proxy_id"] = proxyId;
        j["name"] = name;
        j["description"] = description;
        j["base_path"] = basePath;
        j["target_url"] = targetUrl;
        j["version"] = version_;
        j["status"] = status;
        j["auth_scheme"] = authScheme;
        j["call_count"] = callCount;
        j["error_count"] = errorCount;

        Json pols = Json.emptyArray;
        foreach (p; policies) pols ~= Json(p);
        j["policies"] = pols;

        j["created_at"] = createdAt;
        j["updated_at"] = updatedAt;
        return j;
    }
}

ISApiProxy apiProxyFromJson(string tenantId, Json request) {
    ISApiProxy p;
    p.tenantId = tenantId;
    p.proxyId = randomUUID().toString();

    if ("name" in request && request["name"].type == Json.Type.string)
        p.name = request["name"].get!string;
    if ("description" in request && request["description"].type == Json.Type.string)
        p.description = request["description"].get!string;
    if ("base_path" in request && request["base_path"].type == Json.Type.string)
        p.basePath = request["base_path"].get!string;
    if ("target_url" in request && request["target_url"].type == Json.Type.string)
        p.targetUrl = request["target_url"].get!string;
    if ("version" in request && request["version"].type == Json.Type.string)
        p.version_ = request["version"].get!string;
    if ("auth_scheme" in request && request["auth_scheme"].type == Json.Type.string)
        p.authScheme = request["auth_scheme"].get!string;

    p.createdAt = Clock.currTime().toISOExtString();
    p.updatedAt = p.createdAt;
    return p;
}
