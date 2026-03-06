module uim.sap.identityprovisioning.server;

import uim.sap.identityprovisioning;

mixin(ShowModule!());

@safe:

/**
 * IPVServer handles HTTP requests and routes them to the Identity Provisioning service.
 *
 * Platform:
 * - GET  /health                                                      Health check
 * - GET  /ready                                                       Readiness check
 *
 * Systems:
 * - POST   /v1/tenants/{tenantId}/systems                            Create system
 * - GET    /v1/tenants/{tenantId}/systems                            List systems (?type=source|target|proxy)
 * - GET    /v1/tenants/{tenantId}/systems/{systemName}               Get system
 * - PUT    /v1/tenants/{tenantId}/systems/{systemName}               Update system
 * - DELETE /v1/tenants/{tenantId}/systems/{systemName}               Delete system
 *
 * Users:
 * - POST   /v1/tenants/{tenantId}/users                              Create user
 * - GET    /v1/tenants/{tenantId}/users                              List users
 * - GET    /v1/tenants/{tenantId}/users/{userId}                     Get user
 * - PUT    /v1/tenants/{tenantId}/users/{userId}                     Update user
 * - DELETE /v1/tenants/{tenantId}/users/{userId}                     Delete user
 *
 * Groups:
 * - POST   /v1/tenants/{tenantId}/groups                             Create group
 * - GET    /v1/tenants/{tenantId}/groups                             List groups
 * - GET    /v1/tenants/{tenantId}/groups/{groupId}                   Get group
 * - DELETE /v1/tenants/{tenantId}/groups/{groupId}                   Delete group
 *
 * Transformations:
 * - POST   /v1/tenants/{tenantId}/transformations                    Create transformation
 * - GET    /v1/tenants/{tenantId}/transformations                    List (?system_id=...)
 * - GET    /v1/tenants/{tenantId}/transformations/{transformationId} Get transformation
 * - DELETE /v1/tenants/{tenantId}/transformations/{transformationId} Delete transformation
 *
 * Jobs:
 * - POST   /v1/tenants/{tenantId}/jobs                               Run provisioning job
 * - GET    /v1/tenants/{tenantId}/jobs                               List jobs
 * - GET    /v1/tenants/{tenantId}/jobs/{jobId}                       Get job
 * - POST   /v1/tenants/{tenantId}/jobs/{jobId}/cancel                Cancel job
 * - GET    /v1/tenants/{tenantId}/jobs/{jobId}/logs                  List job logs (?level=...)
 * - GET    /v1/tenants/{tenantId}/jobs/{jobId}/logs/export           Export job logs
 *
 * Notifications:
 * - POST   /v1/tenants/{tenantId}/notifications                     Subscribe
 * - GET    /v1/tenants/{tenantId}/notifications                     List subscriptions
 * - DELETE /v1/tenants/{tenantId}/notifications/{subscriptionId}    Delete subscription
 *
 * Dashboard:
 * - GET    /v1/tenants/{tenantId}/dashboard                          Dashboard metrics
 */
class IPVServer : SAPServer {
  mixin(SAPServerTemplate!IPVServer);
  private IPVService _service;

  this(IPVService service) {
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

    // --- Platform endpoints ---
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

      // All business routes are under /v1/tenants/{tenantId}/...
      if (segments.length >= 3 && segments[0] == "v1" && segments[1] == "tenants") {
        auto tenantId = segments[2];

        // --- System routes ---
        // POST /v1/tenants/{tenantId}/systems
        // GET  /v1/tenants/{tenantId}/systems?type=source|target|proxy
        if (segments.length == 4 && segments[3] == "systems") {
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.createSystem(tenantId, req.json), 201);
            return;
          }
          if (req.method == HTTPMethod.GET) {
            string systemType = "";
            if ("type" in req.query) {
              systemType = req.query["type"];
            }
            res.writeJsonBody(_service.listSystems(tenantId, systemType), 200);
            return;
          }
        }

        // GET    /v1/tenants/{tenantId}/systems/{systemName}
        // PUT    /v1/tenants/{tenantId}/systems/{systemName}
        // DELETE /v1/tenants/{tenantId}/systems/{systemName}
        if (segments.length == 5 && segments[3] == "systems") {
          auto systemName = segments[4];
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.getSystem(tenantId, systemName), 200);
            return;
          }
          if (req.method == HTTPMethod.PUT) {
            res.writeJsonBody(_service.updateSystem(tenantId, systemName, req.json), 200);
            return;
          }
          if (req.method == HTTPMethod.DELETE) {
            res.writeJsonBody(_service.deleteSystem(tenantId, systemName), 200);
            return;
          }
        }

        // --- User routes ---
        // POST /v1/tenants/{tenantId}/users
        // GET  /v1/tenants/{tenantId}/users
        if (segments.length == 4 && segments[3] == "users") {
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.createUser(tenantId, req.json), 201);
            return;
          }
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listUsers(tenantId), 200);
            return;
          }
        }

        // GET    /v1/tenants/{tenantId}/users/{userId}
        // PUT    /v1/tenants/{tenantId}/users/{userId}
        // DELETE /v1/tenants/{tenantId}/users/{userId}
        if (segments.length == 5 && segments[3] == "users") {
          auto userId = segments[4];
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.getUser(tenantId, userId), 200);
            return;
          }
          if (req.method == HTTPMethod.PUT) {
            res.writeJsonBody(_service.updateUser(tenantId, userId, req.json), 200);
            return;
          }
          if (req.method == HTTPMethod.DELETE) {
            res.writeJsonBody(_service.deleteUser(tenantId, userId), 200);
            return;
          }
        }

        // --- Group routes ---
        // POST /v1/tenants/{tenantId}/groups
        // GET  /v1/tenants/{tenantId}/groups
        if (segments.length == 4 && segments[3] == "groups") {
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.createGroup(tenantId, req.json), 201);
            return;
          }
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listGroups(tenantId), 200);
            return;
          }
        }

        // GET    /v1/tenants/{tenantId}/groups/{groupId}
        // DELETE /v1/tenants/{tenantId}/groups/{groupId}
        if (segments.length == 5 && segments[3] == "groups") {
          auto groupId = segments[4];
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.getGroup(tenantId, groupId), 200);
            return;
          }
          if (req.method == HTTPMethod.DELETE) {
            res.writeJsonBody(_service.deleteGroup(tenantId, groupId), 200);
            return;
          }
        }

        // --- Transformation routes ---
        // POST /v1/tenants/{tenantId}/transformations
        // GET  /v1/tenants/{tenantId}/transformations?system_id=...
        if (segments.length == 4 && segments[3] == "transformations") {
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.createTransformation(tenantId, req.json), 201);
            return;
          }
          if (req.method == HTTPMethod.GET) {
            string systemId = "";
            if ("system_id" in req.query) {
              systemId = req.query["system_id"];
            }
            res.writeJsonBody(_service.listTransformations(tenantId, systemId), 200);
            return;
          }
        }

        // GET    /v1/tenants/{tenantId}/transformations/{transformationId}
        // DELETE /v1/tenants/{tenantId}/transformations/{transformationId}
        if (segments.length == 5 && segments[3] == "transformations") {
          auto transformationId = segments[4];
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.getTransformation(tenantId, transformationId), 200);
            return;
          }
          if (req.method == HTTPMethod.DELETE) {
            res.writeJsonBody(_service.deleteTransformation(tenantId, transformationId), 200);
            return;
          }
        }

        // --- Job routes ---
        // POST /v1/tenants/{tenantId}/jobs
        // GET  /v1/tenants/{tenantId}/jobs
        if (segments.length == 4 && segments[3] == "jobs") {
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.runJob(tenantId, req.json), 201);
            return;
          }
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listJobs(tenantId), 200);
            return;
          }
        }

        // GET /v1/tenants/{tenantId}/jobs/{jobId}
        if (segments.length == 5 && segments[3] == "jobs") {
          auto jobId = segments[4];
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.getJob(tenantId, jobId), 200);
            return;
          }
        }

        // POST /v1/tenants/{tenantId}/jobs/{jobId}/cancel
        if (segments.length == 6 && segments[3] == "jobs" && segments[5] == "cancel"
          && req.method == HTTPMethod.POST) {
          auto jobId = segments[4];
          res.writeJsonBody(_service.cancelJob(tenantId, jobId), 200);
          return;
        }

        // GET /v1/tenants/{tenantId}/jobs/{jobId}/logs?level=...
        if (segments.length == 6 && segments[3] == "jobs" && segments[5] == "logs"
          && req.method == HTTPMethod.GET) {
          auto jobId = segments[4];
          string level = "";
          if ("level" in req.query) {
            level = req.query["level"];
          }
          res.writeJsonBody(_service.listJobLogs(tenantId, jobId, level), 200);
          return;
        }

        // GET /v1/tenants/{tenantId}/jobs/{jobId}/logs/export
        if (segments.length == 7 && segments[3] == "jobs" && segments[5] == "logs"
          && segments[6] == "export" && req.method == HTTPMethod.GET) {
          auto jobId = segments[4];
          res.writeJsonBody(_service.exportJobLogs(tenantId, jobId), 200);
          return;
        }

        // --- Notification routes ---
        // POST /v1/tenants/{tenantId}/notifications
        // GET  /v1/tenants/{tenantId}/notifications
        if (segments.length == 4 && segments[3] == "notifications") {
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.createNotification(tenantId, req.json), 201);
            return;
          }
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listNotifications(tenantId), 200);
            return;
          }
        }

        // DELETE /v1/tenants/{tenantId}/notifications/{subscriptionId}
        if (segments.length == 5 && segments[3] == "notifications"
          && req.method == HTTPMethod.DELETE) {
          auto subscriptionId = segments[4];
          res.writeJsonBody(_service.deleteNotification(tenantId, subscriptionId), 200);
          return;
        }

        // --- Dashboard ---
        // GET /v1/tenants/{tenantId}/dashboard
        if (segments.length == 4 && segments[3] == "dashboard"
          && req.method == HTTPMethod.GET) {
          res.writeJsonBody(_service.dashboard(tenantId), 200);
          return;
        }
      }

      respondError(res, "Not found", 404);
    } catch (IPVAuthorizationException e) {
      respondError(res, e.msg, 401);
    } catch (IPVNotFoundException e) {
      respondError(res, e.msg, 404);
    } catch (IPVValidationException e) {
      respondError(res, e.msg, 422);
    } catch (IPVException e) {
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
      throw new IPVAuthorizationException("Missing Authorization header");
    }

    auto expected = "Bearer " ~ _service.config.authToken;
    if (req.headers["Authorization"] != expected) {
      throw new IPVAuthorizationException("Invalid token");
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
