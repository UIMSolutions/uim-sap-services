module uim.sap.service.classes.tenants.controller;

import uim.sap.service;

mixin(ShowModule!());

@safe:

class SAPTenantController {
  this(MultitenancyService multitenancyService) {
    this.multitenancyService = multitenancyService;
  }

  // Endpoint to create a new tenant
  void createTenant(Tenant tenant) {
    multitenancyService.createTenant(tenant);
    // Return success response
  }

  // Endpoint to get tenant details
  Tenant getTenant(UUID tenantId) {
    return multitenancyService.getTenant(tenantId);
  }

  // Endpoint to update tenant information
  void updateTenant(UUID tenantId, Tenant tenant) {
    multitenancyService.updateTenant(tenantId, tenant);
    // Return success response
  }

  // Endpoint to delete a tenant
  void deleteTenant(UUID tenantId) {
    multitenancyService.deleteTenant(tenantId);
    // Return success response
  }

  // Endpoint to list all tenants
  Tenant[] listTenants() {
    return multitenancyService.listTenants();
  }
}
