module uim.sap.atp.models.catalog;

import uim.sap.atp;

mixin(ShowModule!());

@safe:

class ATPCatalog : SAPTenantObject {
  mixin(SAPObjectTemplate!ATPCatalog);
  
  UUID catalogId;
  string name;
  string scenario;
  bool predefined;
  UUID[] commandIds;

  override Json toJson()  {
    Json commands = commandIds.map!(id => id.toString()).array.toJson;

    return super.toJson()
      .set("tenant_id", tenantId)
      .set("catalog_id", catalogId)
      .set("name", name)
      .set("scenario", scenario)
      .set("predefined", predefined)
      .set("command_ids", commands);
  }
}
