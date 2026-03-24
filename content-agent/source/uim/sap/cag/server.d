module uim.sap.cag.server;

import uim.sap.cag;

mixin(ShowModule!());

@safe:

class CAGServer : SAPServer {
  mixin(SAPServerTemplate!CAGServer);

  private CAGService _service;

  this(CAGService service) {
    _service = service;
  }

  override void handleRequest(HTTPServerRequest req, HTTPServerResponse res) {
    super.handleRequest(req, res);

    if (subPath == "/" && req.method == HTTPMethod.GET) {
      res.contentType = "text/html; charset=utf-8";
      res.writeBody(_service.dashboardHtml());
      return;
    }

    try {
      validateAuth(req, _service.config);

      auto segments = normalizedSegments(subPath);
      if (segments.length >= 3 && segments[0] == "v1" && segments[1] == "tenants") {
        auto tenantId = segments[2];

        if (segments.length == 4 && segments[3] == "providers") {
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listProviders(tenantId), 200);
            return;
          }
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.upsertProvider(tenantId, req.json), 200);
            return;
          }
        }

        if (segments.length == 4 && segments[3] == "content") {
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listContent(tenantId), 200);
            return;
          }
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.upsertContent(tenantId, req.json), 200);
            return;
          }
        }

        if (segments.length == 5 && segments[3] == "content" && req.method == HTTPMethod.GET) {
          res.writeJsonBody(_service.getContent(tenantId, segments[4]), 200);
          return;
        }

        if (segments.length == 4 && segments[3] == "queues") {
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listQueues(tenantId), 200);
            return;
          }
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.upsertQueue(tenantId, req.json), 200);
            return;
          }
        }

        if (segments.length == 4 && segments[3] == "assemblies") {
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listAssemblies(tenantId), 200);
            return;
          }
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.createAssembly(tenantId, req.json), 200);
            return;
          }
        }

        if (segments.length == 5 && segments[3] == "assemblies" && req.method == HTTPMethod.GET) {
          res.writeJsonBody(_service.getAssembly(tenantId, segments[4]), 200);
          return;
        }

        if (segments.length == 6
          && segments[3] == "assemblies"
          && segments[5] == "mtar"
          && req.method == HTTPMethod.GET) {
          res.writeJsonBody(_service.getMtarMetadata(tenantId, segments[4]), 200);
          return;
        }

        if (segments.length == 6
          && segments[3] == "assemblies"
          && segments[5] == "export"
          && req.method == HTTPMethod.POST) {
          res.writeJsonBody(_service.exportAssembly(tenantId, segments[4], req.json), 200);
          return;
        }

        if (segments.length == 4 && segments[3] == "activities" && req.method == HTTPMethod.GET) {
          res.writeJsonBody(_service.listActivities(tenantId), 200);
          return;
        }
      }

      respondError(res, "Not found", 404);
    } catch (CAGAuthorizationException e) {
      respondError(res, e.msg, 401);
    } catch (CAGNotFoundException e) {
      respondError(res, e.msg, 404);
    } catch (CAGValidationException e) {
      respondError(res, e.msg, 422);
    } catch (CAGException e) {
      respondError(res, e.msg, 500);
    } catch (Exception e) {
      respondError(res, e.msg, 500);
    }
  }
}
