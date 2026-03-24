module uim.sap.bas.server;

import uim.sap.bas;

mixin(ShowModule!());

@safe:


class BASServer : SAPServer {
  mixin(SAPServerTemplate!BASServer);

  private BASService _service;

  this(BASService service) {
    _service = service;
  }

  private void handleRequest(HTTPServerRequest req, HTTPServerResponse res) {
    foreach (key, value; _service.config.customHeaders)
      res.headers[key] = value;

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

        if (segments.length == 4 && segments[3] == "scenarios" && req.method == HTTPMethod.GET) {
          res.writeJsonBody(_service.listScenarios(tenantId), 200);
          return;
        }

        if (segments.length == 4 && segments[3] == "templates" && req.method == HTTPMethod.GET) {
          auto scenarioId = req.query.get("scenario_id", "");
          res.writeJsonBody(_service.listTemplates(tenantId, scenarioId), 200);
          return;
        }

        if (segments.length == 4 && segments[3] == "workspaces") {
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listWorkspaces(tenantId), 200);
            return;
          }
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.createWorkspace(tenantId, req.json), 200);
            return;
          }
        }

        if (segments.length == 6 && segments[3] == "workspaces" && segments[5] == "wizard-runs") {
          auto workspaceId = segments[4];
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listWizardRuns(tenantId, workspaceId), 200);
            return;
          }
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.runWizard(tenantId, workspaceId, req.json), 200);
            return;
          }
        }

        if (segments.length == 6 && segments[3] == "workspaces" && segments[5] == "terminal-sessions") {
          auto workspaceId = segments[4];
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listTerminalSessions(tenantId, workspaceId), 200);
            return;
          }
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.createTerminalSession(tenantId, workspaceId, req.json), 200);
            return;
          }
        }

        if (segments.length == 7 && segments[3] == "workspaces" && segments[5] == "tests" && segments[6] == "local-run" && req
          .method == HTTPMethod.POST) {
          auto workspaceId = segments[4];
          res.writeJsonBody(_service.runLocalTest(tenantId, workspaceId, req.json), 200);
          return;
        }

        if (segments.length == 6 && segments[3] == "workspaces" && segments[5] == "deployments") {
          auto workspaceId = segments[4];
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listDeployments(tenantId, workspaceId), 200);
            return;
          }
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.createDeployment(tenantId, workspaceId, req.json), 200);
            return;
          }
        }
      }

      if (segments.length == 3 && segments[0] == "v1" && segments[1] == "platform" && segments[2] == "availability" && req
        .method == HTTPMethod.GET) {
        res.writeJsonBody(_service.availability(), 200);
        return;
      }

      respondError(res, "Not found", 404);
    } catch (BASAuthorizationException e) {
      respondError(res, e.msg, 401);
    } catch (BASNotFoundException e) {
      respondError(res, e.msg, 404);
    } catch (BASValidationException e) {
      respondError(res, e.msg, 422);
    } catch (BASException e) {
      respondError(res, e.msg, 500);
    } catch (Exception e) {
      respondError(res, e.msg, 500);
    }
  }
}
