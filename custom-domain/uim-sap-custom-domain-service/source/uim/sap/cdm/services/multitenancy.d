module uim.sap.cdm.services.multitenancy;

import models.tenant;
import repositories.tenant_repository;
import vibe.vibe;

/**
    * The MultitenancyService class provides methods to manage tenants in a multitenant environment.
    * It allows for creating, retrieving, updating, and deleting tenant information.
    *
    * To use this service, create an instance of MultitenancyService and call the desired methods.
    * Example:
    *     auto multitenancyService = new MultitenancyService();
    *     auto tenant = multitenancyService.createTenant("Tenant Name", "tenant.domain.com");
    */
class MultitenancyService : SAPService {
    private TenantRepository tenantRepo;

    this() {
        tenantRepo = new TenantRepository();
    }

    // Method to create a new tenant
    Tenant createTenant(string name, string domain) {
        auto tenant = new Tenant(name, domain);
        tenantRepo.save(tenant);
        return tenant;
    }

    // Method to retrieve a tenant by ID
    Tenant getTenantById(UUID tenantId) {
        return tenantRepo.findById(tenantId);
    }

    // Method to update tenant information
    void updateTenant(UUID tenantId, string newName, string newDomain) {
        auto tenant = tenantRepo.findById(tenantId);
        if (tenant !is null) {
            tenant.name = newName;
            tenant.domain = newDomain;
            tenantRepo.update(tenant);
        }
    }

    // Method to delete a tenant
    void deleteTenant(UUID tenantId) {
        tenantRepo.delete(tenantId);
    }

    // Method to list all tenants
    Tenant[] listTenants() {
        return tenantRepo.findAll();
    }
}