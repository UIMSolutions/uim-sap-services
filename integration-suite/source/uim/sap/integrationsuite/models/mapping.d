/**
 * Mapping model — Integration Advisor
 *
 * Represents an interface/mapping definition designed via crowdsourcing or ML.
 */
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

    if ("name" in request && request["name"].type == Json.Type.string)
        m.name = request["name"].get!string;
    if ("description" in request && request["description"].type == Json.Type.string)
        m.description = request["description"].get!string;
    if ("source_format" in request && request["source_format"].type == Json.Type.string)
        m.sourceFormat = request["source_format"].get!string;
    if ("target_format" in request && request["target_format"].type == Json.Type.string)
        m.targetFormat = request["target_format"].get!string;
    if ("source_schema" in request && request["source_schema"].type == Json.Type.string)
        m.sourceSchema = request["source_schema"].get!string;
    if ("target_schema" in request && request["target_schema"].type == Json.Type.string)
        m.targetSchema = request["target_schema"].get!string;
    if ("generation_method" in request && request["generation_method"].type == Json.Type.string)
        m.generationMethod = request["generation_method"].get!string;
    if ("mapping_rules" in request)
        m.mappingRules = request["mapping_rules"];
    else
        m.mappingRules = Json.emptyObject;

    m.createdAt = Clock.currTime().toISOExtString();
    m.updatedAt = m.createdAt;
    return m;
}
