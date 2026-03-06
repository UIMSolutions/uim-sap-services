/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.datasphere.models.tenantadminstate;

import uim.sap.datasphere;

@safe:

/**
    * Represents the state of a tenant administrator, including connectivity, maintenance mode, and associated users.
    *
    * This struct is used to track the status of tenant administration and can be extended with custom properties as needed.
    *
    * Fields:
    * - tenantName: The name of the tenant.
    * - connectivityPrepared: A boolean indicating whether the tenant's connectivity is prepared.
    * - maintenanceMode: A boolean indicating whether the tenant is currently in maintenance mode.
    * - lastMaintenance: A string representing the timestamp of the last maintenance activity.
    * - users: An array of user IDs that are associated with the tenant administration.
    * - custom: A JSON object for storing any additional custom properties related to tenant administration.
    *
    * The `toJson` method allows for easy serialization of the tenant administration state into a JSON format, facilitating storage and integration with logging systems or external monitoring tools.
    *
    * Example usage:
    * ```
    * DATTenantAdminState state;
    * state.tenantName = "ExampleTenant";
    * state.connectivityPrepared = true;
    * state.maintenanceMode = false;
    * state.lastMaintenance = "2024-06-01T12:00:00Z";
    * state.users = ["user1", "user2"];
    * state.custom = Json.object("key", "value");
    * Json jsonState = state.toJson();
    * ```
    */

struct DATTenantAdminState {
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