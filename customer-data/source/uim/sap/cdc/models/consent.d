module uim.sap.cdc.models.consent;

import std.datetime : SysTime;

import vibe.data.json : Json;

@safe:

struct CDCConsent {
  string tenantId;
  string userId;
  string consentId;
  string purpose;
  string legalBasis;
  string status;
  string source;
  string language;
  SysTime updatedAt;

  override Json toJson()  {
    Json info = super.toJson;
    payload["tenant_id"] = tenantId;
    payload["user_id"] = userId;
    payload["consent_id"] = consentId;
    payload["purpose"] = purpose;
    payload["legal_basis"] = legalBasis;
    payload["status"] = status;
    payload["source"] = source;
    payload["language"] = language;
    payload["updated_at"] = updatedAt.toISOExtString();
    return payload;
  }
}
