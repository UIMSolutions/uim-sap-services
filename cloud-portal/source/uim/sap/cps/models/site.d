module uim.sap.cps.models.site;

import uim.sap.cps;

mixin(ShowModule!());

@safe:

class CPSSite : SAPTenantObject {
  mixin(SAPTenantObjectTemplate!CPSSite);

  UUID siteId;
  string name;
  string design;
  Json pages;
  Json apps;
  Json widgets;
  Json menu;

  override Json toJson() {
    return super.toJson()
      .set("site_id", siteId)
      .set("name", name)
      .set("design", design)
      .set("pages", pages)
      .set("apps", apps)
      .set("widgets", widgets)
      .set("menu", menu);
  }

  static CPSSite siteFromJson(UUID tenantId, Json request, string defaultTheme) {
    CPSSite site = new CPSSite(request);
    site.tenantId = tenantId;
    site.siteId = createId();
    site.design = defaultTheme;
    site.pages = Json.emptyArray;
    site.apps = Json.emptyArray;
    site.widgets = Json.emptyArray;
    site.menu = Json.emptyArray;
    site.createdAt = Clock.currTime();
    site.updatedAt = site.createdAt;

    if ("site_id" in request && request["site_id"].isString)
      site.siteId = request["site_id"].getString;
    if ("name" in request && request["name"].isString)
      site.name = request["name"].getString;
    if ("design" in request && request["design"].isString)
      site.design = request["design"].getString;
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

}
