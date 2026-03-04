/**
 * Trading Partner model — Trading Partner Management
 *
 * Represents a B2B trading partner profile.
 */
module uim.sap.integrationsuite.models.trading_partner;

import uim.sap.integrationsuite;

mixin(ShowModule!());

@safe:

struct ISTradingPartner {
    string tenantId;
    string partnerId;
    string name;
    string description;
    string partnerType = "supplier";  // supplier | customer | logistics | bank
    string identifierType = "DUNS";   // DUNS | GLN | VAT | custom
    string identifier;
    string contactEmail;
    string contactPhone;
    string status = "active";         // active | inactive | suspended
    long agreementCount = 0;
    string createdAt;
    string updatedAt;

    Json toJson() const {
        Json j = Json.emptyObject;
        j["tenant_id"] = tenantId;
        j["partner_id"] = partnerId;
        j["name"] = name;
        j["description"] = description;
        j["partner_type"] = partnerType;
        j["identifier_type"] = identifierType;
        j["identifier"] = identifier;
        j["contact_email"] = contactEmail;
        j["contact_phone"] = contactPhone;
        j["status"] = status;
        j["agreement_count"] = agreementCount;
        j["created_at"] = createdAt;
        j["updated_at"] = updatedAt;
        return j;
    }
}

ISTradingPartner tradingPartnerFromJson(string tenantId, Json request) {
    ISTradingPartner tp;
    tp.tenantId = tenantId;
    tp.partnerId = randomUUID().toString();

    if ("name" in request && request["name"].type == Json.Type.string)
        tp.name = request["name"].get!string;
    if ("description" in request && request["description"].type == Json.Type.string)
        tp.description = request["description"].get!string;
    if ("partner_type" in request && request["partner_type"].type == Json.Type.string)
        tp.partnerType = request["partner_type"].get!string;
    if ("identifier_type" in request && request["identifier_type"].type == Json.Type.string)
        tp.identifierType = request["identifier_type"].get!string;
    if ("identifier" in request && request["identifier"].type == Json.Type.string)
        tp.identifier = request["identifier"].get!string;
    if ("contact_email" in request && request["contact_email"].type == Json.Type.string)
        tp.contactEmail = request["contact_email"].get!string;
    if ("contact_phone" in request && request["contact_phone"].type == Json.Type.string)
        tp.contactPhone = request["contact_phone"].get!string;

    tp.createdAt = Clock.currTime().toISOExtString();
    tp.updatedAt = tp.createdAt;
    return tp;
}
