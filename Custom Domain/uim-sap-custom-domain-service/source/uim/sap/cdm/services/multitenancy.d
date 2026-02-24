module uim.sap.cdm.services.multitenancy;

import models.tenant;
import repositories.tenant_repository;
import vibe.vibe;

class MultitenancyService {
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
    Tenant getTenantById(string tenantId) {
        return tenantRepo.findById(tenantId);
    }

    // Method to update tenant information
    void updateTenant(string tenantId, string newName, string newDomain) {
        auto tenant = tenantRepo.findById(tenantId);
        if (tenant !is null) {
            tenant.name = newName;
            tenant.domain = newDomain;
            tenantRepo.update(tenant);
        }
    }

    // Method to delete a tenant
    void deleteTenant(string tenantId) {
        tenantRepo.delete(tenantId);
    }

    // Method to list all tenants
    Tenant[] listTenants() {
        return tenantRepo.findAll();
    }
}