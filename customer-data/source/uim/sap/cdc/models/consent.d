module uim.sap.cdc.models.consent;

import uim.sap.cdc;

mixin(ShowModule!());

@safe:

class CDCConsent : SAPTenantObject {
  mixin(SAPObjectTemplate!CDCConsent);

  UUID userId;
  UUID consentId;
  string purpose;
  string legalBasis;
  string status;
  string source;
  string language;

  override Json toJson()  {
    Json info = super.toJson
      .set("user_id", userId)
      .set("consent_id", consentId)
      .set("purpose", purpose)
      .set("legal_basis", legalBasis)
      .set("status", status)
      .set("source", source)
      .set("language", language);
  }
}
