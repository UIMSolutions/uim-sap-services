module uim.sap.smg.models.subaccountsettings;

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
