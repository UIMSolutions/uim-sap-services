module middlewares.tenant;

import vibe.vibe;
import models.tenant;

/**
    * This middleware handles tenant identification for incoming requests.
    * It checks for a tenant ID in the request headers and attaches the corresponding tenant information to the request context.
    *
    * To use this middleware, add it to your server configuration before your route handlers.
    * Example:
    *     auto server = new HTTPServer();
    *     server.addMiddleware(new TenantMiddleware(tenantRepository));
    */
class TenantMiddleware {
    private TenantRepository tenantRepository;

    this(TenantRepository tenantRepository) {
        this.tenantRepository = tenantRepository;
    }

    void handleRequest(HttpServerRequest req, HttpServerResponse res) {
        auto tenantId = req.getHeader("X-Tenant-ID");
        if (tenantId !is null) {
            auto tenant = tenantRepository.findById(tenantId);
            if (tenant !is null) {
                req.setUserData(tenant);
            } else {
                res.statusCode = HttpStatus.notFound;
                res.writeBody("Tenant not found");
                res.send();
                return;
            }
        } else {
            res.statusCode = HttpStatus.badRequest;
            res.writeBody("Missing Tenant ID");
            res.send();
            return;
        }
    }
}