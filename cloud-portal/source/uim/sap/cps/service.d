/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.cps.service;

import uim.sap.cps;

mixin(ShowModule!());

@safe:

class CPSService : SAPService {
  mixin(SAPServiceTemplate!CPSService);

  private CPSStore _store;

  this(CPSConfig config) {
    super(config);

    _store = new CPSStore;
  }

  Json upsertSite(UUID tenantId, Json request) {
    CPSConfig cfg = cast(CPSConfig)_config;

    validateId(tenantId, "Tenant ID");
    auto site = siteFromJson(tenantId, request, cfg.defaultTheme);
    if (site.name.length == 0)
      throw new CPSValidationException("name is required");
    site.updatedAt = Clock.currTime();
    auto saved = _store.upsertSite(site);

    Json payload = Json.emptyObject;
    payload["success"] = true;
    payload["site"] = saved.toJson();
    payload["user_experience"] = "fiori3-or-custom";
    return payload;
  }

  Json listSites(UUID tenantId) {
    validateId(tenantId, "Tenant ID");
    Json resources = Json.emptyArray;
    foreach (site; _store.listSites(tenantId))
      resources ~= site.toJson();

    return Json.emptyObject
      .set("resources", resources)
      .set("total_results", cast(long)resources.length);
  }

  Json getSite(UUID tenantId, string siteId) {
    validateId(tenantId, "Tenant ID");
    validateId(siteId, "Site ID");
    auto site = _store.getSite(tenantId, siteId);
    if (site.siteId.length == 0)
      throw new CPSNotFoundException("Site", tenantId ~ "/" ~ siteId);

    Json payload = Json.emptyObject;
    payload["site"] = site.toJson();
    return payload;
  }

  Json deleteSite(UUID tenantId, string siteId) {
    validateId(tenantId, "Tenant ID");
    validateId(siteId, "Site ID");
    if (!_store.deleteSite(tenantId, siteId))
      throw new CPSNotFoundException("Site", tenantId ~ "/" ~ siteId);

    Json payload = Json.emptyObject;
    payload["success"] = true;
    payload["site_id"] = siteId;
    return payload;
  }

  Json resolveNavigation(UUID tenantId, Json request) {
    validateId(tenantId, "Tenant ID");

    Json roles = Json.emptyArray;
    if ("roles" in request && request["roles"].isArray)
      roles = request["roles"];

    Json entries = Json.emptyArray;
    foreach (site; _store.listSites(tenantId)) {
      foreach (app; site.apps.toArray) {
        if (!app.isObject)
          continue;
        string requiredRole;
        if ("required_role" in app && app["required_role"].isString)
          requiredRole = app["required_role"].get!string;
        if (requiredRole.length == 0 || containsString(roles, requiredRole)) {
          Json entry = Json.emptyObject;
          entry["site_id"] = site.siteId;
          entry["app"] = app;
          entries ~= entry;
        }
      }
    }

    return Json.emptyObject
      .set("entries", entries)
      .set("single_sign_on", true)
      .set("sso_protocols", Json.emptyArray)
      .set("sso_protocols", "openid-connect")
      .set("sso_protocols", "saml2");
  }

  Json listEntryPoints(UUID tenantId) {
    validateId(tenantId, "Tenant ID");
    Json resources = Json.emptyArray;

    foreach (site; _store.listSites(tenantId)) {
      Json item = Json.emptyObject;
      item["type"] = "site";
      item["site_id"] = site.siteId;
      item["name"] = site.name;
      item["apps"] = site.apps;
      resources ~= item;
    }

    foreach (provider; _store.listProviders(tenantId)) {
      Json item = Json.emptyObject;
      item["type"] = "content-provider";
      item["provider_id"] = provider.providerId;
      item["solution_name"] = provider.solutionName;
      item["catalogs"] = provider.catalogs;
      resources ~= item;
    }

    Json payload = Json.emptyObject;
    payload["resources"] = resources;
    payload["total_results"] = cast(long)resources.length;
    payload["central_entry_point"] = true;
    return payload;
  }

  Json upsertSiteAdministration(UUID tenantId, Json request) {
    validateId(tenantId, "Tenant ID");

    CPSAdminSettings admin;
    admin.tenantId = UUID(tenantId);
    admin.themes = Json.emptyArray;
    admin.transports = Json.emptyArray;
    admin.translations = Json.emptyArray;
    admin.templates = Json.emptyArray;
    admin.extensions = Json.emptyArray;
    admin.updatedAt = Clock.currTime();

    if ("themes" in request && request["themes"].isArray)
      admin.themes = request["themes"];
    if ("transports" in request && request["transports"].isArray)
      admin.transports = request["transports"];
    if ("translations" in request && request["translations"].isArray)
      admin.translations = request["translations"];
    if ("templates" in request && request["templates"].isArray)
      admin.templates = request["templates"];
    if ("extensions" in request && request["extensions"].isArray)
      admin.extensions = request["extensions"];

    auto saved = _store.upsertAdmin(admin);
    
    return Json.emptyObject
      .set("success", true)
      .set("administration", saved.toJson());      
  }

  Json getSiteAdministration(UUID tenantId) {
    validateId(tenantId, "Tenant ID");
    auto admin = _store.getAdmin(tenantId);
    if (admin.tenantId.length == 0) {
      admin.tenantId = UUID(tenantId);
      admin.themes = Json.emptyArray;
      admin.transports = Json.emptyArray;
      admin.translations = Json.emptyArray;
      admin.templates = Json.emptyArray;
      admin.extensions = Json.emptyArray;
      admin.updatedAt = Clock.currTime();
    }

    Json payload = Json.emptyObject;
    payload["administration"] = admin.toJson();
    return payload;
  }

  Json upsertContent(UUID tenantId, string contentType, Json request) {
    validateId(tenantId, "Tenant ID");
    validateContentType(contentType);

    CPSContentItem item;
    item.tenantId = UUID(tenantId);
    item.itemType = contentType;
    item.itemId = createId();
    item.configuration = Json.emptyObject;
    item.updatedAt = Clock.currTime();

    if ("item_id" in request && request["item_id"].isString)
      item.itemId = request["item_id"].get!string;
    if ("name" in request && request["name"].isString)
      item.name = request["name"].get!string;
    if ("configuration" in request && request["configuration"].isObject)
      item.configuration = request["configuration"];

    if (item.name.length == 0)
      throw new CPSValidationException("name is required");

    auto saved = _store.upsertContent(item);
    Json payload = Json.emptyObject;
    payload["success"] = true;
    payload["content"] = saved.toJson();
    return payload;
  }

  Json listContent(UUID tenantId, string contentType) {
    validateId(tenantId, "Tenant ID");
    validateContentType(contentType);

    Json resources = Json.emptyArray;
    foreach (item; _store.listContent(tenantId, contentType))
      resources ~= item.toJson();

    Json payload = Json.emptyObject;
    payload["resources"] = resources;
    payload["total_results"] = cast(long)resources.length;
    return payload;
  }

  Json upsertLaunchpadModule(UUID tenantId, Json request) {
    validateId(tenantId, "Tenant ID");

    CPSLaunchpadModule launchpadModule;
    launchpadModule.tenantId = UUID(tenantId);
    launchpadModule.moduleId = createId();
    launchpadModule.personalization = true;
    launchpadModule.translation = true;
    launchpadModule.customThemes = true;
    launchpadModule.updatedAt = Clock.currTime();

    if ("module_id" in request && request["module_id"].isString)
      launchpadModule.moduleId = request["module_id"].get!string;
    if ("solution_name" in request && request["solution_name"].isString)
      launchpadModule.solutionName = request["solution_name"].get!string;
    if ("personalization" in request && request["personalization"].isBoolean)
      launchpadModule.personalization = request["personalization"].get!bool;
    if ("translation" in request && request["translation"].isBoolean)
      launchpadModule.translation = request["translation"].get!bool;
    if ("custom_themes" in request && request["custom_themes"].isBoolean)
      launchpadModule.customThemes = request["custom_themes"].get!bool;

    if (launchpadModule.solutionName.length == 0)
      throw new CPSValidationException("solution_name is required");

    auto saved = _store.upsertLaunchpad(launchpadModule);

    return Json.emptyObject
      .set("success", true)
      .set("launchpad_module", saved.toJson())
      .set("embedded_launchpad", true);
  }

  Json listLaunchpadModules(UUID tenantId) {
    validateId(tenantId, "Tenant ID");
    Json resources = Json.emptyArray;
    foreach (launchpadModule; _store.listLaunchpad(tenantId))
      resources ~= launchpadModule.toJson();

    return Json.emptyObject
      .set("resources", resources)
      .set("total_results", cast(long)resources.length);
  }

  Json upsertProvider(UUID tenantId, Json request) {
    validateId(tenantId, "Tenant ID");
    CPSContentProvider provider;
    provider.tenantId = UUID(tenantId);
    provider.providerId = createId();
    provider.saasEnabled = true;
    provider.catalogs = Json.emptyArray;
    provider.updatedAt = Clock.currTime();

    if ("provider_id" in request && request["provider_id"].isString)
      provider.providerId = request["provider_id"].get!string;
    if ("solution_name" in request && request["solution_name"].isString)
      provider.solutionName = request["solution_name"].get!string;
    if ("saas_enabled" in request && request["saas_enabled"].isBoolean)
      provider.saasEnabled = request["saas_enabled"].get!bool;
    if ("catalogs" in request && request["catalogs"].isArray)
      provider.catalogs = request["catalogs"];

    if (provider.solutionName.length == 0)
      throw new CPSValidationException("solution_name is required");

    auto saved = _store.upsertProvider(provider);
    return Json.emptyObject
      .set("success", true)
      .set("provider", saved.toJson())
      .set("saas_content_provider", true);
  }

  Json listProviders(UUID tenantId) {
    validateId(tenantId, "Tenant ID");
    Json resources = Json.emptyArray;
    foreach (provider; _store.listProviders(tenantId))
      resources ~= provider.toJson();

    return Json.emptyObject
      .set("resources", resources)
      .set("total_results", cast(long)resources.length);
  }

  Json consumeProvider(UUID tenantId, string providerId) {
    validateId(tenantId, "Tenant ID");
    validateId(providerId, "Provider ID");

    auto provider = _store.getProvider(tenantId, providerId);
    if (provider.providerId.length == 0)
      throw new CPSNotFoundException("Provider", tenantId ~ "/" ~ providerId);

    return Json.emptyObject
      .set("success", true)
      .set("consumed", provider.toJson())
      .set("message", "SaaS content provider exposed for portal consumption");
  }

  private void validateContentType(string contentType) {
    if (contentType != "apps" && contentType != "roles" && contentType != "groups" && contentType != "catalogs") {
      throw new CPSValidationException("contentType must be apps, roles, groups, or catalogs");
    }
  }

  private bool containsString(Json values, string needle) {
    if (!values.isArray || needle.length == 0)
      return false;
    
    return values.toArray.any!(item => item.isString && item.get!string == needle);
  }
}
