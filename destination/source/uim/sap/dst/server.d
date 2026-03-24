/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.dst.server;

import uim.sap.dst;

mixin(ShowModule!());

@safe:

// ---------------------------------------------------------------------------
// DSTServer – Vibe.D HTTP server for the Destination service
// ---------------------------------------------------------------------------
class DSTServer {
  private DSTService _service;

  this(DSTService service) {
    _service = service;
  }

  // -----------------------------------------------------------------------
  // Root dispatcher
  // -----------------------------------------------------------------------
  override void handleRequest(HTTPServerRequest req, HTTPServerResponse res) {
    super.handleRequest(req, res);

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
    } catch (DSTNotFoundException e) {
      respondError(res, e.msg, 404);
    } catch (DSTValidationException e) {
      respondError(res, e.msg, 400);
    } catch (DSTAuthorizationException e) {
      respondError(res, e.msg, 403);
    } catch (DSTDestinationException e) {
      respondError(res, e.msg, 409);
    } catch (DSTException e) {
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

    // ── /destinations ─────────────────────────────────────────────────
    if (segs.length == 4 && segs[3] == "destinations") {
      if (req.method == HTTPMethod.GET) {
        auto protocol = req.params.get("protocol", "");
        auto proxyType = req.params.get("proxy_type", "");
        res.writeJsonBody(
          _service.listDestinations(tenantId, protocol, proxyType), 200);
        return;
      }
      if (req.method == HTTPMethod.POST) {
        res.writeJsonBody(_service.createDestination(tenantId, req.json), 201);
        return;
      }
    }

    // ── /destinations/:name ───────────────────────────────────────────
    if (segs.length == 5 && segs[3] == "destinations") {
      auto name = segs[4];
      if (req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.getDestination(tenantId, name), 200);
        return;
      }
      if (req.method == HTTPMethod.PUT) {
        res.writeJsonBody(_service.updateDestination(tenantId, name, req.json), 200);
        return;
      }
      if (req.method == HTTPMethod.DELETE) {
        res.writeJsonBody(_service.deleteDestination(tenantId, name), 200);
        return;
      }
    }

    // ── /destinations/:name/lookup ────────────────────────────────────
    if (segs.length == 6 && segs[3] == "destinations" && segs[5] == "lookup") {
      if (req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.lookupDestination(tenantId, segs[4]), 200);
        return;
      }
    }

    // ── /certificates ─────────────────────────────────────────────────
    if (segs.length == 4 && segs[3] == "certificates") {
      if (req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.listCertificates(tenantId), 200);
        return;
      }
      if (req.method == HTTPMethod.POST) {
        res.writeJsonBody(_service.createCertificate(tenantId, req.json), 201);
        return;
      }
    }

    // ── /certificates/:name ───────────────────────────────────────────
    if (segs.length == 5 && segs[3] == "certificates") {
      auto name = segs[4];
      if (req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.getCertificate(tenantId, name), 200);
        return;
      }
      if (req.method == HTTPMethod.DELETE) {
        res.writeJsonBody(_service.deleteCertificate(tenantId, name), 200);
        return;
      }
    }

    // ── /logs ─────────────────────────────────────────────────────────
    if (segs.length == 4 && segs[3] == "logs") {
      if (req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.listLogs(tenantId), 200);
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
      throw new DSTAuthorizationException("Missing Authorization header");
    if (authHeader.length < 8 || authHeader[0 .. 7] != "Bearer ")
      throw new DSTAuthorizationException("Authorization must use Bearer scheme");
    if (authHeader[7 .. $] != _service.config.authToken)
      throw new DSTAuthorizationException("Invalid auth token");
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
