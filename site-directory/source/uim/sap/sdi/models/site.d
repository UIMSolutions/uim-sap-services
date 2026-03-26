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
    Json info = super.toJson;
    payload["tenant_id"] = tenantId;
    payload["site_id"] = siteId;
    payload["name"] = name;
    payload["description"] = description;
    payload["alias"] = siteAlias;
    payload["runtime_url"] = runtimeUrl;
    payload["is_default"] = isDefault;

    Json roleValues = Json.emptyArray;
    foreach (role; roles)
      roleValues ~= role;
    payload["roles"] = roleValues;

    payload["settings"] = settings.toJson();
    payload["created_at"] = createdAt.toISOExtString();
    payload["updated_at"] = updatedAt.toISOExtString();
    return payload;
  }

  Json toTileJson() const {
    Json payload = Json.emptyObject;
    payload["site_id"] = siteId;
    payload["title"] = name;
    payload["alias"] = siteAlias;
    payload["runtime_url"] = runtimeUrl;
    payload["is_default"] = isDefault;
    payload["role_count"] = cast(long)roles.length;
    return payload;
  }
}