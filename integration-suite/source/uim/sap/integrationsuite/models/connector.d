/**
 * Connector model — Open Connectors
 *
 * Represents a pre-built or custom connector to non-SAP cloud applications.
 */
module uim.sap.integrationsuite.models.connector;

import uim.sap.integrationsuite;

mixin(ShowModule!());

@safe:

struct ISConnector {
    string tenantId;
    string connectorId;
    string name;
    string description;
    string connectorType = "prebuilt";  // prebuilt | custom
    string provider;                     // e.g. Salesforce, Slack, AWS S3
    string authScheme = "oauth2";        // oauth2 | basic | apikey | none
    string status = "active";            // active | inactive | error
    string baseUrl;
    Json configuration;
    long callCount = 0;
    string createdAt;
    string updatedAt;

    Json toJson() const {
        Json j = Json.emptyObject;
        j["tenant_id"] = tenantId;
        j["connector_id"] = connectorId;
        j["name"] = name;
        j["description"] = description;
        j["connector_type"] = connectorType;
        j["provider"] = provider;
        j["auth_scheme"] = authScheme;
        j["status"] = status;
        j["base_url"] = baseUrl;
        j["configuration"] = configuration;
        j["call_count"] = callCount;
        j["created_at"] = createdAt;
        j["updated_at"] = updatedAt;
        return j;
    }
}

ISConnector connectorFromJson(string tenantId, Json request) {
    ISConnector c;
    c.tenantId = tenantId;
    c.connectorId = randomUUID().toString();

    if ("name" in request && request["name"].type == Json.Type.string)
        c.name = request["name"].get!string;
    if ("description" in request && request["description"].type == Json.Type.string)
        c.description = request["description"].get!string;
    if ("connector_type" in request && request["connector_type"].type == Json.Type.string)
        c.connectorType = request["connector_type"].get!string;
    if ("provider" in request && request["provider"].type == Json.Type.string)
        c.provider = request["provider"].get!string;
    if ("auth_scheme" in request && request["auth_scheme"].type == Json.Type.string)
        c.authScheme = request["auth_scheme"].get!string;
    if ("base_url" in request && request["base_url"].type == Json.Type.string)
        c.baseUrl = request["base_url"].get!string;
    if ("configuration" in request)
        c.configuration = request["configuration"];
    else
        c.configuration = Json.emptyObject;

    c.createdAt = Clock.currTime().toISOExtString();
    c.updatedAt = c.createdAt;
    return c;
}
