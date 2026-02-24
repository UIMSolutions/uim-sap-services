module routes.api_routes;

import vibe.vibe;
import controllers.custom_domain_controller;
import controllers.identity_controller;
import controllers.dashboard_controller;
import controllers.tenant_controller;

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