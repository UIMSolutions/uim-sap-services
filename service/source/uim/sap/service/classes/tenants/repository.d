module uim.sap.service.classes.tenants.repository;

import uim.sap.service;

mixin(ShowModule!());

@safe:

class SAPTenantRepository {
  private ISAPTenant[UUID] tenants;

  this() {
    // Load tenants from a data source or initialize an empty array
    tenants = null;
  }

  void addTenant(ISAPTenant tenant) {
    tenants[tenant.id] = tenant;
    writeln("Tenant added: ", tenant.name);
  }

  ISAPTenant getTenant(UUID tenantId) {
    return tenantId in tenants ? tenants[tenantId] : null;
  }

  void updateTenant(UUID tenantId, ISAPTenant updatedTenant) {
    if (tenantId in tenants) {
      tenants[tenantId] = updatedTenant;
      writeln("Tenant updated: ", updatedTenant.name);
      return;
    }
    writeln("Tenant not found: ", tenantId);
  }

  void deleteTenant(UUID tenantId) {
    if (tenantId in tenants) {
      tenants.remove(tenantId);
      writeln("Tenant deleted: ", tenantId);
      return;
    }
    writeln("Tenant not found: ", tenantId);
  }

  ISAPTenant[] getAllTenants() {
    return tenants.values.array;
  }

  void loadTenantsFromJson(string jsonData) {
    auto json = parseJSON(jsonData);
    foreach (tenantJson; json["tenants"].array) {
      tenants[Tenant(tenantJson["id"].get!string, tenantJson["name"].getString).id] = Tenant(
        tenantJson["id"].get!string, tenantJson["name"].getString);
    }
  }
}
