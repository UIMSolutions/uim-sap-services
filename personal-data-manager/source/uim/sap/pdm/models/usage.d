/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.pdm.models.usage;

import uim.sap.pdm;

mixin(ShowModule!());

@safe:

/**
  * Represents a specific usage of personal data, e.g. for a specific application or processing activity.
  * This is used to track how personal data is being used across different applications and purposes.
  *
  * The PDMDataUsage struct captures details about the usage, including the application, data category, purpose, legal basis, and timestamps.
  * It also provides a toJson method for easy serialization to JSON format, and a usageFromJson function to create an instance from JSON input.
  *
  * The dataCategory, purpose, and legalBasis fields use enumerations defined in the uim.sap.pdm.enumerations module to ensure consistent values.
  *
  * Example usage:
  * ```
  * PDMDataUsage usage;
  * usage.usageId = "usage123";
  * usage.subjectId = "subject456";
  * usage.tenantId = "tenant789"; 
  * usage.applicationName = "Example App";
  * usage.applicationId = "app123";
  * usage.dataCategory = PDMDataCategory.contact;
  * usage.purpose = PDMProcessingPurpose.consent;
  * usage.legalBasis = PDMLegalBasis.gdpr;
  * usage.description = "Used for sending marketing emails";
  * usage.retentionPeriod = "2 years";
  * usage.firstUsedAt = Clock.currTime();
  * usage.lastAccessedAt = Clock.currTime();
  * usage.createdAt = Clock.currTime();
  * ```
  */
class PDMDataUsage : SAPTenantEntity {
  mixin(SAPTenantEntityTemplate!PDMDataUsage);

  UUID usageId;
  UUID subjectId;

  string applicationName;
  UUID applicationId;
  PDMDataCategory dataCategory = PDMDataCategory.identification;
  PDMProcessingPurpose purpose = PDMProcessingPurpose.contractual;
  PDMLegalBasis legalBasis = PDMLegalBasis.gdpr;

  string description; // human-readable description of usage
  string retentionPeriod;
  bool active = true;

  SysTime firstUsedAt;
  SysTime lastAccessedAt;

  override Json toJson() {
    return super.toJson()
      .set("usage_id", usageId)
      .set("subject_id", subjectId)
      .set("application_name", applicationName)
      .set("application_id", applicationId)
      .set("data_category", cast(string)dataCategory)
      .set("purpose", cast(string)purpose)
      .set("legal_basis", cast(string)legalBasis)
      .set("description", description)
      .set("retention_period", retentionPeriod)
      .set("active", active)
      .set("first_used_at", firstUsedAt.toISOExtString())
      .set("last_accessed_at", lastAccessedAt.toISOExtString());
  }

  static PDMDataUsage opCall(UUID usageId, UUID subjectId, UUID tenantId, Json req) {
    PDMDataUsage u = new PDMDataUsage(req);
    u.usageId = usageId;
    u.subjectId = subjectId;
    u.tenantId = tenantId;
    u.createdAt = Clock.currTime();
    u.firstUsedAt = u.createdAt;
    u.lastAccessedAt = u.createdAt;

    if ("application_name" in req && req["application_name"].isString)
      u.applicationName = req["application_name"].getString;
    if ("application_id" in req && req["application_id"].isString)
      u.applicationId = UUID(req["application_id"].get!string);
    if ("data_category" in req && req["data_category"].isString)
      u.dataCategory = parseDataCat(req["data_category"].get!string);
    if ("purpose" in req && req["purpose"].isString)
      u.purpose = parsePurpose(req["purpose"].get!string);
    if ("legal_basis" in req && req["legal_basis"].isString)
      u.legalBasis = parseBasis(req["legal_basis"].get!string);
    if ("description" in req && req["description"].isString)
      u.description = req["description"].getString;
    if ("retention_period" in req && req["retention_period"].isString)
      u.retentionPeriod = req["retention_period"].getString;

    return u;
  }
}

private PDMDataCategory parseDataCat(string s) {
  switch (s) {
  case "identification":
    return PDMDataCategory.identification;
  case "contact":
    return PDMDataCategory.contact;
  case "financial":
    return PDMDataCategory.financial;
  case "health":
    return PDMDataCategory.health;
  case "behavioral":
    return PDMDataCategory.behavioral;
  case "technical":
    return PDMDataCategory.technical;
  case "location":
    return PDMDataCategory.location;
  default:
    return PDMDataCategory.identification;
  }
}

private PDMProcessingPurpose parsePurpose(string s) {
  switch (s) {
  case "contractual":
    return PDMProcessingPurpose.contractual;
  case "legal":
    return PDMProcessingPurpose.legal;
  case "consent":
    return PDMProcessingPurpose.consent;
  case "legitimate_interest":
    return PDMProcessingPurpose.legitimateInterest;
  default:
    return PDMProcessingPurpose.contractual;
  }
}

private PDMLegalBasis parseBasis(string s) {
  switch (s) {
  case "GDPR":
    return PDMLegalBasis.gdpr;
  case "CCPA":
    return PDMLegalBasis.ccpa;
  case "LGPD":
    return PDMLegalBasis.lgpd;
  default:
    return PDMLegalBasis.gdpr;
  }
}
