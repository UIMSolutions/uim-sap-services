module routes.api_routes;

import vibe.vibe;
import controllers.custom_domain_controller;
import controllers.identity_controller;
import controllers.dashboard_controller;
import controllers.tenant_controller;

/**
    * This module defines the API routes for the Custom Domain Service.
    * It includes routes for managing custom domains, identity protection, dashboard KPIs, and tenant management.
    *
    * To set up the API routes, call the setupApiRoutes function during your server initialization.
    * Example:
    *     auto server = new HTTPServer();
    *     setupApiRoutes();
    */
void setupApiRoutes() {
    // Custom Domain Routes
    route("/api/custom-domains", "GET", &CustomDomainController.getAll);
    route("/api/custom-domains", "POST", &CustomDomainController.create);
    route("/api/custom-domains/:id", "GET", &CustomDomainController.get);
    route("/api/custom-domains/:id", "PUT", &CustomDomainController.update);
    route("/api/custom-domains/:id", "DELETE", &CustomDomainController.delete);

    // Identity Protection Routes
    route("/api/identity/protect", "POST", &IdentityController.uploadCertificate);
    route("/api/identity/protect/:id", "GET", &IdentityController.getCertificate);

    // Dashboard Routes
    route("/api/dashboard/kpis", "GET", &DashboardController.getKpis);
    route("/api/dashboard/warnings", "GET", &DashboardController.getExpirationWarnings);

    // Tenant Management Routes
    route("/api/tenants", "GET", &TenantController.getAllTenants);
    route("/api/tenants", "POST", &TenantController.createTenant);
    route("/api/tenants/:id", "GET", &TenantController.getTenant);
    route("/api/tenants/:id", "PUT", &TenantController.updateTenant);
    route("/api/tenants/:id", "DELETE", &TenantController.deleteTenant);
}