struct TenantAdminState {
    string tenantName;
    bool connectivityPrepared;
    bool maintenanceMode;
    string lastMaintenance;
    string[] users;
    Json custom;

    Json toJson() const {
        Json payload = Json.emptyObject;
        Json usersPayload = Json.emptyArray;
        foreach (user; users) usersPayload ~= user;

        payload["tenant_name"] = tenantName;
        payload["connectivity_prepared"] = connectivityPrepared;
        payload["maintenance_mode"] = maintenanceMode;
        payload["last_maintenance"] = lastMaintenance;
        payload["users"] = usersPayload;
        payload["custom"] = custom;
        return payload;
    }
}