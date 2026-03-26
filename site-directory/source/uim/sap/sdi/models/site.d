module uim.sap.sdi.models.site;

import uim.sap.sdi;

mixin(ShowModule!());

@safe:

struct SDISite {
  UUID tenantId;
  UUID siteId;
  string name;
  string description;
  string siteAlias;
  string runtimeUrl;
  bool isDefault;
  string[] roles;
  SDISiteSettings settings;
  Json importBundle;
  SysTime createdAt;
  SysTime updatedAt;

  override Json toJson()  {
    Json roleValues = Json.emptyArray;
    foreach (role; roles)
      roleValues ~= role;

    return super.toJson
    .set("tenant_id", tenantId)
    .set("site_id", siteId)
    .set("name", name)
    .set("description", description)
    .set("alias", siteAlias)
    .set("runtime_url", runtimeUrl)
    .set("is_default", isDefault)
    .set("roles", roleValues)
    .set("settings", settings.toJson())
    .set("created_at", createdAt.toISOExtString())
    .set("updated_at", updatedAt.toISOExtString());
  }

  Json toTileJson() const {
    return Json.emptyObject
      .set("site_id", siteId)
      .set("title", name)
      .set("alias", siteAlias)
      .set("runtime_url", runtimeUrl)
      .set("is_default", isDefault)
      .set("role_count", cast(long)roles.length);
  }
}