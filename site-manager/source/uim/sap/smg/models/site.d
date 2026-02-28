module uim.sap.smg.models.site;

struct SMGSite {
  string tenantId;
  string siteId;
  string siteName;
  string description;
  string lifecycle;
  string[] assignedRoles;
  string[] pages;
  string[] catalogs;
  SysTime createdAt;
  SysTime updatedAt;

  Json toJson() const {
    Json payload = Json.emptyObject;
    payload["tenant_id"] = tenantId;
    payload["site_id"] = siteId;
    payload["site_name"] = siteName;
    payload["description"] = description;
    payload["lifecycle"] = lifecycle;
    Json assignedRoleValues = Json.emptyArray;
    foreach (role; assignedRoles)
      assignedRoleValues ~= role;
    payload["assigned_roles"] = assignedRoleValues;

    Json pageValues = Json.emptyArray;
    foreach (page; pages)
      pageValues ~= page;
    payload["pages"] = pageValues;

    Json catalogValues = Json.emptyArray;
    foreach (catalog; catalogs)
      catalogValues ~= catalog;
    payload["catalogs"] = catalogValues;
    payload["created_at"] = createdAt.toISOExtString();
    payload["updated_at"] = updatedAt.toISOExtString();
    return payload;
  }
}
