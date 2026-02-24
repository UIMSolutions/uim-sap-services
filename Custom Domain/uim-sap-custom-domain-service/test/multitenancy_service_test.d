module multitenancy_service_test;

import vibe.vibe;
import source.services.multitenancy_service;
import source.models.tenant;
import std.stdio;

void main()
{
    // Initialize the Vibe.D application
    auto app = createApp();

    // Test case: Create a new tenant
    void testCreateTenant()
    {
        auto service = new MultitenancyService();
        auto newTenant = new Tenant("tenant1", "Tenant One", "tenant1@example.com");

        // Act
        service.createTenant(newTenant);

        // Assert
        assert(service.getTenant("tenant1") !is null);
        writeln("Test Create Tenant Passed");
    }

    // Test case: Retrieve existing tenant
    void testGetTenant()
    {
        auto service = new MultitenancyService();
        auto existingTenant = service.getTenant("tenant1");

        // Assert
        assert(existingTenant !is null);
        assert(existingTenant.name == "Tenant One");
        writeln("Test Get Tenant Passed");
    }

    // Test case: Update tenant information
    void testUpdateTenant()
    {
        auto service = new MultitenancyService();
        auto updatedTenant = new Tenant("tenant1", "Updated Tenant One", "updated@example.com");

        // Act
        service.updateTenant(updatedTenant);

        // Assert
        auto tenant = service.getTenant("tenant1");
        assert(tenant.email == "updated@example.com");
        writeln("Test Update Tenant Passed");
    }

    // Test case: Delete tenant
    void testDeleteTenant()
    {
        auto service = new MultitenancyService();

        // Act
        service.deleteTenant("tenant1");

        // Assert
        assert(service.getTenant("tenant1") is null);
        writeln("Test Delete Tenant Passed");
    }

    // Run tests
    testCreateTenant();
    testGetTenant();
    testUpdateTenant();
    testDeleteTenant();

    // Start the application
    runApp();
}