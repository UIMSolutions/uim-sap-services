module uim.sap.cdc.models.risk_provider;

import uim.sap.cdc;

mixin(ShowModule!());

@safe:

class CDCRiskProvider : SAPTenantObject {
  mixin(SAPObjectTemplate!CDCRiskProivider);

  UUID providerId;
  string name;
  string providerKind;
  bool enabled = true;
  Json config;

  override Json toJson()  {
    return super.toJson
      .set("provider_id", providerId)
      .set("name", name)
      .set("provider_kind", providerKind)
      .set("enabled", enabled)
      .set("config", config);
  }
}
