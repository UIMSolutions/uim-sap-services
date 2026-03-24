module uim.sap.mob.server;

import uim.sap.mob;

mixin(ShowModule!());

@safe:

/**
 * HTTP server for SAP Mobile Services.
 *
 * Routes:
 *   GET  /health
 *   GET  /ready
 *   GET  /v1/metrics
 *   GET  /v1/sdks
 *   GET  /v1/sdks/{type}
 *
 *   Apps:
 *     GET|POST|PUT|DELETE /v1/apps[/{appId}]
 *
 *   Versions:
 *     GET|POST|DELETE /v1/apps/{appId}/versions[/{ver}]
 *     POST /v1/apps/{appId}/versions/{ver}/activate
 *
 *   Push:
 *     GET|PUT /v1/apps/{appId}/push/config
 *     POST    /v1/apps/{appId}/push/send
 *     GET     /v1/apps/{appId}/push/history
 *
 *   Offline:
 *     GET|PUT /v1/apps/{appId}/offline
 *
 *   Security:
 *     GET|PUT /v1/apps/{appId}/security
 *
 *   Users:
 *     GET     /v1/apps/{appId}/users
 *     POST    /v1/apps/{appId}/users/{userId}
 *     GET     /v1/apps/{appId}/users/{userId}
 *     DELETE  /v1/apps/{appId}/users/{userId}
 *     POST    /v1/apps/{appId}/users/{userId}/lock
 *     POST    /v1/apps/{appId}/users/{userId}/unlock
 *     POST    /v1/apps/{appId}/users/{userId}/wipe
 *
 *   Analytics:
 *     GET  /v1/apps/{appId}/analytics
 */
class MOBServer : SAPServer {
  mixin(SAPServerTemplate!MOBServer);

  private MOBService _service;

  this(MOBService service) {
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
      validateAuth(req, _service.config);
      auto segments = normalizedSegments(subPath);

      // GET /v1/metrics
      if (segments.length == 2 && segments[0] == "v1" && segments[1] == "metrics" && req.method == HTTPMethod
        .GET) {
        res.writeJsonBody(_service.getMetrics(), 200);
        return;
      }

      // /v1/sdks...
      if (segments.length >= 2 && segments[0] == "v1" && segments[1] == "sdks") {
        routeSdks(req, res, segments[2 .. $]);
        return;
      }

      // /v1/apps...
      if (segments.length >= 2 && segments[0] == "v1" && segments[1] == "apps") {
        routeApps(req, res, segments[2 .. $]);
        return;
      }

      respondError(res, "Not found", 404);
    } catch (MOBAuthorizationException e) {
      respondError(res, e.msg, 401);
    } catch (MOBConflictException e) {
      respondError(res, e.msg, 409);
    } catch (MOBNotFoundException e) {
      respondError(res, e.msg, 404);
    } catch (MOBQuotaExceededException e) {
      respondError(res, e.msg, 429);
    } catch (MOBValidationException e) {
      respondError(res, e.msg, 422);
    } catch (MOBException e) {
      respondError(res, e.msg, 500);
    } catch (Exception e) {
      respondError(res, e.msg, 500);
    }
  }

  // ── SDKs ──

  private void routeSdks(HTTPServerRequest req, HTTPServerResponse res, string[] segments) {
    if (segments.length == 0 && req.method == HTTPMethod.GET) {
      res.writeJsonBody(_service.listSdks(), 200);
      return;
    }
    if (segments.length == 1 && req.method == HTTPMethod.GET) {
      res.writeJsonBody(_service.getSdk(segments[0]), 200);
      return;
    }
    respondError(res, "Not found", 404);
  }

  // ── Apps ──

  private void routeApps(HTTPServerRequest req, HTTPServerResponse res, string[] segments) {
    // GET /v1/apps
    if (segments.length == 0 && req.method == HTTPMethod.GET) {
      res.writeJsonBody(_service.listApps(), 200);
      return;
    }
    if (segments.length == 0) {
      respondError(res, "Not found", 404);
      return;
    }

    auto appId = segments[0];

    // POST /v1/apps/{appId}
    if (segments.length == 1 && req.method == HTTPMethod.POST) {
      res.writeJsonBody(_service.createApp(appId, req.json), 201);
      return;
    }
    // PUT /v1/apps/{appId}
    if (segments.length == 1 && req.method == HTTPMethod.PUT) {
      res.writeJsonBody(_service.updateApp(appId, req.json), 200);
      return;
    }
    // GET /v1/apps/{appId}
    if (segments.length == 1 && req.method == HTTPMethod.GET) {
      res.writeJsonBody(_service.getApp(appId), 200);
      return;
    }
    // DELETE /v1/apps/{appId}
    if (segments.length == 1 && req.method == HTTPMethod.DELETE) {
      res.writeJsonBody(_service.deleteApp(appId), 200);
      return;
    }

    // Sub-resources
    if (segments.length >= 2) {
      auto resource = segments[1];

      if (resource == "versions") {
        routeVersions(req, res, appId, segments[2 .. $]);
        return;
      }
      if (resource == "push") {
        routePush(req, res, appId, segments[2 .. $]);
        return;
      }
      if (resource == "offline") {
        routeOffline(req, res, appId, segments[2 .. $]);
        return;
      }
      if (resource == "security") {
        routeSecurity(req, res, appId, segments[2 .. $]);
        return;
      }
      if (resource == "users") {
        routeUsers(req, res, appId, segments[2 .. $]);
        return;
      }
      if (resource == "analytics") {
        routeAnalytics(req, res, appId, segments[2 .. $]);
        return;
      }
    }

    respondError(res, "Not found", 404);
  }

  // ── Versions ──

  private void routeVersions(HTTPServerRequest req, HTTPServerResponse res, string appId, string[] segments) {
    // GET /v1/apps/{appId}/versions
    if (segments.length == 0 && req.method == HTTPMethod.GET) {
      res.writeJsonBody(_service.listVersions(appId), 200);
      return;
    }
    if (segments.length == 0) {
      respondError(res, "Not found", 404);
      return;
    }

    auto verId = segments[0];

    // POST /v1/apps/{appId}/versions/{ver}/activate
    if (segments.length == 2 && segments[1] == "activate" && req.method == HTTPMethod.POST) {
      res.writeJsonBody(_service.activateVersion(appId, verId), 200);
      return;
    }

    // POST /v1/apps/{appId}/versions/{ver}
    if (segments.length == 1 && req.method == HTTPMethod.POST) {
      res.writeJsonBody(_service.createVersion(appId, verId, req.json), 201);
      return;
    }
    // GET /v1/apps/{appId}/versions/{ver}
    if (segments.length == 1 && req.method == HTTPMethod.GET) {
      res.writeJsonBody(_service.getVersion(appId, verId), 200);
      return;
    }
    // DELETE /v1/apps/{appId}/versions/{ver}
    if (segments.length == 1 && req.method == HTTPMethod.DELETE) {
      res.writeJsonBody(_service.deleteVersion(appId, verId), 200);
      return;
    }

    respondError(res, "Not found", 404);
  }

  // ── Push ──

  private void routePush(HTTPServerRequest req, HTTPServerResponse res, string appId, string[] segments) {
    if (segments.length == 0) {
      respondError(res, "Not found", 404);
      return;
    }

    // GET /v1/apps/{appId}/push/config
    if (segments.length == 1 && segments[0] == "config" && req.method == HTTPMethod.GET) {
      res.writeJsonBody(_service.getPushConfig(appId), 200);
      return;
    }
    // PUT /v1/apps/{appId}/push/config
    if (segments.length == 1 && segments[0] == "config" && req.method == HTTPMethod.PUT) {
      res.writeJsonBody(_service.setPushConfig(appId, req.json), 200);
      return;
    }
    // POST /v1/apps/{appId}/push/send
    if (segments.length == 1 && segments[0] == "send" && req.method == HTTPMethod.POST) {
      res.writeJsonBody(_service.sendNotification(appId, req.json), 200);
      return;
    }
    // GET /v1/apps/{appId}/push/history
    if (segments.length == 1 && segments[0] == "history" && req.method == HTTPMethod.GET) {
      res.writeJsonBody(_service.listNotifications(appId), 200);
      return;
    }

    respondError(res, "Not found", 404);
  }

  // ── Offline ──

  private void routeOffline(HTTPServerRequest req, HTTPServerResponse res, string appId, string[] segments) {
    // GET /v1/apps/{appId}/offline
    if (segments.length == 0 && req.method == HTTPMethod.GET) {
      res.writeJsonBody(_service.getOfflineConfig(appId), 200);
      return;
    }
    // PUT /v1/apps/{appId}/offline
    if (segments.length == 0 && req.method == HTTPMethod.PUT) {
      res.writeJsonBody(_service.setOfflineConfig(appId, req.json), 200);
      return;
    }
    respondError(res, "Not found", 404);
  }

  // ── Security ──

  private void routeSecurity(HTTPServerRequest req, HTTPServerResponse res, string appId, string[] segments) {
    // GET /v1/apps/{appId}/security
    if (segments.length == 0 && req.method == HTTPMethod.GET) {
      res.writeJsonBody(_service.getSecurityPolicy(appId), 200);
      return;
    }
    // PUT /v1/apps/{appId}/security
    if (segments.length == 0 && req.method == HTTPMethod.PUT) {
      res.writeJsonBody(_service.setSecurityPolicy(appId, req.json), 200);
      return;
    }
    respondError(res, "Not found", 404);
  }

  // ── Users ──

  private void routeUsers(HTTPServerRequest req, HTTPServerResponse res, string appId, string[] segments) {
    // GET /v1/apps/{appId}/users
    if (segments.length == 0 && req.method == HTTPMethod.GET) {
      res.writeJsonBody(_service.listUsers(appId), 200);
      return;
    }
    if (segments.length == 0) {
      respondError(res, "Not found", 404);
      return;
    }

    auto userId = segments[0];

    // User actions: lock, unlock, wipe
    if (segments.length == 2 && req.method == HTTPMethod.POST) {
      auto action = segments[1];
      if (action == "lock") {
        res.writeJsonBody(_service.lockUser(appId, userId), 200);
        return;
      }
      if (action == "unlock") {
        res.writeJsonBody(_service.unlockUser(appId, userId), 200);
        return;
      }
      if (action == "wipe") {
        res.writeJsonBody(_service.wipeUser(appId, userId), 200);
        return;
      }
    }

    // POST /v1/apps/{appId}/users/{userId}  (register)
    if (segments.length == 1 && req.method == HTTPMethod.POST) {
      res.writeJsonBody(_service.registerUser(appId, userId, req.json), 201);
      return;
    }
    // GET /v1/apps/{appId}/users/{userId}
    if (segments.length == 1 && req.method == HTTPMethod.GET) {
      res.writeJsonBody(_service.getUser(appId, userId), 200);
      return;
    }
    // DELETE /v1/apps/{appId}/users/{userId}
    if (segments.length == 1 && req.method == HTTPMethod.DELETE) {
      res.writeJsonBody(_service.deleteUser(appId, userId), 200);
      return;
    }

    respondError(res, "Not found", 404);
  }

  // ── Analytics ──

  private void routeAnalytics(HTTPServerRequest req, HTTPServerResponse res, string appId, string[] segments) {
    if (segments.length == 0 && req.method == HTTPMethod.GET) {
      res.writeJsonBody(_service.getAppAnalytics(appId), 200);
      return;
    }
    respondError(res, "Not found", 404);
  }
}
