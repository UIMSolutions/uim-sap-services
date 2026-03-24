/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.sdi.service;

import uim.sap.sdi;

mixin(ShowModule!());

@safe:

/**
  * SDIService is the main service class for the Site Directory Integration (SDI) module. It provides methods to manage sites, including creating, retrieving, updating, and deleting site information. The service also includes health and readiness checks.
  *
  * The service uses SDIConfig for configuration and SDIStore for data persistence. It validates input data and handles exceptions using custom exception classes defined in the uim.sap.sdi.exceptions package.
  *
  * Each method returns a Json object as a response payload, which can be used by the server to send responses to clients.
  *
  * Example usage:
  * ```
  * SDIConfig config = new SDIConfig();
  * SDIService service = new SDIService(config);
  * SDIServer server = new SDIServer(service);
  * server.run();
  * ```
  * Note: The example usage demonstrates how to initialize the SDIConfig, create an instance of SDIService with the configuration, and then start the SDIServer to listen for incoming requests. The server will use the service instance to handle requests related to site management and health checks.
  */
class SDIService : SAPService {
  private SDIConfig _config;
  private SDIStore _store;

  this(SDIConfig config) {
    super(config);

    _store = new SDIStore;
  }

  override Json health() {
    Json payload = Json.emptyObject;
    payload["domain"] = "site-directory";
    return payload;
  }

  Json listSiteTiles(UUID tenantId) {
    validateTenant(tenantId);
    Json tiles = Json.emptyArray;
    foreach (site; _store.listSites(tenantId))
      tiles ~= site.toTileJson();

    Json payload = Json.emptyObject;
    payload["tenant_id"] = tenantId;
    payload["tiles"] = tiles;
    payload["count"] = cast(long)tiles.length;
    return payload;
  }

  Json createSite(UUID tenantId, Json data) {
    validateTenant(tenantId);
    auto now = Clock.currTime();

    SDISite site;
    site.tenantId = tenantId;
    site.siteid = requiredUUID(body, "site_id");
    site.name = requiredString(body, "name");
    site.description = optionalString(body, "description", "");
    site.siteAlias = normalizeSiteAlias(optionalString(body, "alias", site.siteId));
    site.runtimeUrl = defaultRuntimeUrl(tenantId, site.siteAlias);
    site.isDefault = optionalBoolean(data, "is_default", false);
    site.roles = readStringArray(body, "roles");
    site.settings = settingsFromJson(body);
    site.importBundle = Json.emptyObject;
    site.createdAt = now;
    site.updatedAt = now;

    auto saved = _store.upsertSite(site);
    if (saved.isDefault)
      _store.setDefaultSite(tenantId, saved.siteId);

    Json payload = Json.emptyObject;
    payload["message"] = "Site created";
    payload["site"] = saved.toJson();
    return payload;
  }

  Json getSite(UUID tenantId, string siteId) {
    validateTenant(tenantId);
    auto site = requireSite(tenantId, siteId);

    Json payload = Json.emptyObject;
    payload["site"] = site.toJson();
    return payload;
  }

  Json deleteSite(UUID tenantId, string siteId) {
    validateTenant(tenantId);
    if (!_store.deleteSite(tenantId, siteId))
      throw new SDINotFoundException("Site not found");

    Json payload = Json.emptyObject;
    payload["message"] = "Site deleted";
    payload["site_id"] = siteId;
    return payload;
  }

  Json importSite(UUID tenantId, string siteId, Json data) {
    validateTenant(tenantId);
    auto existing = requireSite(tenantId, siteId);
    auto now = Clock.currTime();

    existing.importBundle = body;
    if ("name" in body && body["name"].isString)
      existing.name = body["name"].get!string;
    if ("description" in body && body["description"].isString)
      existing.description = body["description"].get!string;
    if ("roles" in body && body["roles"].isArray)
      existing.roles = readStringArray(body, "roles");
    if ("settings" in body && body["settings"].isObject)
      existing.settings = settingsFromObject(body["settings"]);
    existing.updatedAt = now;

    auto saved = _store.upsertSite(existing);

    Json payload = Json.emptyObject;
    payload["message"] = "Site imported";
    payload["site"] = saved.toJson();
    return payload;
  }

  Json exportSite(UUID tenantId, string siteId) {
    validateTenant(tenantId);
    auto site = requireSite(tenantId, siteId);

    Json payload = Json.emptyObject;
    payload["site"] = site.toJson();
    payload["export_bundle"] = site.importBundle.isNull ? Json.emptyObject
      : site.importBundle;
    payload["exported_at"] = Clock.currTime().toISOExtString();
    return payload;
  }

  Json updateAlias(UUID tenantId, string siteId, Json data) {
    validateTenant(tenantId);
    auto site = requireSite(tenantId, siteId);

    site.siteAlias = normalizeSiteAlias(requiredString(body, "alias"));
    site.runtimeUrl = defaultRuntimeUrl(tenantId, site.siteAlias);
    site.updatedAt = Clock.currTime();

    auto saved = _store.upsertSite(site);

    Json payload = Json.emptyObject;
    payload["message"] = "Site alias updated";
    payload["site"] = saved.toJson();
    return payload;
  }

  Json setDefaultSite(UUID tenantId, string siteId) {
    validateTenant(tenantId);
    auto site = requireSite(tenantId, siteId);
    site.isDefault = true;
    site.updatedAt = Clock.currTime();
    _store.upsertSite(site);
    _store.setDefaultSite(tenantId, siteId);

    Json payload = Json.emptyObject;
    payload["message"] = "Default site selected";
    payload["site_id"] = siteId;
    return payload;
  }

  Json openRuntimeSite(UUID tenantId, string siteId) {
    validateTenant(tenantId);
    auto site = requireSite(tenantId, siteId);

    Json payload = Json.emptyObject;
    payload["message"] = "Runtime site opened";
    payload["runtime_url"] = site.runtimeUrl;
    payload["open_target"] = "browser";
    return payload;
  }

  Json getSiteSettings(UUID tenantId, string siteId) {
    validateTenant(tenantId);
    auto site = requireSite(tenantId, siteId);

    Json payload = Json.emptyObject;
    payload["settings"] = site.settings.toJson();
    payload["roles"] = toJsonArray(site.roles);
    return payload;
  }

  Json updateSiteSettings(UUID tenantId, string siteId, Json data) {
    validateTenant(tenantId);
    auto site = requireSite(tenantId, siteId);

    site.settings = settingsFromJson(body);
    site.updatedAt = Clock.currTime();
    auto saved = _store.upsertSite(site);

    Json payload = Json.emptyObject;
    payload["message"] = "Site settings updated";
    payload["settings"] = saved.settings.toJson();
    return payload;
  }

  Json assignRoles(UUID tenantId, string siteId, Json data) {
    validateTenant(tenantId);
    auto site = requireSite(tenantId, siteId);

    site.roles = readStringArray(body, "roles");
    site.updatedAt = Clock.currTime();
    auto saved = _store.upsertSite(site);

    Json payload = Json.emptyObject;
    payload["message"] = "Roles assigned";
    payload["roles"] = toJsonArray(saved.roles);
    payload["role_count"] = cast(long)saved.roles.length;
    return payload;
  }

  private SDISite requireSite(UUID tenantId, string siteId) {
    if (siteId.length == 0)
      throw new SDIValidationException("site_id is required");
    auto site = _store.getSite(tenantId, siteId);
    if (site.isNull)
      throw new SDINotFoundException("Site not found");
    return site.get;
  }

  private void validateTenant(UUID tenantId) const {
    if (tenantId.length == 0)
      throw new SDIValidationException("tenant_id is required");
  }

  private string[] readStringArray(Json data, string key) const {
    string[] values;
    if (!(key in data) || data[key].isNull)
      return values;
    if (!data[key].isArray)
      throw new SDIValidationException(key ~ " must be an array");
    foreach (item; data[key]) {
      if (item.type != Json.Type.string)
        throw new SDIValidationException(key ~ " must contain strings");

      values ~= item.get!string;
    }

    return values;
  }

  private SDISiteSettings settingsFromJson(Json data) const {
    if (!("settings" in data) || data["settings"].isNull) {
      SDISiteSettings defaults;
      return defaults;
    }
    if (!data["settings"].isObject)
      throw new SDIValidationException("settings must be an object");
    return settingsFromObject(data["settings"]);
  }

  private SDISiteSettings settingsFromObject(Json settingsBody) const {
    SDISiteSettings settings;
    if ("theme" in settingsBody && settingsBody["theme"].isString)
      settings.theme = settingsBody["theme"].get!string;
    if ("home_page" in settingsBody && settingsBody["home_page"].isString)
      settings.homePage = settingsBody["home_page"].get!string;
    if ("allow_personalization" in settingsBody && settingsBody["allow_personalization"].isBoolean)
      settings.allowPersonalization = settingsBody["allow_personalization"].get!bool;
    if ("enable_notifications" in settingsBody && settingsBody["enable_notifications"].isBoolean)
      settings.enableNotifications = settingsBody["enable_notifications"].get!bool;
    return settings;
  }

  private string normalizeSiteAlias(string siteAlias) const {
    if (siteAlias.length == 0)
      throw new SDIValidationException("alias is required");
    auto normalized = replace(siteAlias, " ", "-");
    return normalized;
  }

  private string defaultRuntimeUrl(UUID tenantId, string siteAlias) const {
    return "https://runtime.local/" ~ tenantId ~ "/" ~ siteAlias;
  }

  private Json toJsonArray(string[] values) const {
    return values.toJson;
  }
}
