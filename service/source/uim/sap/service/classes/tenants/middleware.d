module uim.sap.service.classes.tenants.middleware;
import uim.sap.service;

mixin(ShowModule!());

@safe:
/*
class SAPTenantMiddleware {
  private SAPTenantRepository tenantRepository;

  this(SAPTenantRepository tenantRepository) {
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
*/