module uim.sap.cdc.models.risk_provider;

import std.datetime : SysTime;

import vibe.data.json : Json;

@safe:

struct CDCRiskProvider {
  string tenantId;
  string providerId;
  string name;
  string providerKind;
  bool enabled = true;
  Json config;
  SysTime createdAt;
  SysTime updatedAt;

  Json toJson() const {
    Json payload = Json.emptyObject;
    payload["tenant_id"] = tenantId;
    payload["provider_id"] = providerId;
    payload["name"] = name;
    payload["provider_kind"] = providerKind;
    payload["enabled"] = enabled;
    payload["config"] = config;
    payload["created_at"] = createdAt.toISOExtString();
    payload["updated_at"] = updatedAt.toISOExtString();
    return payload;
  }
}
