/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.integrationsuite.models.assessment;

import uim.sap.integrationsuite;

mixin(ShowModule!());

@safe:

struct ISAssessment {
    string tenantId;
    string assessmentId;
    string name;
    string description;
    string integrationDomain = "process";  // process | data | analytics | user | thing
    string integrationStyle = "p2p";       // p2p | hub | bus | mesh
    string recommendedTechnology;
    string status = "draft";               // draft | in_review | approved | archived
    Json findings;
    string assessor;
    string createdAt;
    string updatedAt;

    Json toJson() const {
        Json j = Json.emptyObject;
        j["tenant_id"] = tenantId;
        j["assessment_id"] = assessmentId;
        j["name"] = name;
        j["description"] = description;
        j["integration_domain"] = integrationDomain;
        j["integration_style"] = integrationStyle;
        j["recommended_technology"] = recommendedTechnology;
        j["status"] = status;
        j["findings"] = findings;
        j["assessor"] = assessor;
        j["created_at"] = createdAt;
        j["updated_at"] = updatedAt;
        return j;
    }
}

ISAssessment assessmentFromJson(string tenantId, Json request) {
    ISAssessment a;
    a.tenantId = tenantId;
    a.assessmentId = randomUUID().toString();

    if ("name" in request && request["name"].isString)
        a.name = request["name"].get!string;
    if ("description" in request && request["description"].isString)
        a.description = request["description"].get!string;
    if ("integration_domain" in request && request["integration_domain"].isString)
        a.integrationDomain = request["integration_domain"].get!string;
    if ("integration_style" in request && request["integration_style"].isString)
        a.integrationStyle = request["integration_style"].get!string;
    if ("recommended_technology" in request && request["recommended_technology"].isString)
        a.recommendedTechnology = request["recommended_technology"].get!string;
    if ("assessor" in request && request["assessor"].isString)
        a.assessor = request["assessor"].get!string;
    if ("findings" in request)
        a.findings = request["findings"];
    else
        a.findings = Json.emptyObject;

    a.createdAt = Clock.currTime().toISOExtString();
    a.updatedAt = a.createdAt;
    return a;
}
