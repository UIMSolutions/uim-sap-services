module uim.sap.cps.models.site;

module sap.cps.models.site;

struct CPSSite {
  string tenantId;
  string siteId;
  string name;
  string design;
  Json pages;
  Json apps;
  Json widgets;
  Json menu;
  SysTime createdAt;
  SysTime updatedAt;

  Json toJson() const {
    Json payload = Json.emptyObject;
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
