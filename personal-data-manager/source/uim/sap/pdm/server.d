/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.pdm.server;

import uim.sap.pdm;

mixin(ShowModule!());

@safe:

/**
 * HTTP server for SAP Personal Data Manager.
 *
 * Routes:
 *   GET  /health
 *   GET  /ready
 *
 *   Tenants:
 *     GET|POST  /v1/tenants
 *     GET       /v1/tenants/{tid}
 *
 *   Data Subjects:
 *     GET|POST  /v1/tenants/{tid}/subjects
 *     GET       /v1/tenants/{tid}/subjects/search?q=...&type=...
 *     GET|PUT|DELETE /v1/tenants/{tid}/subjects/{sid}
 *
 *   Personal Data Records:
 *     GET|POST  /v1/tenants/{tid}/subjects/{sid}/records
 *     DELETE    /v1/tenants/{tid}/subjects/{sid}/records/{rid}
 *     GET       /v1/tenants/{tid}/subjects/{sid}/report
 *
 *   Data Requests:
 *     GET|POST  /v1/tenants/{tid}/requests
 *     GET|POST  /v1/tenants/{tid}/subjects/{sid}/requests
 *     GET       /v1/tenants/{tid}/requests/{rid}
 *     POST      /v1/tenants/{tid}/requests/{rid}/submit
 *     POST      /v1/tenants/{tid}/requests/{rid}/process
 *     POST      /v1/tenants/{tid}/requests/{rid}/complete
 *     POST      /v1/tenants/{tid}/requests/{rid}/reject
 *     POST      /v1/tenants/{tid}/requests/{rid}/cancel
 *
 *   Notifications:
 *     GET       /v1/tenants/{tid}/subjects/{sid}/notifications
 *     POST      /v1/tenants/{tid}/subjects/{sid}/notify
 *     POST      /v1/tenants/{tid}/subjects/{sid}/send-report
 *
 *   Data Usages:
 *     GET|POST  /v1/tenants/{tid}/subjects/{sid}/usages
 */
class PDMServer : SAPServer {
  mixin(SAPServerTemplate!PDMServer);
  
  private PDMService _service;

  this(PDMService service) {
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

    // Health / ready (no auth)
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

      // /v1/tenants...
      if (segments.length >= 2 && segments[0] == "v1" && segments[1] == "tenants") {
        routeTenants(req, res, segments[2 .. $]);
        return;
      }

      respondError(res, "Not found", 404);
    } catch (PDMAuthorizationException e) {
      respondError(res, e.msg, 401);
    } catch (PDMConflictException e) {
      respondError(res, e.msg, 409);
    } catch (PDMNotFoundException e) {
      respondError(res, e.msg, 404);
    } catch (PDMValidationException e) {
      respondError(res, e.msg, 400);
    } catch (PDMQuotaExceededException e) {
      respondError(res, e.msg, 429);
    } catch (PDMConfigurationException e) {
      respondError(res, e.msg, 500);
    } catch (PDMException e) {
      respondError(res, e.msg, 500);
    } catch (Exception e) {
      respondError(res, "Internal server error", 500);
    }
  }

  // ──────────────────────────────────────
  //  Tenant Routes
  // ──────────────────────────────────────

  private void routeTenants(HTTPServerRequest req, HTTPServerResponse res, string[] rest) {
    // GET|POST /v1/tenants
    if (rest.length == 0) {
      if (req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.listTenants(), 200);
        return;
      }
      if (req.method == HTTPMethod.POST) {
        Json data_ = parseBody(req);
        res.writeJsonBody(_service.createTenant(data_), 201);
        return;
      }
      respondError(res, "Method not allowed", 405);
      return;
    }

    UUID tenantId = rest[0];

    // GET /v1/tenants/{tid}
    if (rest.length == 1 && req.method == HTTPMethod.GET) {
      res.writeJsonBody(_service.getTenant(tenantId), 200);
      return;
    }

    // /v1/tenants/{tid}/subjects...
    if (rest.length >= 2 && rest[1] == "subjects") {
      routeSubjects(req, res, tenantId, rest[2 .. $]);
      return;
    }

    // /v1/tenants/{tid}/requests...
    if (rest.length >= 2 && rest[1] == "requests") {
      routeRequests(req, res, tenantId, rest[2 .. $]);
      return;
    }

    respondError(res, "Not found", 404);
  }

  // ──────────────────────────────────────
  //  Data Subject Routes
  // ──────────────────────────────────────

  private void routeSubjects(HTTPServerRequest req, HTTPServerResponse res,
    UUID tenantId, string[] rest) {
    // GET|POST /v1/tenants/{tid}/subjects
    if (rest.length == 0) {
      if (req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.listSubjects(tenantId), 200);
        return;
      }
      if (req.method == HTTPMethod.POST) {
        Json data_ = parseBody(req);
        res.writeJsonBody(_service.registerSubject(tenantId, data_), 201);
        return;
      }
      respondError(res, "Method not allowed", 405);
      return;
    }

    // GET /v1/tenants/{tid}/subjects/search?q=term&type=private
    if (rest[0] == "search" && rest.length == 1 && req.method == HTTPMethod.GET) {
      auto q = req.params.get("q", "");
      auto type_ = req.params.get("type", "");
      if (type_.length > 0)
        res.writeJsonBody(_service.searchSubjectsByType(tenantId, type_), 200);
      else if (q.length > 0)
        res.writeJsonBody(_service.searchSubjects(tenantId, q), 200);
      else
        res.writeJsonBody(_service.listSubjects(tenantId), 200);
      return;
    }

    UUID subjectId = rest[0];

    // GET|PUT|DELETE /v1/tenants/{tid}/subjects/{sid}
    if (rest.length == 1) {
      if (req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.getSubject(tenantId, subjectId), 200);
        return;
      }
      if (req.method == HTTPMethod.PUT) {
        Json data_ = parseBody(req);
        res.writeJsonBody(_service.updateSubject(tenantId, subjectId, data_), 200);
        return;
      }
      if (req.method == HTTPMethod.DELETE) {
        res.writeJsonBody(_service.deleteSubject(tenantId, subjectId), 200);
        return;
      }
      respondError(res, "Method not allowed", 405);
      return;
    }

    // /v1/tenants/{tid}/subjects/{sid}/records...
    if (rest.length >= 2 && rest[1] == "records") {
      routeRecords(req, res, tenantId, subjectId, rest[2 .. $]);
      return;
    }

    // GET /v1/tenants/{tid}/subjects/{sid}/report
    if (rest.length == 2 && rest[1] == "report" && req.method == HTTPMethod.GET) {
      res.writeJsonBody(_service.generateDataReport(tenantId, subjectId), 200);
      return;
    }

    // /v1/tenants/{tid}/subjects/{sid}/requests...
    if (rest.length >= 2 && rest[1] == "requests") {
      routeSubjectRequests(req, res, tenantId, subjectId, rest[2 .. $]);
      return;
    }

    // GET /v1/tenants/{tid}/subjects/{sid}/notifications
    if (rest.length == 2 && rest[1] == "notifications" && req.method == HTTPMethod.GET) {
      res.writeJsonBody(_service.listNotifications(tenantId, subjectId), 200);
      return;
    }

    // POST /v1/tenants/{tid}/subjects/{sid}/notify
    if (rest.length == 2 && rest[1] == "notify" && req.method == HTTPMethod.POST) {
      Json data = parseBody(req);
      res.writeJsonBody(_service.sendNotification(tenantId, subjectId, data), 200);
      return;
    }

    // POST /v1/tenants/{tid}/subjects/{sid}/send-report
    if (rest.length == 2 && rest[1] == "send-report" && req.method == HTTPMethod.POST) {
      res.writeJsonBody(_service.sendDataReport(tenantId, subjectId), 200);
      return;
    }

    // /v1/tenants/{tid}/subjects/{sid}/usages...
    if (rest.length >= 2 && rest[1] == "usages") {
      routeUsages(req, res, tenantId, subjectId, rest[2 .. $]);
      return;
    }

    respondError(res, "Not found", 404);
  }

  // ──────────────────────────────────────
  //  Personal Data Record Routes
  // ──────────────────────────────────────

  private void routeRecords(HTTPServerRequest req, HTTPServerResponse res,
    UUID tenantId, UUID subjectId, string[] rest) {
    // GET|POST /v1/tenants/{tid}/subjects/{sid}/records
    if (rest.length == 0) {
      if (req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.getSubjectRecords(tenantId, subjectId), 200);
        return;
      }
      if (req.method == HTTPMethod.POST) {
        Json data = parseBody(req);
        res.writeJsonBody(_service.addRecord(tenantId, subjectId, data), 201);
        return;
      }
      respondError(res, "Method not allowed", 405);
      return;
    }

    // DELETE /v1/tenants/{tid}/subjects/{sid}/records/{rid}
    if (rest.length == 1 && req.method == HTTPMethod.DELETE) {
      res.writeJsonBody(_service.deleteRecord(tenantId, UUID(rest[0])), 200);
      return;
    }

    respondError(res, "Not found", 404);
  }

  // ──────────────────────────────────────
  //  Subject Request Routes
  // ──────────────────────────────────────

  private void routeSubjectRequests(HTTPServerRequest req, HTTPServerResponse res,
    UUID tenantId, UUID subjectId, string[] rest) {
    // GET|POST /v1/tenants/{tid}/subjects/{sid}/requests
    if (rest.length == 0) {
      if (req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.listRequestsBySubject(tenantId, subjectId), 200);
        return;
      }
      if (req.method == HTTPMethod.POST) {
        Json data = parseBody(req);
        res.writeJsonBody(_service.createRequest(tenantId, subjectId, data), 201);
        return;
      }
      respondError(res, "Method not allowed", 405);
      return;
    }

    respondError(res, "Not found", 404);
  }

  // ──────────────────────────────────────
  //  Top-level Request Routes
  // ──────────────────────────────────────

  private void routeRequests(HTTPServerRequest req, HTTPServerResponse res,
    UUID tenantId, string[] rest) {
    // GET /v1/tenants/{tid}/requests
    if (rest.length == 0 && req.method == HTTPMethod.GET) {
      auto statusFilter = req.params.get("status", "");
      if (statusFilter.length > 0)
        res.writeJsonBody(_service.listRequestsByStatus(tenantId, statusFilter), 200);
      else
        res.writeJsonBody(_service.listRequests(tenantId), 200);
      return;
    }

    if (rest.length < 1) {
      respondError(res, "Not found", 404);
      return;
    }

    UUID requestId = UUID(rest[0]);

    // GET /v1/tenants/{tid}/requests/{rid}
    if (rest.length == 1 && req.method == HTTPMethod.GET) {
      res.writeJsonBody(_service.getRequest(tenantId, requestId), 200);
      return;
    }

    // POST /v1/tenants/{tid}/requests/{rid}/submit|process|complete|reject|cancel
    if (rest.length == 2 && req.method == HTTPMethod.POST) {
      switch (rest[1]) {
      case "submit":
        res.writeJsonBody(_service.submitRequest(tenantId, requestId), 200);
        return;
      case "process":
        res.writeJsonBody(_service.processRequest(tenantId, requestId), 200);
        return;
      case "complete":
        Json data = parseBody(req);
        res.writeJsonBody(_service.completeRequest(tenantId, requestId, data), 200);
        return;
      case "reject":
        Json data2 = parseBody(req);
        res.writeJsonBody(_service.rejectRequest(tenantId, requestId, data2), 200);
        return;
      case "cancel":
        res.writeJsonBody(_service.cancelRequest(tenantId, requestId), 200);
        return;
      default:
        break;
      }
    }

    respondError(res, "Not found", 404);
  }

  // ──────────────────────────────────────
  //  Data Usage Routes
  // ──────────────────────────────────────

  private void routeUsages(HTTPServerRequest req, HTTPServerResponse res,
    UUID tenantId, UUID subjectId, string[] rest) {
    // GET|POST /v1/tenants/{tid}/subjects/{sid}/usages
    if (rest.length == 0) {
      if (req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.listUsages(tenantId, subjectId), 200);
        return;
      }
      if (req.method == HTTPMethod.POST) {
        Json data = parseBody(req);
        res.writeJsonBody(_service.addUsage(tenantId, subjectId, data), 201);
        return;
      }
      respondError(res, "Method not allowed", 405);
      return;
    }

    respondError(res, "Not found", 404);
  }

  // ──────────────────────────────────────
  //  Helpers
  // ──────────────────────────────────────

  private void validateAuth(HTTPServerRequest req) {
    if (!_service.config.requireAuthToken)
      return;
    auto authHeader = req.headers.get("Authorization", "");
    if (!authHeader.startsWith("Bearer "))
      throw new PDMAuthorizationException("Missing bearer token");
    auto token = authHeader[7 .. $];
    if (token != _service.config.authToken)
      throw new PDMAuthorizationException("Invalid bearer token");
  }

  private static string[] normalizedSegments(string path) {
    import std.algorithm : filter;
    import std.array : array;

    return path.split("/").filter!(s => s.length > 0).array;
  }
}
