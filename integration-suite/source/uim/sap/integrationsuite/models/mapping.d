/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.integrationsuite.models.mapping;

import uim.sap.integrationsuite;

mixin(ShowModule!());

@safe:

struct ISMapping {
    string tenantId;
    string mappingId;
    string name;
    string description;
    string sourceFormat = "xml";     // xml | json | csv | idoc | edifact
    string targetFormat = "json";
    string sourceSchema;
    string targetSchema;
    string status = "draft";         // draft | published | deprecated
    string generationMethod = "manual";  // manual | crowdsource | ml
    Json mappingRules;
    string createdAt;
    string updatedAt;

    Json toJson() const {
        Json j = Json.emptyObject;
        j["tenant_id"] = tenantId;
        j["mapping_id"] = mappingId;
        j["name"] = name;
        j["description"] = description;
        j["source_format"] = sourceFormat;
        j["target_format"] = targetFormat;
        j["source_schema"] = sourceSchema;
        j["target_schema"] = targetSchema;
        j["status"] = status;
        j["generation_method"] = generationMethod;
        j["mapping_rules"] = mappingRules;
        j["created_at"] = createdAt;
        j["updated_at"] = updatedAt;
        return j;
    }
}

ISMapping mappingFromJson(string tenantId, Json request) {
    ISMapping m;
    m.tenantId = tenantId;
    m.mappingId = randomUUID().toString();

    if ("name" in request && request["name"].isString)
        m.name = request["name"].get!string;
    if ("description" in request && request["description"].isString)
        m.description = request["description"].get!string;
    if ("source_format" in request && request["source_format"].isString)
        m.sourceFormat = request["source_format"].get!string;
    if ("target_format" in request && request["target_format"].isString)
        m.targetFormat = request["target_format"].get!string;
    if ("source_schema" in request && request["source_schema"].isString)
        m.sourceSchema = request["source_schema"].get!string;
    if ("target_schema" in request && request["target_schema"].isString)
        m.targetSchema = request["target_schema"].get!string;
    if ("generation_method" in request && request["generation_method"].isString)
        m.generationMethod = request["generation_method"].get!string;
    if ("mapping_rules" in request)
        m.mappingRules = request["mapping_rules"];
    else
        m.mappingRules = Json.emptyObject;

    m.createdAt = Clock.currTime().toISOExtString();
    m.updatedAt = m.createdAt;
    return m;
}
