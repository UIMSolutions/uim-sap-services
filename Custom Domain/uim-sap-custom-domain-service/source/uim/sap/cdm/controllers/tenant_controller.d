module controllers.tenant_controller;

import vibe.vibe;
import models.tenant;
import services.multitenancy_service;

class TenantController {
    private MultitenancyService multitenancyService;

    this(MultitenancyService multitenancyService) {
        this.multitenancyService = multitenancyService;
    }

    // Endpoint to create a new tenant
    void createTenant(Tenant tenant) {
        multitenancyService.createTenant(tenant);
        // Return success response
    }

    // Endpoint to get tenant details
    Tenant getTenant(string tenantId) {
        return multitenancyService.getTenant(tenantId);
    }

    // Endpoint to update tenant information
    void updateTenant(string tenantId, Tenant tenant) {
        multitenancyService.updateTenant(tenantId, tenant);
        // Return success response
    }

    // Endpoint to delete a tenant
    void deleteTenant(string tenantId) {
        multitenancyService.deleteTenant(tenantId);
        // Return success response
    }

    // Endpoint to list all tenants
    Tenant[] listTenants() {
        return multitenancyService.listTenants();
    }
}