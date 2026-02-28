/**
 * HTTP server for AAS service
 */
module uim.sap.aas.server;

import uim.sap.aas;

@safe:

class AASServer {
  private AASService _service;

  this(AASService service) {
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
      if (subPath == "/apps") {
        validateAuth(req);
        if (req.method == HTTPMethod.GET) {
          res.writeJsonBody(_service.listApps(), 200);
          return;
        }
        if (req.method == HTTPMethod.POST) {
          res.writeJsonBody(_service.registerApp(req.json), 201);
          return;
        }
      }

      if (subPath.startsWith("/apps/") && req.method == HTTPMethod.GET && !subPath.endsWith(
          "/policies")) {
        validateAuth(req);
        auto appId = secondSegment(subPath);
        res.writeJsonBody(_service.getApp(appId), 200);
        return;
      }

      if (subPath.startsWith("/apps/") && subPath.endsWith("/policies")) {
        validateAuth(req);
        auto appId = secondSegment(subPath);
        if (req.method == HTTPMethod.GET) {
          res.writeJsonBody(_service.listPolicies(appId), 200);
          return;
        }
        if (req.method == HTTPMethod.POST) {
          res.writeJsonBody(_service.createPolicy(appId, req.json), 201);
          return;
        }
      }

      if (subPath.startsWith("/apps/")
        && subPath.endsWith("/metrics/evaluate")
        && req.method == HTTPMethod.POST) {
        validateAuth(req);
        auto appId = secondSegment(subPath);
        res.writeJsonBody(_service.evaluate(appId, req.json, false), 200);
        return;
      }

      if (subPath.startsWith("/apps/")
        && subPath.endsWith("/metrics/evaluate/apply")
        && req.method == HTTPMethod.POST) {
        validateAuth(req);
        auto appId = secondSegment(subPath);
        res.writeJsonBody(_service.evaluate(appId, req.json, true), 200);
        return;
      }

      if (subPath.startsWith("/cf/apps/") && subPath.endsWith("/scale") && req.method == HTTPMethod
        .POST) {
        validateAuth(req);
        auto appId = thirdSegment(subPath);
        res.writeJsonBody(_service.triggerCFScale(appId, req.json), 202);
        return;
      }

      respondError(res, "Not found", 404);
    } catch (AASAuthorizationException e) {
      respondError(res, e.msg, 401);
    } catch (AASNotFoundException e) {
      respondError(res, e.msg, 404);
    } catch (AASValidationException e) {
      respondError(res, e.msg, 422);
    } catch (AASException e) {
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
      throw new AASAuthorizationException("Missing Authorization header");
    }

    auto expected = "Bearer " ~ _service.config.authToken;
    if (req.headers["Authorization"] != expected) {
      throw new AASAuthorizationException("Invalid token");
    }
  }

  private string secondSegment(string path) {
    auto parts = path.split("/");
    return parts.length >= 3 ? parts[2] : "";
  }

  private string thirdSegment(string path) {
    auto parts = path.split("/");
    return parts.length >= 4 ? parts[3] : "";
  }

  private void respondError(HTTPServerResponse res, string message, int statusCode) {
    Json payload = Json.emptyObject;
    payload["success"] = false;
    payload["message"] = message;
    payload["statusCode"] = statusCode;
    res.writeJsonBody(payload, statusCode);
  }
}
