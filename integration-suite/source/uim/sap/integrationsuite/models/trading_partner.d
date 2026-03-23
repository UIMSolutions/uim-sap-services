/**
 * Trading Partner model — Trading Partner Management
 *
 * Represents a B2B trading partner profile.
 */
module uim.sap.integrationsuite.models.trading_partner;

import uim.sap.integrationsuite;

mixin(ShowModule!());

@safe:

struct INTTradingPartner {
  UUID tenantId;
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
  string createdAt;
  string updatedAt;

  override Json toJson() {
    return super.toJson()
      .set("tenant_id", tenantId)
      .set("partner_id", partnerId)
      .set("name", name)
      .set("description", description)
      .set("partner_type", partnerType)
      .set("identifier_type", identifierType)
      .set("identifier", identifier)
      .set("contact_email", contactEmail)
      .set("contact_phone", contactPhone)
      .set("status", status)
      .set("agreement_count", agreementCount)
      .set("created_at", createdAt)
      .set("updated_at", updatedAt);
  }
}

INTTradingPartner tradingPartnerFromJson(UUID tenantId, Json request) {
  INTTradingPartner tp;
  tp.tenantId = tenantId;
  tp.partnerId = randomUUID().toString();

  if ("name" in request && request["name"].isString)
    tp.name = request["name"].get!string;
  if ("description" in request && request["description"].isString)
    tp.description = request["description"].get!string;
  if ("partner_type" in request && request["partner_type"].isString)
    tp.partnerType = request["partner_type"].get!string;
  if ("identifier_type" in request && request["identifier_type"].isString)
    tp.identifierType = request["identifier_type"].get!string;
  if ("identifier" in request && request["identifier"].isString)
    tp.identifier = request["identifier"].get!string;
  if ("contact_email" in request && request["contact_email"].isString)
    tp.contactEmail = request["contact_email"].get!string;
  if ("contact_phone" in request && request["contact_phone"].isString)
    tp.contactPhone = request["contact_phone"].get!string;

  tp.createdAt = Clock.currTime().toINTOExtString();
  tp.updatedAt = tp.createdAt;
  return tp;
}
