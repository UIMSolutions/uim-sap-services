module uim.sap.mdi.models.extension;

import uim.sap.mdi;

mixin(ShowModule!());

@safe:
struct MDIExtension {
  string tenantId;
  string extensionId;
  string objectType;
  Json fields;
  Json entities;
  SysTime updatedAt;

  override Json toJson()  {
    Json info = super.toJson;
    payload["tenant_id"] = tenantId;
    payload["extension_id"] = extensionId;
    payload["object_type"] = objectType;
    payload["fields"] = fields;
    payload["entities"] = entities;
    payload["updated_at"] = updatedAt.toISOExtString();
    return payload;
  }
}
