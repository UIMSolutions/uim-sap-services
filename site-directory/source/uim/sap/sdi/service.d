module uim.sap.sdi.service;

import std.datetime : Clock;
import std.string : replace;

import vibe.data.json : Json;

import uim.sap.sdi.config;
import uim.sap.sdi.exceptions;
import uim.sap.sdi.models;
import uim.sap.sdi.store;

class SDIService : SAPService {
    private SDIConfig _config;
    private SDIStore _store;

    this(SDIConfig config) {
        config.validate();
        _config = config;
        _store = new SDIStore;
    }

    @property const(SDIConfig) config() const {
        return _config;
    }

    Json health() const {
        Json payload = Json.emptyObject;
        payload["status"] = "UP";
        payload["service"] = _config.serviceName;
        payload["version"] = _config.serviceVersion;
        payload["domain"] = "site-directory";
        return payload;
    }

    Json ready() const {
        Json payload = Json.emptyObject;
        payload["status"] = "READY";
        return payload;
    }

    Json listSiteTiles(string tenantId) {
        validateTenant(tenantId);
        Json tiles = Json.emptyArray;
        foreach (site; _store.listSites(tenantId)) tiles ~= site.toTileJson();

        Json payload = Json.emptyObject;
        payload["tenant_id"] = tenantId;
        payload["tiles"] = tiles;
        payload["count"] = cast(long)tiles.length;
        return payload;
    }

    Json createSite(string tenantId, Json body) {
        validateTenant(tenantId);
        auto now = Clock.currTime();

        SDISite site;
        site.tenantId = tenantId;
        site.siteId = readRequired(body, "site_id");
        site.name = readRequired(body, "name");
        site.description = readOptional(body, "description", "");
        site.siteAlias = normalizeSiteAlias(readOptional(body, "alias", site.siteId));
        site.runtimeUrl = defaultRuntimeUrl(tenantId, site.siteAlias);
        site.isDefault = readOptionalBool(body, "is_default", false);
        site.roles = readStringArray(body, "roles");
        site.settings = settingsFromJson(body);
        site.importBundle = Json.emptyObject;
        site.createdAt = now;
        site.updatedAt = now;

        auto saved = _store.upsertSite(site);
        if (saved.isDefault) _store.setDefaultSite(tenantId, saved.siteId);

        Json payload = Json.emptyObject;
        payload["message"] = "Site created";
        payload["site"] = saved.toJson();
        return payload;
    }

    Json getSite(string tenantId, string siteId) {
        validateTenant(tenantId);
        auto site = requireSite(tenantId, siteId);

        Json payload = Json.emptyObject;
        payload["site"] = site.toJson();
        return payload;
    }

    Json deleteSite(string tenantId, string siteId) {
        validateTenant(tenantId);
        if (!_store.deleteSite(tenantId, siteId)) throw new SDINotFoundException("Site not found");

        Json payload = Json.emptyObject;
        payload["message"] = "Site deleted";
        payload["site_id"] = siteId;
        return payload;
    }

    Json importSite(string tenantId, string siteId, Json body) {
        validateTenant(tenantId);
        auto existing = requireSite(tenantId, siteId);
        auto now = Clock.currTime();

        existing.importBundle = body;
        if ("name" in body && body["name"].isString) existing.name = body["name"].get!string;
        if ("description" in body && body["description"].isString) existing.description = body["description"].get!string;
        if ("roles" in body && body["roles"].type == Json.Type.array) existing.roles = readStringArray(body, "roles");
        if ("settings" in body && body["settings"].type == Json.Type.object) existing.settings = settingsFromObject(body["settings"]);
        existing.updatedAt = now;

        auto saved = _store.upsertSite(existing);

        Json payload = Json.emptyObject;
        payload["message"] = "Site imported";
        payload["site"] = saved.toJson();
        return payload;
    }

    Json exportSite(string tenantId, string siteId) {
        validateTenant(tenantId);
        auto site = requireSite(tenantId, siteId);

        Json payload = Json.emptyObject;
        payload["site"] = site.toJson();
        payload["export_bundle"] = site.importBundle.type == Json.Type.null_ ? Json.emptyObject : site.importBundle;
        payload["exported_at"] = Clock.currTime().toISOExtString();
        return payload;
    }

    Json updateAlias(string tenantId, string siteId, Json body) {
        validateTenant(tenantId);
        auto site = requireSite(tenantId, siteId);

        site.siteAlias = normalizeSiteAlias(readRequired(body, "alias"));
        site.runtimeUrl = defaultRuntimeUrl(tenantId, site.siteAlias);
        site.updatedAt = Clock.currTime();

        auto saved = _store.upsertSite(site);

        Json payload = Json.emptyObject;
        payload["message"] = "Site alias updated";
        payload["site"] = saved.toJson();
        return payload;
    }

    Json setDefaultSite(string tenantId, string siteId) {
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

    Json openRuntimeSite(string tenantId, string siteId) {
        validateTenant(tenantId);
        auto site = requireSite(tenantId, siteId);

        Json payload = Json.emptyObject;
        payload["message"] = "Runtime site opened";
        payload["runtime_url"] = site.runtimeUrl;
        payload["open_target"] = "browser";
        return payload;
    }

    Json getSiteSettings(string tenantId, string siteId) {
        validateTenant(tenantId);
        auto site = requireSite(tenantId, siteId);

        Json payload = Json.emptyObject;
        payload["settings"] = site.settings.toJson();
        payload["roles"] = toJsonArray(site.roles);
        return payload;
    }

    Json updateSiteSettings(string tenantId, string siteId, Json body) {
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

    Json assignRoles(string tenantId, string siteId, Json body) {
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

    private SDISite requireSite(string tenantId, string siteId) {
        if (siteId.length == 0) throw new SDIValidationException("site_id is required");
        auto site = _store.getSite(tenantId, siteId);
        if (site.isNull) throw new SDINotFoundException("Site not found");
        return site.get;
    }

    private void validateTenant(string tenantId) const {
        if (tenantId.length == 0) throw new SDIValidationException("tenant_id is required");
    }

    private string readRequired(Json body, string key) const {
        if (!(key in body) || body[key].type != Json.Type.string || body[key].get!string.length == 0) {
            throw new SDIValidationException(key ~ " is required");
        }
        return body[key].get!string;
    }

    private string readOptional(Json body, string key, string fallback) const {
        if (!(key in body) || body[key].type == Json.Type.null_) return fallback;
        if (body[key].type != Json.Type.string) throw new SDIValidationException(key ~ " must be a string");
        return body[key].get!string;
    }

    private bool readOptionalBool(Json body, string key, bool fallback) const {
        if (!(key in body) || body[key].type == Json.Type.null_) return fallback;
        if (body[key].type != Json.Type.bool_) throw new SDIValidationException(key ~ " must be a boolean");
        return body[key].get!bool;
    }

    private string[] readStringArray(Json body, string key) const {
        string[] values;
        if (!(key in body) || body[key].type == Json.Type.null_) return values;
        if (body[key].type != Json.Type.array) throw new SDIValidationException(key ~ " must be an array");
        foreach (item; body[key]) {
            if (item.type != Json.Type.string) throw new SDIValidationException(key ~ " must contain strings");
            values ~= item.get!string;
        }
        return values;
    }

    private SDISiteSettings settingsFromJson(Json body) const {
        if (!("settings" in body) || body["settings"].type == Json.Type.null_) {
            SDISiteSettings defaults;
            return defaults;
        }
        if (body["settings"].type != Json.Type.object) throw new SDIValidationException("settings must be an object");
        return settingsFromObject(body["settings"]);
    }

    private SDISiteSettings settingsFromObject(Json settingsBody) const {
        SDISiteSettings settings;
        if ("theme" in settingsBody && settingsBody["theme"].isString) settings.theme = settingsBody["theme"].get!string;
        if ("home_page" in settingsBody && settingsBody["home_page"].isString) settings.homePage = settingsBody["home_page"].get!string;
        if ("allow_personalization" in settingsBody && settingsBody["allow_personalization"].isBoolean) settings.allowPersonalization = settingsBody["allow_personalization"].get!bool;
        if ("enable_notifications" in settingsBody && settingsBody["enable_notifications"].isBoolean) settings.enableNotifications = settingsBody["enable_notifications"].get!bool;
        return settings;
    }

    private string normalizeSiteAlias(string siteAlias) const {
        if (siteAlias.length == 0) throw new SDIValidationException("alias is required");
        auto normalized = replace(siteAlias, " ", "-");
        return normalized;
    }

    private string defaultRuntimeUrl(string tenantId, string siteAlias) const {
        return "https://runtime.local/" ~ tenantId ~ "/" ~ siteAlias;
    }

    private Json toJsonArray(string[] values) const {
        Json result = Json.emptyArray;
        foreach (value; values) result ~= value;
        return result;
    }
}
