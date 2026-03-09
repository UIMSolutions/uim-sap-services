/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.integrationsuite.models.connector;

import uim.sap.integrationsuite;

mixin(ShowModule!());

@safe:

struct INTConnector {
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

INTConnector connectorFromJson(string tenantId, Json request) {
    INTConnector c;
    c.tenantId = tenantId;
    c.connectorId = randomUUID().toString();

    if ("name" in request && request["name"].isString)
        c.name = request["name"].get!string;
    if ("description" in request && request["description"].isString)
        c.description = request["description"].get!string;
    if ("connector_type" in request && request["connector_type"].isString)
        c.connectorType = request["connector_type"].get!string;
    if ("provider" in request && request["provider"].isString)
        c.provider = request["provider"].get!string;
    if ("auth_scheme" in request && request["auth_scheme"].isString)
        c.authScheme = request["auth_scheme"].get!string;
    if ("base_url" in request && request["base_url"].isString)
        c.baseUrl = request["base_url"].get!string;
    if ("configuration" in request)
        c.configuration = request["configuration"];
    else
        c.configuration = Json.emptyObject;

    c.createdAt = Clock.currTime().toINTOExtString();
    c.updatedAt = c.createdAt;
    return c;
}
