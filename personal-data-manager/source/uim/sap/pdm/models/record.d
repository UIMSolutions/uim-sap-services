/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.pdm.models.record;

import uim.sap.pdm;

mixin(ShowModule!());

@safe:

/// A personal data record — describes what personal data is stored and where
struct PDMPersonalDataRecord {
    string recordId;
    string subjectId;
    string tenantId;

    PDMDataCategory category = PDMDataCategory.identification;
    PDMProcessingPurpose purpose = PDMProcessingPurpose.contractual;
    PDMLegalBasis legalBasis = PDMLegalBasis.gdpr;

    string fieldName;        // e.g. "email", "phone_number", "address"
    string fieldValue;       // the actual personal data value
    string applicationName;  // which application stores this data
    string applicationId;
    string dataStore;        // e.g. "HANA", "PostgreSQL", "S3"

    bool sensitive;          // special category data (health, biometric, etc.)
    string retentionPeriod;  // e.g. "3y", "90d", "indefinite"

    SysTime createdAt;
    SysTime updatedAt;

    Json toJson() const {
        Json j = Json.emptyObject;
        j["record_id"] = recordId;
        j["subject_id"] = subjectId;
        j["tenant_id"] = tenantId;
        j["category"] = cast(string) category;
        j["purpose"] = cast(string) purpose;
        j["legal_basis"] = cast(string) legalBasis;
        j["field_name"] = fieldName;
        j["field_value"] = fieldValue;
        j["application_name"] = applicationName;
        j["application_id"] = applicationId;
        j["data_store"] = dataStore;
        j["sensitive"] = sensitive;
        j["retention_period"] = retentionPeriod;
        j["created_at"] = createdAt.toISOExtString();
        j["updated_at"] = updatedAt.toISOExtString();
        return j;
    }

    /// Redacted version — hides the actual field value
    Json toRedactedJson() const {
        Json j = toJson();
        j["field_value"] = "***REDACTED***";
        return j;
    }
}

PDMPersonalDataRecord recordFromJson(string recordId, string subjectId, string tenantId, Json req) {
    PDMPersonalDataRecord r;
    r.recordId = recordId;
    r.subjectId = subjectId;
    r.tenantId = tenantId;
    r.createdAt = Clock.currTime();
    r.updatedAt = r.createdAt;

    if ("category" in req && req["category"].isString)
        r.category = parseDataCategory(req["category"].get!string);
    if ("purpose" in req && req["purpose"].isString)
        r.purpose = parseProcessingPurpose(req["purpose"].get!string);
    if ("legal_basis" in req && req["legal_basis"].isString)
        r.legalBasis = parseLegalBasis(req["legal_basis"].get!string);
    if ("field_name" in req && req["field_name"].isString)
        r.fieldName = req["field_name"].get!string;
    if ("field_value" in req && req["field_value"].isString)
        r.fieldValue = req["field_value"].get!string;
    if ("application_name" in req && req["application_name"].isString)
        r.applicationName = req["application_name"].get!string;
    if ("application_id" in req && req["application_id"].isString)
        r.applicationId = req["application_id"].get!string;
    if ("data_store" in req && req["data_store"].isString)
        r.dataStore = req["data_store"].get!string;
    if ("sensitive" in req && req["sensitive"].type == Json.Type.bool_)
        r.sensitive = req["sensitive"].get!bool;
    if ("retention_period" in req && req["retention_period"].isString)
        r.retentionPeriod = req["retention_period"].get!string;

    return r;
}

private PDMDataCategory parseDataCategory(string s) {
    switch (s) {
        case "identification": return PDMDataCategory.identification;
        case "contact": return PDMDataCategory.contact;
        case "financial": return PDMDataCategory.financial;
        case "health": return PDMDataCategory.health;
        case "behavioral": return PDMDataCategory.behavioral;
        case "technical": return PDMDataCategory.technical;
        case "location": return PDMDataCategory.location;
        case "biometric": return PDMDataCategory.biometric;
        case "genetic": return PDMDataCategory.genetic;
        default: return PDMDataCategory.identification;
    }
}

private PDMProcessingPurpose parseProcessingPurpose(string s) {
    switch (s) {
        case "contractual": return PDMProcessingPurpose.contractual;
        case "legal": return PDMProcessingPurpose.legal;
        case "consent": return PDMProcessingPurpose.consent;
        case "legitimate_interest": return PDMProcessingPurpose.legitimateInterest;
        case "vital_interest": return PDMProcessingPurpose.vitalInterest;
        case "public_interest": return PDMProcessingPurpose.publicInterest;
        default: return PDMProcessingPurpose.contractual;
    }
}

private PDMLegalBasis parseLegalBasis(string s) {
    switch (s) {
        case "GDPR": return PDMLegalBasis.gdpr;
        case "CCPA": return PDMLegalBasis.ccpa;
        case "LGPD": return PDMLegalBasis.lgpd;
        case "PDPA": return PDMLegalBasis.pdpa;
        case "PIPA": return PDMLegalBasis.pipa;
        case "custom": return PDMLegalBasis.custom;
        default: return PDMLegalBasis.gdpr;
    }
}
