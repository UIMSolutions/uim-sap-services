module uim.sap.cag.models.provider;

import uim.sap.cag;

mixin(ShowModule!());

@safe:

class CAGContentProvider : SAPTenantEntity {
  mixin(SAPTenantEntityTemplate!CAGContentProvider);

  UUID providerId;
  string name;
  string providerType;
  string endpoint;
  string[] supportedTypes;
  bool active;

  override Json toJson() {
    auto types = supportedTypes.map!(type => type).array; // Convert string[] to Json array

    return super.toJson()
      .set("provider_id", providerId)
      .set("name", name)
      .set("provider_type", providerType)
      .set("endpoint", endpoint)
      .set("supported_types", types)
      .set("active", active);
  }
}


