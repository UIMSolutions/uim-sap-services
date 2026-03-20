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
struct PDMDataUsage {
  string usageId;
  string subjectId;
  UUID tenantId;

  string applicationName;
  string applicationId;
  PDMDataCategory dataCategory = PDMDataCategory.identification;
  PDMProcessingPurpose purpose = PDMProcessingPurpose.contractual;
  PDMLegalBasis legalBasis = PDMLegalBasis.gdpr;

  string description; // human-readable description of usage
  string retentionPeriod;
  bool active = true;

  SysTime firstUsedAt;
  SysTime lastAccessedAt;
  SysTime createdAt;

  override Json toJson()  {
    Json j = Json.emptyObject;
    j["usage_id"] = usageId;
    j["subject_id"] = subjectId;
    j["tenant_id"] = tenantId;
    j["application_name"] = applicationName;
    j["application_id"] = applicationId;
    j["data_category"] = cast(string)dataCategory;
    j["purpose"] = cast(string)purpose;
    j["legal_basis"] = cast(string)legalBasis;
    j["description"] = description;
    j["retention_period"] = retentionPeriod;
    j["active"] = active;
    j["first_used_at"] = firstUsedAt.toISOExtString();
    j["last_accessed_at"] = lastAccessedAt.toISOExtString();
    j["created_at"] = createdAt.toISOExtString();
    return j;
  }
}

PDMDataUsage usageFromJson(string usageId, string subjectId, string tenantId, Json req) {
  PDMDataUsage u;
  u.usageId = usageId;
  u.subjectId = subjectId;
  u.tenantId = UUID(tenantId);
  u.createdAt = Clock.currTime();
  u.firstUsedAt = u.createdAt;
  u.lastAccessedAt = u.createdAt;

  if ("application_name" in req && req["application_name"].isString)
    u.applicationName = req["application_name"].get!string;
  if ("application_id" in req && req["application_id"].isString)
    u.applicationId = req["application_id"].get!string;
  if ("data_category" in req && req["data_category"].isString)
    u.dataCategory = parseDataCat(req["data_category"].get!string);
  if ("purpose" in req && req["purpose"].isString)
    u.purpose = parsePurpose(req["purpose"].get!string);
  if ("legal_basis" in req && req["legal_basis"].isString)
    u.legalBasis = parseBasis(req["legal_basis"].get!string);
  if ("description" in req && req["description"].isString)
    u.description = req["description"].get!string;
  if ("retention_period" in req && req["retention_period"].isString)
    u.retentionPeriod = req["retention_period"].get!string;

  return u;
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
