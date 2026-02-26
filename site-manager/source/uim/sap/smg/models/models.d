/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.smg.models;

import std.datetime : SysTime;

import vibe.data.json : Json;

struct SMGSite {
    string tenantId;
    string siteId;
    string siteName;
    string description;
    string lifecycle;
    string[] assignedRoles;
    string[] pages;
    string[] catalogs;
    SysTime createdAt;
    SysTime updatedAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["tenant_id"] = tenantId;
        payload["site_id"] = siteId;
        payload["site_name"] = siteName;
        payload["description"] = description;
        payload["lifecycle"] = lifecycle;
        Json assignedRoleValues = Json.emptyArray;
        foreach (role; assignedRoles) assignedRoleValues ~= role;
        payload["assigned_roles"] = assignedRoleValues;

        Json pageValues = Json.emptyArray;
        foreach (page; pages) pageValues ~= page;
        payload["pages"] = pageValues;

        Json catalogValues = Json.emptyArray;
        foreach (catalog; catalogs) catalogValues ~= catalog;
        payload["catalogs"] = catalogValues;
        payload["created_at"] = createdAt.toISOExtString();
        payload["updated_at"] = updatedAt.toISOExtString();
        return payload;
    }
}

struct SMGSubaccountSettings {
    string tenantId;
    string defaultSiteId;
    string launchpadMode;
    string themeId;
    bool enableContentApproval;
    bool enableTransport;
    bool enforceRoleBasedAccess;
    string lastChangedBy;
    SysTime updatedAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["tenant_id"] = tenantId;
        payload["default_site_id"] = defaultSiteId;
        payload["launchpad_mode"] = launchpadMode;
        payload["theme_id"] = themeId;
        payload["enable_content_approval"] = enableContentApproval;
        payload["enable_transport"] = enableTransport;
        payload["enforce_role_based_access"] = enforceRoleBasedAccess;
        payload["last_changed_by"] = lastChangedBy;
        payload["updated_at"] = updatedAt.toISOExtString();
        return payload;
    }
}
