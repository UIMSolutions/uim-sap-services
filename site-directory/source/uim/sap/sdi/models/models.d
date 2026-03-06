module uim.sap.sdi.models;

import std.datetime : SysTime;

import vibe.data.json : Json;

struct SDISiteSettings {
    string theme = "sap_horizon";
    string homePage = "home";
    bool allowPersonalization = true;
    bool enableNotifications = true;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["theme"] = theme;
        payload["home_page"] = homePage;
        payload["allow_personalization"] = allowPersonalization;
        payload["enable_notifications"] = enableNotifications;
        return payload;
    }
}

struct SDISite {
    string tenantId;
    string siteId;
    string name;
    string description;
    string siteAlias;
    string runtimeUrl;
    bool isDefault;
    string[] roles;
    SDISiteSettings settings;
    Json importBundle;
    SysTime createdAt;
    SysTime updatedAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["tenant_id"] = tenantId;
        payload["site_id"] = siteId;
        payload["name"] = name;
        payload["description"] = description;
        payload["alias"] = siteAlias;
        payload["runtime_url"] = runtimeUrl;
        payload["is_default"] = isDefault;

        Json roleValues = Json.emptyArray;
        foreach (role; roles) roleValues ~= role;
        payload["roles"] = roleValues;

        payload["settings"] = settings.toJson();
        payload["created_at"] = createdAt.toISOExtString();
        payload["updated_at"] = updatedAt.toISOExtString();
        return payload;
    }

    Json toTileJson() const {
        Json payload = Json.emptyObject;
        payload["site_id"] = siteId;
        payload["title"] = name;
        payload["alias"] = siteAlias;
        payload["runtime_url"] = runtimeUrl;
        payload["is_default"] = isDefault;
        payload["role_count"] = cast(long)roles.length;
        return payload;
    }
}
