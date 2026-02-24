module uim.sap.cdm.repositories.tenant;

import models.tenant;
import std.stdio;
import std.array;
import std.json;

class TenantRepository {
    private Tenant[] tenants;

    this() {
        // Load tenants from a data source or initialize an empty array
        tenants = [];
    }

    void addTenant(Tenant tenant) {
        tenants ~= tenant;
        writeln("Tenant added: ", tenant.name);
    }

    Tenant getTenant(string tenantId) {
        foreach (tenant; tenants) {
            if (tenant.id == tenantId) {
                return tenant;
            }
        }
        return null;
    }

    void updateTenant(string tenantId, Tenant updatedTenant) {
        for (size_t i = 0; i < tenants.length; i++) {
            if (tenants[i].id == tenantId) {
                tenants[i] = updatedTenant;
                writeln("Tenant updated: ", updatedTenant.name);
                return;
            }
        }
        writeln("Tenant not found: ", tenantId);
    }

    void deleteTenant(string tenantId) {
        tenants = tenants.filter!(t => t.id != tenantId);
        writeln("Tenant deleted: ", tenantId);
    }

    Tenant[] getAllTenants() {
        return tenants;
    }

    void loadTenantsFromJson(string jsonData) {
        auto json = parseJSON(jsonData);
        foreach (tenantJson; json["tenants"].array) {
            tenants ~= Tenant(tenantJson["id"].str, tenantJson["name"].str);
        }
    }
}