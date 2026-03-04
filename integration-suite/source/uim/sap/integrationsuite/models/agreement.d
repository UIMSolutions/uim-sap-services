/**
 * Agreement model — Trading Partner Management
 *
 * Represents a B2B agreement between an organization and a trading partner.
 */
module uim.sap.integrationsuite.models.agreement;

import uim.sap.integrationsuite;

mixin(ShowModule!());

@safe:

struct ISAgreement {
    string tenantId;
    string agreementId;
    string partnerId;
    string name;
    string description;
    string documentStandard = "EDIFACT";  // EDIFACT | X12 | cXML | SAP IDoc
    string direction = "outbound";         // inbound | outbound | bidirectional
    string status = "draft";               // draft | active | suspended | terminated
    string validFrom;
    string validTo;
    long transactionCount = 0;
    string createdAt;
    string updatedAt;

    Json toJson() const {
        Json j = Json.emptyObject;
        j["tenant_id"] = tenantId;
        j["agreement_id"] = agreementId;
        j["partner_id"] = partnerId;
        j["name"] = name;
        j["description"] = description;
        j["document_standard"] = documentStandard;
        j["direction"] = direction;
        j["status"] = status;
        j["valid_from"] = validFrom;
        j["valid_to"] = validTo;
        j["transaction_count"] = transactionCount;
        j["created_at"] = createdAt;
        j["updated_at"] = updatedAt;
        return j;
    }
}

ISAgreement agreementFromJson(string tenantId, Json request) {
    ISAgreement a;
    a.tenantId = tenantId;
    a.agreementId = randomUUID().toString();

    if ("partner_id" in request && request["partner_id"].type == Json.Type.string)
        a.partnerId = request["partner_id"].get!string;
    if ("name" in request && request["name"].type == Json.Type.string)
        a.name = request["name"].get!string;
    if ("description" in request && request["description"].type == Json.Type.string)
        a.description = request["description"].get!string;
    if ("document_standard" in request && request["document_standard"].type == Json.Type.string)
        a.documentStandard = request["document_standard"].get!string;
    if ("direction" in request && request["direction"].type == Json.Type.string)
        a.direction = request["direction"].get!string;
    if ("valid_from" in request && request["valid_from"].type == Json.Type.string)
        a.validFrom = request["valid_from"].get!string;
    if ("valid_to" in request && request["valid_to"].type == Json.Type.string)
        a.validTo = request["valid_to"].get!string;

    a.createdAt = Clock.currTime().toISOExtString();
    a.updatedAt = a.createdAt;
    return a;
}
