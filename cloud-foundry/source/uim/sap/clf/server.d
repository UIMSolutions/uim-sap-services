/**
 * HTTP server for CLF service
 */
module uim.sap.clf.server;

import uim.sap.clf;

mixin(ShowModule!());

@safe:

class CLFServer {
  private CLFService _service;

  this(CLFService service) {
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
      res.statusCode = 200;
      res.writeJsonBody(_service.health());
      return;
    }

    if (subPath == "/ready" && req.method == HTTPMethod.GET) {
      res.statusCode = 200;
      res.writeJsonBody(_service.ready());
      return;
    }

    try {
      if (subPath == "/v2/organizations") {
        if (req.method == HTTPMethod.GET) {
          validateAuth(req);
          res.writeJsonBody(_service.listOrganizations());
          return;
        }
        if (req.method == HTTPMethod.POST) {
          validateAuth(req);
          res.writeJsonBody(_service.createOrganization(req.json), 201);
          return;
        }
      }

      if (subPath == "/v2/spaces") {
        if (req.method == HTTPMethod.GET) {
          validateAuth(req);
          res.writeJsonBody(_service.listSpaces());
          return;
        }
        if (req.method == HTTPMethod.POST) {
          validateAuth(req);
          res.writeJsonBody(_service.createSpace(req.json), 201);
          return;
        }
      }

      if (subPath == "/v2/apps") {
        if (req.method == HTTPMethod.GET) {
          validateAuth(req);
          res.writeJsonBody(_service.listApps());
          return;
        }
        if (req.method == HTTPMethod.POST) {
          validateAuth(req);
          res.writeJsonBody(_service.createApp(req.json), 201);
          return;
        }
      }

      if (subPath.startsWith("/v2/apps/") && req.method == HTTPMethod.GET) {
        validateAuth(req);
        auto guid = lastSegment(subPath);
        res.writeJsonBody(_service.getApp(guid));
        return;
      }

      if (subPath == "/v2/services" && req.method == HTTPMethod.GET) {
        validateAuth(req);
        res.writeJsonBody(_service.listServiceOfferings());
        return;
      }

      if (subPath == "/v2/service_instances") {
        if (req.method == HTTPMethod.GET) {
          validateAuth(req);
          res.writeJsonBody(_service.listServiceInstances());
          return;
        }
        if (req.method == HTTPMethod.POST) {
          validateAuth(req);
          res.writeJsonBody(_service.createServiceInstance(req.json), 201);
          return;
        }
      }

      respondError(res, "Not found", 404);
    } catch (CLFAuthorizationException e) {
      respondError(res, e.msg, 401);
    } catch (CLFNotFoundException e) {
      respondError(res, e.msg, 404);
    } catch (CLFValidationException e) {
      respondError(res, e.msg, 422);
    } catch (CLFException e) {
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
      throw new CLFAuthorizationException("Missing Authorization header");
    }

    auto expected = "Bearer " ~ _service.config.authToken;
    if (req.headers["Authorization"] != expected) {
      throw new CLFAuthorizationException("Invalid token");
    }
  }

  private string lastSegment(string path) {
    auto parts = path.split("/");
    if (parts.length == 0) {
      return "";
    }
    return parts[$ - 1];
  }

  private void respondError(HTTPServerResponse res, string message, int statusCode) {
    Json payload = Json.emptyObject;
    payload["success"] = false;
    payload["message"] = message;
    payload["statusCode"] = statusCode;
    res.writeJsonBody(payload, statusCode);
  }
}
