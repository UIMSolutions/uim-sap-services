module uim.sap.usagedatamanagement.server;

import uim.sap.usagedatamanagement;

mixin(ShowModule!());

@safe:

class UDMServer : SAPServer {
mixin(SAPServerTemplate!UDMServer);

  private UDMService _service;

  this(UDMService service) {
    _service = service;
  }

  private void handleRequest(HTTPServerRequest req, HTTPServerResponse res) {
    foreach (key, value; _service.config.customHeaders) {
      res.headers[key] = value;
    }

    auto basePath = _service.config.basePath;
    auto path = req.path;

    if (!matchesBasePath(path, basePath)) {
      respondError(res, "Not found", 404);
      return;
    }

    string subPath = "/";
    if (path.length > basePath.length) {
      subPath = path[basePath.length .. $];
    }

    if (subPath == "/health" && req.method == HTTPMethod.GET) {
      res.writeJsonBody(_service.health(), 200);
      return;
    }

    if (subPath == "/ready" && req.method == HTTPMethod.GET) {
      res.writeJsonBody(_service.ready(), 200);
      return;
    }

    try {
      validateAuth(req, _service.config);

      if (subPath == "/v1/discovery" && req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.discovery(), 200);
        return;
      }

      if (subPath == "/v1/tenants" && req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.listTenants(), 200);
        return;
      }

      auto segments = normalizedSegments(subPath);
      if (segments.length >= 3 && segments[0] == "v1" && segments[1] == "tenants") {
        auto tenantId = segments[2];

        if (segments.length == 4 && segments[3] == "usage-events") {
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listUsageEvents(tenantId), 200);
            return;
          }

          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.ingestUsageEvent(tenantId, req.json), 200);
            return;
          }
        }

        if (segments.length == 5 && segments[3] == "reports" && req.method == HTTPMethod.POST) {
          if (segments[4] == "monthly-usage") {
            res.writeJsonBody(_service.monthlyUsageReport(tenantId, req.json), 200);
            return;
          }

          if (segments[4] == "subaccount-usage") {
            res.writeJsonBody(_service.subaccountUsageReport(tenantId, req.json), 200);
            return;
          }

          if (segments[4] == "monthly-subaccount-costs") {
            res.writeJsonBody(_service.monthlySubaccountCostsReport(tenantId, req.json), 200);
            return;
          }
        }
      }

      respondError(res, "Not found", 404);
    } catch (UDMAuthorizationException e) {
      respondError(res, e.msg, 401);
    } catch (UDMValidationException e) {
      respondError(res, e.msg, 422);
    } catch (UDMNotFoundException e) {
      respondError(res, e.msg, 404);
    } catch (UDMException e) {
      respondError(res, e.msg, 500);
    } catch (Exception e) {
      respondError(res, e.msg, 500);
    }
  }

  private bool matchesBasePath(string path, string basePath) {
    return path == basePath ? true : path.startsWith(basePath ~ "/");
  }
}
