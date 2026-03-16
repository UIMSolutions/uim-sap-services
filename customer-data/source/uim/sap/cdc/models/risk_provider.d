module uim.sap.cdc.models.risk_provider;

import uim.sap.cdc;

mixin(ShowModule!());

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

  override Json toJson()  {
    Json info = super.toJson;
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
