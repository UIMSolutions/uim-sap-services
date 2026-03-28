module uim.sap.mdi.models.extension;

import uim.sap.mdi;

mixin(ShowModule!());

@safe:
class MDIExtension : SAPTenantObject {
  mixin(SAPTenantObjectTemplate!MDIExtension);

  UUID extensionId;
  string objectType;
  Json fields;
  Json entities;

  override Json toJson()  {
    return super.toJson
      .set("extension_id", extensionId)
      .set("object_type", objectType)
      .set("fields", fields)
      .set("entities", entities);
  }
}
