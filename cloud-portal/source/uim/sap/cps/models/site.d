module uim.sap.cps.models.site;

import uim.sap.cps;

mixin(ShowModule!());

@safe:

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

CPSSite siteFromJson(UUID tenantId, Json request, string defaultTheme) {
  CPSSite site;
  site.tenantId = UUID(tenantId);
  site.siteId = createId();
  site.design = defaultTheme;
  site.pages = Json.emptyArray;
  site.apps = Json.emptyArray;
  site.widgets = Json.emptyArray;
  site.menu = Json.emptyArray;
  site.createdAt = Clock.currTime();
  site.updatedAt = site.createdAt;

  if ("site_id" in request && request["site_id"].isString)
    site.siteId = request["site_id"].get!string;
  if ("name" in request && request["name"].isString)
    site.name = request["name"].get!string;
  if ("design" in request && request["design"].isString)
    site.design = request["design"].get!string;
  if ("pages" in request && request["pages"].isArray)
    site.pages = request["pages"];
  if ("apps" in request && request["apps"].isArray)
    site.apps = request["apps"];
  if ("widgets" in request && request["widgets"].isArray)
    site.widgets = request["widgets"];
  if ("menu" in request && request["menu"].isArray)
    site.menu = request["menu"];
  return site;
}
