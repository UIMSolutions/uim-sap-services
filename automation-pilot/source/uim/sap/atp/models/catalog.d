module uim.sap.atp.models.catalog;

import uim.sap.atp;

mixin(ShowModule!());

@safe:

struct ATPCatalog {
  string tenantId;
  string catalogId;
  string name;
  string scenario;
  bool predefined;
  string[] commandIds;
  SysTime createdAt;
  SysTime updatedAt;

  override Json toJson()  {
    Json info = super.toJson;
    payload["tenant_id"] = tenantId;
    payload["catalog_id"] = catalogId;
    payload["name"] = name;
    payload["scenario"] = scenario;
    payload["predefined"] = predefined;
    Json commands = Json.emptyArray;
    foreach (id; commandIds)
      commands ~= id;
    payload["command_ids"] = commands;
    payload["created_at"] = createdAt.toISOExtString();
    payload["updated_at"] = updatedAt.toISOExtString();
    return payload;
  }
}
