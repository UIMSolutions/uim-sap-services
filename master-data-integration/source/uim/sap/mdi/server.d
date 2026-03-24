module uim.sap.mdi.server;

import uim.sap.mdi;

mixin(ShowModule!());

@safe:

class MDIServer : SAPServer {
  mixin(SAPServerTemplate!MDIServer);

  private MDIService _service;

  this(MDIService service) {
    _service = service;
  }

  override void handleRequest(HTTPServerRequest req, HTTPServerResponse res) {
    super.handleRequest(req, res);

    if (!path.startsWith(basePath)) {
      respondError(res, "Not found", 404);
      return;
    }

    auto subPath = path[basePath.length .. $];
    if (subPath.length == 0)
      subPath = "/";

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
      auto segments = normalizedSegments(subPath);

      if (segments.length >= 3 && segments[0] == "v1" && segments[1] == "tenants") {
        auto tenantId = segments[2];

        if (segments.length == 4 && segments[3] == "clients") {
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listClients(tenantId), 200);
            return;
          }
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.upsertClient(tenantId, req.json), 200);
            return;
          }
        }

        if (segments.length == 5 && segments[3] == "filters") {
          auto filterId = segments[4];
          if (req.method == HTTPMethod.PUT) {
            res.writeJsonBody(_service.upsertFilter(tenantId, filterId, req.json), 200);
            return;
          }
        }

        if (segments.length == 4 && segments[3] == "filters" && req.method == HTTPMethod.GET) {
          res.writeJsonBody(_service.listFilters(tenantId), 200);
          return;
        }

        if (segments.length == 5 && segments[3] == "extensions") {
          auto extensionId = segments[4];
          if (req.method == HTTPMethod.PUT) {
            res.writeJsonBody(_service.upsertExtension(tenantId, extensionId, req.json), 200);
            return;
          }
        }

        if (segments.length == 4 && segments[3] == "extensions" && req.method == HTTPMethod.GET) {
          res.writeJsonBody(_service.listExtensions(tenantId), 200);
          return;
        }

        if (segments.length == 5 && segments[3] == "replication" && segments[4] == "run" && req.method == HTTPMethod
          .POST) {
          res.writeJsonBody(_service.replicate(tenantId, req.json), 200);
          return;
        }

        if (segments.length == 5 && segments[3] == "replication" && segments[4] == "jobs" && req.method == HTTPMethod
          .GET) {
          res.writeJsonBody(_service.listReplications(tenantId), 200);
          return;
        }
      }

      respondError(res, "Not found", 404);
    } catch (MDIAuthorizationException e) {
      respondError(res, e.msg, 401);
    } catch (MDINotFoundException e) {
      respondError(res, e.msg, 404);
    } catch (MDIValidationException e) {
      respondError(res, e.msg, 422);
    } catch (MDIException e) {
      respondError(res, e.msg, 500);
    } catch (Exception e) {
      respondError(res, e.msg, 500);
    }
  }
}
