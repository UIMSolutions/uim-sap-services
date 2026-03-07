/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.integrationsuite.models.iflow;

import uim.sap.integrationsuite;

mixin(ShowModule!());

@safe:

struct ISIFlow {
    string tenantId;
    string iflowId;
    string name;
    string description;
    string packageId;
    string version_ = "1.0.0";
    string status = "draft";        // draft | active | error | deployed
    string runtime = "cloud";       // cloud | hybrid
    string sender;
    string receiver;
    string protocol = "https";
    string endpointUrl;
    long messageCount = 0;
    long errorCount = 0;
    string deployedAt;
    string createdAt;
    string updatedAt;

    Json toJson() const {
        Json j = Json.emptyObject;
        j["tenant_id"] = tenantId;
        j["iflow_id"] = iflowId;
        j["name"] = name;
        j["description"] = description;
        j["package_id"] = packageId;
        j["version"] = version_;
        j["status"] = status;
        j["runtime"] = runtime;
        j["sender"] = sender;
        j["receiver"] = receiver;
        j["protocol"] = protocol;
        j["endpoint_url"] = endpointUrl;
        j["message_count"] = messageCount;
        j["error_count"] = errorCount;
        j["deployed_at"] = deployedAt;
        j["created_at"] = createdAt;
        j["updated_at"] = updatedAt;
        return j;
    }
}

ISIFlow iflowFromJson(string tenantId, Json request) {
    ISIFlow f;
    f.tenantId = tenantId;
    f.iflowId = randomUUID().toString();

    if ("name" in request && request["name"].isString)
        f.name = request["name"].get!string;
    if ("description" in request && request["description"].isString)
        f.description = request["description"].get!string;
    if ("package_id" in request && request["package_id"].isString)
        f.packageId = request["package_id"].get!string;
    if ("version" in request && request["version"].isString)
        f.version_ = request["version"].get!string;
    if ("runtime" in request && request["runtime"].isString)
        f.runtime = request["runtime"].get!string;
    if ("sender" in request && request["sender"].isString)
        f.sender = request["sender"].get!string;
    if ("receiver" in request && request["receiver"].isString)
        f.receiver = request["receiver"].get!string;
    if ("protocol" in request && request["protocol"].isString)
        f.protocol = request["protocol"].get!string;
    if ("endpoint_url" in request && request["endpoint_url"].isString)
        f.endpointUrl = request["endpoint_url"].get!string;

    f.createdAt = Clock.currTime().toISOExtString();
    f.updatedAt = f.createdAt;
    return f;
}
