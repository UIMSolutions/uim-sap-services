module uim.sap.cdc.models.auth_event;

import std.datetime : SysTime;

import vibe.data.json : Json;

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

  Json toJson() const {
    Json payload = Json.emptyObject;
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
