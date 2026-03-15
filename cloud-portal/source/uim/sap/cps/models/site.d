module uim.sap.cps.models.site;

module sap.cps.models.site;

struct CPSSite {
  UUID tenantId;
  UUID siteId;
  string name;
  string design;
  Json pages;
  Json apps;
  Json widgets;
  Json menu;
  SysTime createdAt;
  SysTime updatedAt;

  override Json toJson()  {
    Json info = super.toJson;
    payload["tenant_id"] = tenantId;
    payload["site_id"] = siteId;
    payload["name"] = name;
    payload["design"] = design;
    payload["pages"] = pages;
    payload["apps"] = apps;
    payload["widgets"] = widgets;
    payload["menu"] = menu;
    payload["created_at"] = createdAt.toISOExtString();
    payload["updated_at"] = updatedAt.toISOExtString();
    return payload;
  }
}
