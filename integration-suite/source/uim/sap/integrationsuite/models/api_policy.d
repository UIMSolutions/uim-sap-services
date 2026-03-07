/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.integrationsuite.models.api_policy;

import uim.sap.integrationsuite;

mixin(ShowModule!());

@safe:

struct ISApiPolicy {
    string tenantId;
    string policyId;
    string name;
    string description;
    string policyType = "security";  // security | traffic | mediation
    string enforcement = "request";  // request | response | fault
    bool enabled = true;
    Json configuration;
    string createdAt;
    string updatedAt;

    Json toJson() const {
        Json j = Json.emptyObject;
        j["tenant_id"] = tenantId;
        j["policy_id"] = policyId;
        j["name"] = name;
        j["description"] = description;
        j["policy_type"] = policyType;
        j["enforcement"] = enforcement;
        j["enabled"] = enabled;
        j["configuration"] = configuration;
        j["created_at"] = createdAt;
        j["updated_at"] = updatedAt;
        return j;
    }
}

ISApiPolicy apiPolicyFromJson(string tenantId, Json request) {
    ISApiPolicy p;
    p.tenantId = tenantId;
    p.policyId = randomUUID().toString();

    if ("name" in request && request["name"].isString)
        p.name = request["name"].get!string;
    if ("description" in request && request["description"].isString)
        p.description = request["description"].get!string;
    if ("policy_type" in request && request["policy_type"].isString)
        p.policyType = request["policy_type"].get!string;
    if ("enforcement" in request && request["enforcement"].isString)
        p.enforcement = request["enforcement"].get!string;
    if ("enabled" in request && request["enabled"].type == Json.Type.bool_)
        p.enabled = request["enabled"].get!bool;
    if ("configuration" in request)
        p.configuration = request["configuration"];
    else
        p.configuration = Json.emptyObject;

    p.createdAt = Clock.currTime().toISOExtString();
    p.updatedAt = p.createdAt;
    return p;
}
