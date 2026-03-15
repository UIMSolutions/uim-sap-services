/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.cps.models.models;

import uim.sap.cps;

mixin(ShowModule!());

@safe:





struct CPSLaunchpadModule {
  string tenantId;
  string moduleId;
  string solutionName;
  bool personalization;
  bool translation;
  bool customThemes;
  SysTime updatedAt;

  override Json toJson()  {
    Json info = super.toJson;
    payload["tenant_id"] = tenantId;
    payload["module_id"] = moduleId;
    payload["solution_name"] = solutionName;
    payload["personalization"] = personalization;
    payload["translation"] = translation;
    payload["custom_themes"] = customThemes;
    payload["updated_at"] = updatedAt.toISOExtString();
    return payload;
  }
}

struct CPSContentProvider {
  string tenantId;
  string providerId;
  string solutionName;
  bool saasEnabled;
  Json catalogs;
  SysTime updatedAt;

  override Json toJson()  {
    Json info = super.toJson;
    payload["tenant_id"] = tenantId;
    payload["provider_id"] = providerId;
    payload["solution_name"] = solutionName;
    payload["saas_enabled"] = saasEnabled;
    payload["catalogs"] = catalogs;
    payload["updated_at"] = updatedAt.toISOExtString();
    return payload;
  }
}

CPSSite siteFromJson(string tenantId, Json request, string defaultTheme) {
  CPSSite site;
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
