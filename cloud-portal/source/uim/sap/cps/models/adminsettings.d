module uim.sap.cps.models.adminsettings;

struct CPSAdminSettings {
  string tenantId;
  Json themes;
  Json transports;
  Json translations;
  Json templates;
  Json extensions;
  SysTime updatedAt;

  Json toJson() const {
    Json payload = Json.emptyObject;
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