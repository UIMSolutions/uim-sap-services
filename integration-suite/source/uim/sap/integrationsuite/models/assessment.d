/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.integrationsuite.models.assessment;

import uim.sap.integrationsuite;

mixin(ShowModule!());

@safe:

class INTAssessment : SAPTenantEntity {
  mixin(SAPTenantEntity!INTAssessment);

  override bool initialize(Json[string] initData) {
    if (!super.initialize(initData)) {
      return false;
    }

    if ("assessment_id" in request && request["assessment_id"].isString) {
      assessmentId = UUID(request["assessment_id"].get!string);
    }
    if ("name" in request && request["name"].isString) {
      name = request["name"].getString;
    }
    if ("description" in request && request["description"].isString) {
      description = request["description"].getString;
    }
    if ("integration_domain" in request && request["integration_domain"].isString) {
      integrationDomain = request["integration_domain"].getString;
    }
    if ("integration_style" in request && request["integration_style"].isString) {
      integrationStyle = request["integration_style"].getString;
    }
    if ("recommended_technology" in request && request["recommended_technology"].isString) {
      recommendedTechnology = request["recommended_technology"].getString;
    }
    if ("status" in request && request["status"].isString) {
      status = request["status"].getString;
    }
    if ("findings" in request) {
      findings = request["findings"];
    }
    if ("assessor" in request && request["assessor"].isString) {
      assessor = request["assessor"].getString;
    }

    a.assessmentId = randomUUID();

    if ("name" in request && request["name"].isString)
      a.name = request["name"].getString;
    if ("description" in request && request["description"].isString)
      a.description = request["description"].getString;
    if ("integration_domain" in request && request["integration_domain"].isString)
      a.integrationDomain = request["integration_domain"].getString;
    if ("integration_style" in request && request["integration_style"].isString)
      a.integrationStyle = request["integration_style"].getString;
    if ("recommended_technology" in request && request["recommended_technology"].isString)
      a.recommendedTechnology = request["recommended_technology"].getString;
    if ("assessor" in request && request["assessor"].isString)
      a.assessor = request["assessor"].getString;
    if ("findings" in request)
      a.findings = request["findings"];
    else
      a.findings = Json.emptyObject;

    a.createdAt = Clock.currTime().toINTOExtString();
    a.updatedAt = a.createdAt;
    return true;
  }

  UUID assessmentId;
  string name;
  string description;
  string integrationDomain = "process"; // process | data | analytics | user | thing
  string integrationStyle = "p2p"; // p2p | hub | bus | mesh
  string recommendedTechnology;
  string status = "draft"; // draft | in_review | approved | archived
  Json findings;
  string assessor;

  override Json toJson() {
    return super.toJson
      .set("assessment_id", assessmentId)
      .set("name", name)
      .set("description", description)
      .set("integration_domain", integrationDomain)
      .set("integration_style", integrationStyle)
      .set("recommended_technology", recommendedTechnology)
      .set("status", status)
      .set("findings", findings)
      .set("assessor", assessor);
  }
}

INTAssessment assessmentFromJson(UUID tenantId, Json request) {
  INTAssessment a = new INTAssessment(request);
  a.tenantId = tenantId;

  return a;
}
