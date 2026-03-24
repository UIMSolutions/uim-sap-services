module uim.sap.cid.server;

import uim.sap.cid;

mixin(ShowModule!());

@safe:

// ---------------------------------------------------------------------------
// CIDServer – Vibe.D HTTP server for Continuous Integration and Delivery
// ---------------------------------------------------------------------------
class CIDServer {
  private CIDService _service;

  this(CIDService service) {
    _service = service;
  }

  // -----------------------------------------------------------------------
  // Root dispatcher
  // -----------------------------------------------------------------------
  override void handleRequest(HTTPServerRequest req, HTTPServerResponse res) {
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

    // ── Dashboard ─────────────────────────────────────────────────────
    if (subPath == "/" && req.method == HTTPMethod.GET) {
      res.contentType = "text/html; charset=utf-8";
      res.writeBody(_service.dashboardHtml());
      return;
    }

    // ── Health / readiness ────────────────────────────────────────────
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
      routeRequest(req, res, subPath);
    } catch (CIDNotFoundException e) {
      respondError(res, e.msg, 404);
    } catch (CIDValidationException e) {
      respondError(res, e.msg, 400);
    } catch (CIDAuthorizationException e) {
      respondError(res, e.msg, 403);
    } catch (CIDPipelineException e) {
      respondError(res, e.msg, 409);
    } catch (CIDException e) {
      respondError(res, e.msg, 500);
    }
  }

  // -----------------------------------------------------------------------
  // Route matching
  // -----------------------------------------------------------------------
  private void routeRequest(HTTPServerRequest req, HTTPServerResponse res, string subPath) {
    auto segs = segments(subPath);

    // All API routes: /v1/tenants/:tenantId/...
    if (segs.length < 3 || segs[0] != "v1" || segs[1] != "tenants") {
      respondError(res, "Not found", 404);
      return;
    }
    auto tenantId = segs[2];

    // ── /repositories ─────────────────────────────────────────────────
    if (segs.length == 4 && segs[3] == "repositories") {
      if (req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.listRepositories(tenantId), 200);
        return;
      }
      if (req.method == HTTPMethod.POST) {
        res.writeJsonBody(_service.createRepository(tenantId, req.json), 201);
        return;
      }
    }
    if (segs.length == 5 && segs[3] == "repositories") {
      if (req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.getRepository(tenantId, segs[4]), 200);
        return;
      }
      if (req.method == HTTPMethod.DELETE) {
        res.writeJsonBody(_service.removeRepository(tenantId, segs[4]), 200);
        return;
      }
    }

    // ── /credentials ──────────────────────────────────────────────────
    if (segs.length == 4 && segs[3] == "credentials") {
      if (req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.listCredentials(tenantId), 200);
        return;
      }
      if (req.method == HTTPMethod.POST) {
        res.writeJsonBody(_service.createCredential(tenantId, req.json), 201);
        return;
      }
    }
    if (segs.length == 5 && segs[3] == "credentials") {
      if (req.method == HTTPMethod.DELETE) {
        res.writeJsonBody(_service.removeCredential(tenantId, segs[4]), 200);
        return;
      }
    }

    // ── /pipelines ────────────────────────────────────────────────────
    if (segs.length == 4 && segs[3] == "pipelines") {
      if (req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.listPipelines(tenantId), 200);
        return;
      }
      if (req.method == HTTPMethod.POST) {
        res.writeJsonBody(_service.createPipeline(tenantId, req.json), 201);
        return;
      }
    }
    if (segs.length == 5 && segs[3] == "pipelines") {
      if (req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.getPipeline(tenantId, segs[4]), 200);
        return;
      }
      if (req.method == HTTPMethod.DELETE) {
        res.writeJsonBody(_service.removePipeline(tenantId, segs[4]), 200);
        return;
      }
    }

    // ── /pipelines/:id/trigger ────────────────────────────────────────
    if (segs.length == 6 && segs[3] == "pipelines" && segs[5] == "trigger"
      && req.method == HTTPMethod.POST) {
      res.writeJsonBody(_service.triggerBuild(tenantId, segs[4], req.json), 201);
      return;
    }

    // ── /builds ───────────────────────────────────────────────────────
    if (segs.length == 4 && segs[3] == "builds") {
      if (req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.listBuilds(tenantId), 200);
        return;
      }
    }
    if (segs.length == 5 && segs[3] == "builds") {
      if (req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.getBuild(tenantId, segs[4]), 200);
        return;
      }
    }

    // ── /builds/:id/abort ─────────────────────────────────────────────
    if (segs.length == 6 && segs[3] == "builds" && segs[5] == "abort"
      && req.method == HTTPMethod.POST) {
      res.writeJsonBody(_service.abortBuild(tenantId, segs[4]), 200);
      return;
    }

    // ── /builds/:id/stages ────────────────────────────────────────────
    if (segs.length == 6 && segs[3] == "builds" && segs[5] == "stages") {
      if (req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.listStages(tenantId, segs[4]), 200);
        return;
      }
    }

    // ── /builds/:id/logs ──────────────────────────────────────────────
    if (segs.length == 6 && segs[3] == "builds" && segs[5] == "logs") {
      if (req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.listBuildLogs(tenantId, segs[4]), 200);
        return;
      }
    }

    respondError(res, "Not found", 404);
  }

  // -----------------------------------------------------------------------
  // Auth
  // -----------------------------------------------------------------------
  private void validateAuth(HTTPServerRequest req) {
    if (!_service.config.requireAuthToken)
      return;
    auto authHeader = req.headers.get("Authorization", "");
    if (authHeader.length == 0)
      throw new CIDAuthorizationException("Missing Authorization header");
    if (authHeader.length < 8 || authHeader[0 .. 7] != "Bearer ")
      throw new CIDAuthorizationException("Authorization must use Bearer scheme");
    if (authHeader[7 .. $] != _service.config.authToken)
      throw new CIDAuthorizationException("Invalid auth token");
  }

  // -----------------------------------------------------------------------
  // Helpers
  // -----------------------------------------------------------------------
  private static string[] segments(string path) {
    auto parts = path.split("/");
    string[] segs;
    foreach (p; parts)
      if (p.length > 0)
        segs ~= p;
    return segs;
  }

  private static void respondError(HTTPServerResponse res, string message, int status) {
    Json err = Json.emptyObject;
    err["error"] = message;
    err["status"] = status;
    res.writeJsonBody(err, status);
  }
}
