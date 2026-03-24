module uim.sap.atp.server;

import uim.sap.atp;

mixin(ShowModule!());

@safe:

/**
 * ATPServer handles HTTP requests for the Automation Pilot service.
 * It routes requests to the appropriate service methods based on the URL path and HTTP method.
 * It also handles authentication and error responses.

    The server expects requests to be in the format:
    /{basePath}/v1/tenants/{tenantId}/...
    For example:
    - GET /{basePath}/v1/tenants/{tenantId}/catalogs
    - POST /{basePath}/v1/tenants/{tenantId}/catalogs
    - GET /{basePath}/v1/tenants/{tenantId}/catalogs/{catalogId}/commands
    - POST /{basePath}/v1/tenants/{tenantId}/catalogs/{catalogId}/commands
    - GET /{basePath}/v1/tenants/{tenantId}/executions
    - POST /{basePath}/v1/tenants/{tenantId}/executions
    - GET /{basePath}/v1/tenants/{tenantId}/backups
    - POST /{basePath}/v1/tenants/{tenantId}/backups
    - POST /{basePath}/v1/tenants/{tenantId}/backups/restore
    - GET /{basePath}/v1/tenants/{tenantId}/vault/inputs
    - POST /{basePath}/v1/tenants/{tenantId}/vault/inputs
    - GET /{basePath}/v1/tenants/{tenantId}/schedules
    - POST /{basePath}/v1/tenants/{tenantId}/schedules
    - GET /{basePath}/v1/tenants/{tenantId}/event-triggers
    - POST /{basePath}/v1/tenants/{tenantId}/event-triggers
    - POST /{basePath}/v1/tenants/{tenantId}/events/fire
    - POST /{basePath}/v1/tenants/{tenantId}/ai/generate
    - POST /{basePath}/v1/tenants/{tenantId}/private-env/operate    

* Note: The server uses a simple token-based authentication mechanism. If `requireAuthToken` is enabled in the configuration, it expects an `Authorization` header with the value `Bearer {authToken}`. 
 */
class ATPServer : SAPServer {
  mixin(SAPServerTemplate!ATPServer);

  private ATPService _service;

  this(ATPService service) {
    _service = service;
  }

  override void handleRequest(HTTPServerRequest req, HTTPServerResponse res) {
    super.handleRequest(req, res);

    auto basePath = _service.config.basePath;
    auto path = req.path;
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

        if (segments.length == 4 && segments[3] == "catalogs") {
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listCatalogs(tenantId), 200);
            return;
          }
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.upsertCatalog(tenantId, req.json), 200);
            return;
          }
        }

        if (segments.length == 6 && segments[3] == "catalogs" && segments[5] == "commands") {
          auto catalogId = segments[4];
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listCommands(tenantId, catalogId), 200);
            return;
          }
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.upsertCommand(tenantId, catalogId, req.json), 200);
            return;
          }
        }

        if (segments.length == 4 && segments[3] == "executions") {
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listExecutions(tenantId), 200);
            return;
          }
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.runPredefinedCommand(tenantId, req.json), 200);
            return;
          }
        }

        if (segments.length == 4 && segments[3] == "backups") {
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listBackups(tenantId), 200);
            return;
          }
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.backupContent(tenantId, req.json), 200);
            return;
          }
        }

        if (segments.length == 5 && segments[3] == "backups" && segments[4] == "restore" && req.method == HTTPMethod
          .POST) {
          res.writeJsonBody(_service.restoreContent(tenantId, req.json), 200);
          return;
        }

        if (segments.length == 5 && segments[3] == "vault" && segments[4] == "inputs") {
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listSecretInputs(tenantId), 200);
            return;
          }
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.upsertSecretInput(tenantId, req.json), 200);
            return;
          }
        }

        if (segments.length == 4 && segments[3] == "schedules") {
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listSchedules(tenantId), 200);
            return;
          }
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.upsertSchedule(tenantId, req.json), 200);
            return;
          }
        }

        if (segments.length == 4 && segments[3] == "event-triggers") {
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listEventTriggers(tenantId), 200);
            return;
          }
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.upsertEventTrigger(tenantId, req.json), 200);
            return;
          }
        }

        if (segments.length == 5 && segments[3] == "events" && segments[4] == "fire" && req.method == HTTPMethod
          .POST) {
          res.writeJsonBody(_service.fireEvent(tenantId, req.json), 200);
          return;
        }

        if (segments.length == 5 && segments[3] == "ai" && segments[4] == "generate" && req.method == HTTPMethod
          .POST) {
          res.writeJsonBody(_service.generateAiContent(tenantId, req.json), 200);
          return;
        }

        if (segments.length == 5 && segments[3] == "private-env" && segments[4] == "operate" && req.method == HTTPMethod
          .POST) {
          res.writeJsonBody(_service.executePrivateOperation(tenantId, req.json), 200);
          return;
        }
      }

      respondError(res, "Not found", 404);
    } catch (ATPAuthorizationException e) {
      respondError(res, e.msg, 401);
    } catch (ATPNotFoundException e) {
      respondError(res, e.msg, 404);
    } catch (ATPValidationException e) {
      respondError(res, e.msg, 422);
    } catch (ATPException e) {
      respondError(res, e.msg, 500);
    } catch (Exception e) {
      respondError(res, e.msg, 500);
    }
  }

}
