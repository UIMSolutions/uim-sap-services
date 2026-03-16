module uim.sap.cdc.models.auth_event;

import uim.sap.cdc;

mixin(ShowModule!());

@safe:

struct CDCAuthEvent {
  string tenantId;
  string eventId;
  string userId;
  string providerId;
  string ipAddress;
  string decision;
  string riskLevel;
  long riskScore;
  Json providerSignals;
  SysTime createdAt;

  override Json toJson()  {
    Json info = super.toJson;
    payload["tenant_id"] = tenantId;
    payload["event_id"] = eventId;
    payload["user_id"] = userId;
    payload["provider_id"] = providerId;
    payload["ip_address"] = ipAddress;
    payload["decision"] = decision;
    payload["risk_level"] = riskLevel;
    payload["risk_score"] = riskScore;
    payload["provider_signals"] = providerSignals;
    payload["created_at"] = createdAt.toISOExtString();
    return payload;
  }
}
