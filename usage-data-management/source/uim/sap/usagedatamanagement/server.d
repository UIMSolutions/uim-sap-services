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

  void run() {
    auto settings = new HTTPServerSettings;
    settings.port = _service.config.port;
    settings.bindAddresses = [_service.config.host];
    listenHTTP(settings, &handleRequest);
    runApplication();
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
      validateAuth(req);

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

  private void validateAuth(HTTPServerRequest req) {
    if (!_service.config.requireAuthToken) {
      return;
    }

    if (!("Authorization" in req.headers)) {
      throw new UDMAuthorizationException("Missing Authorization header");
    }

    auto expected = "Bearer " ~ _service.config.authToken;
    if (req.headers["Authorization"] != expected) {
      throw new UDMAuthorizationException("Invalid token");
    }
  }

  private string[] normalizedSegments(string subPath) {
    auto clean = subPath;
    if (clean.length > 0 && clean[0] == '/') {
      clean = clean[1 .. $];
    }
    if (clean.length > 0 && clean[$ - 1] == '/') {
      clean = clean[0 .. $ - 1];
    }

	return clean.length == 0 ? null : clean.split("/");
  }

}
