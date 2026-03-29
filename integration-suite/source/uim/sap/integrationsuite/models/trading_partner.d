/**
 * Trading Partner model — Trading Partner Management
 *
 * Represents a B2B trading partner profile.
 */
module uim.sap.integrationsuite.models.trading_partner;

import uim.sap.integrationsuite;

mixin(ShowModule!());

@safe:

class INTTradingPartner : SAPTenantEntity {
  mixin(SAPTenantEntity!INTTradingPartner);

  override bool initialize(Json[string] initData) {
    if (!super.initialize(initData)) {
      return false;
    }

    if ("name" in request && request["name"].isString) {
      name = request["name"].getString;
    }
    if ("description" in request && request["description"].isString) {
      description = request["description"].getString;
    }
    if ("partner_type" in request && request["partner_type"].isString) {
      partnerType = request["partner_type"].getString;
    }
    if ("identifier_type" in request && request["identifier_type"].isString) {
      identifierType = request["identifier_type"].getString;
    }
    if ("identifier" in request && request["identifier"].isString) {
      identifier = request["identifier"].getString;
    }
    if ("contact_email" in request && request["contact_email"].isString) {
      contactEmail = request["contact_email"].getString;
    }
    if ("contact_phone" in request && request["contact_phone"].isString) {
      contactPhone = request["contact_phone"].getString;
    }

    return true;
  }

  UUID partnerId;
  string name;
  string description;
  string partnerType = "supplier"; // supplier | customer | logistics | bank
  string identifierType = "DUNS"; // DUNS | GLN | VAT | custom
  string identifier;
  string contactEmail;
  string contactPhone;
  string status = "active"; // active | inactive | suspended
  long agreementCount = 0;

  override Json toJson() {
    return super.toJson()
      .set("partner_id", partnerId)
      .set("name", name)
      .set("description", description)
      .set("partner_type", partnerType)
      .set("identifier_type", identifierType)
      .set("identifier", identifier)
      .set("contact_email", contactEmail)
      .set("contact_phone", contactPhone)
      .set("status", status)
      .set("agreement_count", agreementCount);
  }
}

INTTradingPartner tradingPartnerFromJson(UUID tenantId, Json request) {
  INTTradingPartner tp = new INTTradingPartner(request);
  tp.tenantId = tenantId;
  tp.partnerId = randomUUID();

  tp.createdAt = Clock.currTime().toINTOExtString();
  tp.updatedAt = tp.createdAt;
  return tp;
}
