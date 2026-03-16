module uim.sap.cps.models.adminsettings;
import uim.sap.cps;

mixin(ShowModule!());

@safe:
struct CPSAdminSettings {
  string tenantId;
  Json themes;
  Json transports;
  Json translations;
  Json templates;
  Json extensions;
  SysTime updatedAt;

  override Json toJson()  {
    Json info = super.toJson;
    payload["tenant_id"] = tenantId;
    payload["themes"] = themes;
    payload["transports"] = transports;
    payload["translations"] = translations;
    payload["templates"] = templates;
    payload["extensions"] = extensions;
    payload["updated_at"] = updatedAt.toISOExtString();
    return payload;
  }
}