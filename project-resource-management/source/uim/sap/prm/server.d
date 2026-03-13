module uim.sap.prm.server;

import std.array : split;
import std.algorithm.searching : startsWith;

import uim.sap.prm;

mixin(ShowModule!());

@safe:

class PRMServer {
  private PRMService _service;

  this(PRMService service) {
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
    if (!path.startsWith(basePath)) {
      respondError(res, "Not found", 404);
      return;
    }

    auto subPath = path[basePath.length .. $];
    if (subPath.length == 0) {
      subPath = "/";
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
      auto segments = normalizedSegments(subPath);

      if (segments.length == 2 && segments[0] == "v1" && segments[1] == "business-partners") {
        if (req.method == HTTPMethod.GET) {
          res.writeJsonBody(_service.listGlobalPartners(), 200);
          return;
        }
        if (req.method == HTTPMethod.POST) {
          res.writeJsonBody(_service.upsertGlobalPartner(req.json), 200);
          return;
        }
      }

      if (segments.length >= 3 && segments[0] == "v1" && segments[1] == "tenants") {
        auto tenantId = segments[2];

        if (segments.length == 4 && segments[3] == "projects") {
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listProjects(tenantId), 200);
            return;
          }
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.upsertProject(tenantId, req.json), 200);
            return;
          }
        }

        if (segments.length == 5 && segments[3] == "projects") {
          auto projectId = segments[4];
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.getProject(tenantId, projectId), 200);
            return;
          }
          if (req.method == HTTPMethod.PUT) {
            Json payload = req.json;
            payload["project_id"] = projectId;
            res.writeJsonBody(_service.upsertProject(tenantId, payload), 200);
            return;
          }
          if (req.method == HTTPMethod.DELETE) {
            res.writeJsonBody(_service.deleteProject(tenantId, projectId), 200);
            return;
          }
        }

        if (segments.length == 6 && segments[3] == "projects" && segments[5] == "work-packages") {
          auto projectId = segments[4];
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listWorkPackages(tenantId, projectId), 200);
            return;
          }
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.upsertWorkPackage(tenantId, projectId, req.json), 200);
            return;
          }
        }

        if (segments.length == 6 && segments[3] == "projects" && segments[5] == "board-items") {
          auto projectId = segments[4];
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listBoardItems(tenantId, projectId), 200);
            return;
          }
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.upsertBoardItem(tenantId, projectId, req.json), 200);
            return;
          }
        }

        if (segments.length == 6
            && segments[3] == "projects"
            && segments[5] == "board"
            && req.method == HTTPMethod.GET) {
          auto projectId = segments[4];
          res.writeJsonBody(_service.listBoardItems(tenantId, projectId), 200);
          return;
        }

        if (segments.length == 6
            && segments[3] == "projects"
            && segments[5] == "partner-invitations"
            && req.method == HTTPMethod.POST) {
          auto projectId = segments[4];
          res.writeJsonBody(_service.invitePartner(tenantId, projectId, req.json), 200);
          return;
        }

        if (segments.length == 6
            && segments[3] == "projects"
            && segments[5] == "resource-match"
            && req.method == HTTPMethod.POST) {
          auto projectId = segments[4];
          res.writeJsonBody(_service.matchResourcesForProject(tenantId, projectId, req.json), 200);
          return;
        }

        if (segments.length == 4 && segments[3] == "partners") {
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listTenantPartners(tenantId), 200);
            return;
          }
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.linkTenantPartner(tenantId, req.json), 200);
            return;
          }
        }

        if (segments.length == 4 && segments[3] == "delivery-processes") {
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listDeliveryProcesses(tenantId), 200);
            return;
          }
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.upsertDeliveryProcess(tenantId, req.json), 200);
            return;
          }
        }

        if (segments.length == 4 && segments[3] == "resources") {
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listResources(tenantId), 200);
            return;
          }
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.upsertResource(tenantId, req.json), 200);
            return;
          }
        }

        if (segments.length == 5
            && segments[3] == "resources"
            && segments[4] == "search"
            && req.method == HTTPMethod.POST) {
          res.writeJsonBody(_service.searchResourcesBySkills(tenantId, req.json), 200);
          return;
        }

        if (segments.length == 5
            && segments[3] == "resources"
            && segments[4] == "capacity"
            && req.method == HTTPMethod.GET) {
          res.writeJsonBody(_service.resourceCapacity(tenantId), 200);
          return;
        }

        if (segments.length == 4 && segments[3] == "resource-requests") {
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listResourceRequests(tenantId), 200);
            return;
          }
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.upsertResourceRequest(tenantId, req.json), 200);
            return;
          }
        }
      }

      respondError(res, "Not found", 404);
    } catch (PRMAuthorizationException e) {
      respondError(res, e.msg, 401);
    } catch (PRMNotFoundException e) {
      respondError(res, e.msg, 404);
    } catch (PRMValidationException e) {
      respondError(res, e.msg, 422);
    } catch (PRMException e) {
      respondError(res, e.msg, 500);
    } catch (Exception e) {
      respondError(res, e.msg, 500);
    }
  }

  private void validateAuth(HTTPServerRequest req) {
    if (!_service.config.requireAuthToken) {
      return;
    }
    if (!("Authorization" in req.headers)) {
      throw new PRMAuthorizationException("Missing Authorization header");
    }
    auto expected = "Bearer " ~ _service.config.authToken;
    if (req.headers["Authorization"] != expected) {
      throw new PRMAuthorizationException("Invalid token");
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
    if (clean.length == 0) {
      return [];
    }
    return clean.split("/");
  }

  private void respondError(HTTPServerResponse res, string message, int statusCode) {
    Json payload = Json.emptyObject;
    payload["success"] = false;
    payload["message"] = message;
    payload["statusCode"] = statusCode;
    res.writeJsonBody(payload, statusCode);
  }
}
