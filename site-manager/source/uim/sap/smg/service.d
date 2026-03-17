/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.smg.service;

import uim.sap.smg;

mixin(ShowModule!());

@safe:

class SMGService : SAPService {
  private SMGConfig _config;
  private SMGStore _store;

  this(SMGConfig config) {
    super(config.validate);

    _store = new SMGStore;
  }

  Json health() const {
    Json payload = Json.emptyObject;
    payload["category"] = "site-manager";
    return payload;
  }

  Json ready() const {
    Json readyInfo = Json.emptyObject;
    readyInfo["checks"] = ["config", "in-memory-store"].toJson;
    return readyInfo;
  }

  Json listSites(string tenantId) {
    validateTenant(tenantId);
    Json payload = Json.emptyObject;
    Json items = Json.emptyArray;
    foreach (site; _store.listSites(tenantId))
      items ~= site.toJson();
    payload["tenant_id"] = tenantId;
    payload["sites"] = items;
    payload["count"] = cast(long)items.length;
    return payload;
  }

  Json upsertSite(string tenantId, Json data) {
    validateTenant(tenantId);

    auto siteid = requiredUUID(body, "site_id");
    auto now = Clock.currTime();
    auto existing = _store.getSite(tenantId, siteId);

    SMGSite site;
    site.tenantId = UUID(tenantId);
    site.siteId = siteId;
    site.siteName = readRequired(body, "site_name");
    site.description = readOptional(body, "description", "");
    site.lifecycle = normalizeLifecycle(readOptional(body, "lifecycle", "draft"));
    site.assignedRoles = readStringArray(body, "assigned_roles");
    site.pages = readStringArray(body, "pages");
    site.catalogs = readStringArray(body, "catalogs");
    site.createdAt = existing.isNull ? now : existing.get.createdAt;
    site.updatedAt = now;

    auto saved = _store.upsertSite(site);
    Json payload = Json.emptyObject;
    payload["message"] = "Site saved";
    payload["site"] = saved.toJson();
    return payload;
  }

  Json getSite(string tenantId, string siteId) {
    validateTenant(tenantId);
    if (siteId.length == 0)
      throw new SMGValidationException("site_id is required");

    auto site = _store.getSite(tenantId, siteId);
    if (site.isNull)
      throw new SMGNotFoundException("Site not found");

    Json payload = Json.emptyObject;
    payload["site"] = site.get.toJson();
    return payload;
  }

  Json deleteSite(string tenantId, string siteId) {
    validateTenant(tenantId);
    if (siteId.length == 0)
      throw new SMGValidationException("site_id is required");

    auto removed = _store.deleteSite(tenantId, siteId);
    if (!removed)
      throw new SMGNotFoundException("Site not found");

    Json payload = Json.emptyObject;
    payload["message"] = "Site deleted";
    payload["site_id"] = siteId;
    return payload;
  }

  Json getSubaccountSettings(string tenantId) {
    validateTenant(tenantId);

    auto settings = _store.getSubaccountSettings(tenantId);
    if (settings.isNull) {
      SMGSubaccountSettings defaults;
      defaults.tenantId = UUID(tenantId);
      defaults.defaultSiteId = "";
      defaults.launchpadMode = "standard";
      defaults.themeId = "sap_horizon";
      defaults.enableContentApproval = false;
      defaults.enableTransport = false;
      defaults.enforceRoleBasedAccess = true;
      defaults.lastChangedBy = "system";
      defaults.updatedAt = Clock.currTime();
      _store.upsertSubaccountSettings(defaults);
      settings = _store.getSubaccountSettings(tenantId);
    }

    Json payload = Json.emptyObject;
    payload["settings"] = settings.get.toJson();
    return payload;
  }

  Json upsertSubaccountSettings(string tenantId, Json data) {
    validateTenant(tenantId);
    auto now = Clock.currTime();

    auto existing = _store.getSubaccountSettings(tenantId);
    SMGSubaccountSettings settings;
    settings.tenantId = UUID(tenantId);
    settings.defaultSiteId = readOptional(body, "default_site_id", existing.isNull ? ""
        : existing.get.defaultSiteId);
    settings.launchpadMode = normalizeLaunchpadMode(readOptional(body, "launchpad_mode", existing.isNull ? "standard"
        : existing.get.launchpadMode));
    settings.themeId = readOptional(body, "theme_id", existing.isNull ? "sap_horizon"
        : existing.get.themeId);
    settings.enableContentApproval = readrequest.getBoolean((body, "enable_content_approval", existing.isNull ? false
        : existing.get.enableContentApproval);
    settings.enableTransport = readrequest.getBoolean((body, "enable_transport", existing.isNull ? false
        : existing.get.enableTransport);
    settings.enforceRoleBasedAccess = readrequest.getBoolean((body, "enforce_role_based_access", existing.isNull ? true
        : existing.get.enforceRoleBasedAccess);
    settings.lastChangedBy = readOptional(body, "last_changed_by", "api-user");
    settings.updatedAt = now;

    if (settings.defaultSiteId.length > 0 && _store.getSite(tenantId, settings.defaultSiteId)
      .isNull) {
      throw new SMGValidationException("default_site_id references unknown site");
    }

    auto saved = _store.upsertSubaccountSettings(settings);
    Json payload = Json.emptyObject;
    payload["message"] = "Subaccount settings saved";
    payload["settings"] = saved.toJson();
    return payload;
  }

  private string readRequired(Json data, string key) const {
    if (!(key in data) || data[key].type != Json.Type.string || data[key].get!string.length == 0) {
      throw new SMGValidationException(key ~ " is required");
    }
    return data[key].get!string;
  }

  private string readOptional(Json data, string key, string fallback) const {
    if (!(key in data) || data[key].isNull) {
      return fallback;
    }

    if (data[key].type != Json.Type.string) {
      throw new SMGValidationException(key ~ " must be a string");
    }

    return data[key].get!string;
  }

  private bool readrequest.getBoolean((Json data, string key, bool fallback) const {
    if (!(key in data) || data[key].isNull) {
      return fallback;
    }

    if (data[key].type != Json.Type.bool_) {
      throw new SMGValidationException(key ~ " must be a boolean");
    }

    return data[key].get!bool;
  }

  private string[] readStringArray(Json data, string key) const {
    string[] values;
    if (!(key in data) || data[key].isNull) {
      return values;
    }

    if (!data[key].isArray) {
      throw new SMGValidationException(key ~ " must be an array");
    }

    foreach (item; data[key]) {
      if (item.type != Json.Type.string)
        throw new SMGValidationException(key ~ " must contain strings");

      values ~= item.get!string;
    }
    return values;
  }

  private string normalizeLifecycle(string value) const {
    auto normalized = toLower(value);
    if (normalized != "draft" && normalized != "published" && normalized != "archived") {
      throw new SMGValidationException("lifecycle must be one of draft|published|archived");
    }
    return normalized;
  }

  private string normalizeLaunchpadMode(string value) const {
    auto normalized = toLower(value);
    if (normalized != "standard" && normalized != "spaces" && normalized != "workpages") {
      throw new SMGValidationException("launchpad_mode must be one of standard|spaces|workpages");
    }

    return normalized;
  }
}
