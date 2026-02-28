module uim.sap.cps.models;

import std.datetime : Clock, SysTime;
import std.uuid : randomUUID;

import vibe.data.json : Json;

string createId() {
    return randomUUID().toString();
}

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

struct CPSAdminSettings {
    string tenantId;
    Json themes;
    Json transports;
    Json translations;
    Json templates;
    Json extensions;
    SysTime updatedAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["tenant_id"] = tenantId;
        payload["themes"] = themes;
        payload["transports"] = transports;
        payload["translations"] = translations;
        payload["templates"] = templates;
        payload["extensions"] = extensions;
        payload["updated_at"] = updatedAt.toISOExtString();
        return payload;
    }
}

struct CPSContentItem {
    string tenantId;
    string itemType;
    string itemId;
    string name;
    Json configuration;
    SysTime updatedAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["tenant_id"] = tenantId;
        payload["item_type"] = itemType;
        payload["item_id"] = itemId;
        payload["name"] = name;
        payload["configuration"] = configuration;
        payload["updated_at"] = updatedAt.toISOExtString();
        return payload;
    }
}

struct CPSLaunchpadModule {
    string tenantId;
    string moduleId;
    string solutionName;
    bool personalization;
    bool translation;
    bool customThemes;
    SysTime updatedAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
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

    Json toJson() const {
        Json payload = Json.emptyObject;
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

    if ("site_id" in request && request["site_id"].isString) site.siteId = request["site_id"].get!string;
    if ("name" in request && request["name"].isString) site.name = request["name"].get!string;
    if ("design" in request && request["design"].isString) site.design = request["design"].get!string;
    if ("pages" in request && request["pages"].type == Json.Type.array) site.pages = request["pages"];
    if ("apps" in request && request["apps"].type == Json.Type.array) site.apps = request["apps"];
    if ("widgets" in request && request["widgets"].type == Json.Type.array) site.widgets = request["widgets"];
    if ("menu" in request && request["menu"].type == Json.Type.array) site.menu = request["menu"];
    return site;
}
