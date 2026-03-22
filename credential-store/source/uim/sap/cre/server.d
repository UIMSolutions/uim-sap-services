module uim.sap.cre.server;

import uim.sap.cre;

mixin(ShowModule!());

@safe:

class CREServer {
  private CREService _service;

  this(CREService service) {
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

    auto requestKey = req.headers.get("X-CRE-Encryption-Key", "");

    try {
      validateAuth(req);

      if (subPath == "/v1/service_instances") {
        if (req.method == HTTPMethod.GET) {
          res.writeJsonBody(_service.listServiceInstances(), 200);
          return;
        }
      }

      auto segments = normalizedSegments(subPath);
      if (segments.length >= 3 && segments[0] == "v1" && segments[1] == "service_instances") {
        auto instanceId = UUID(segments[2]);

        if (segments.length == 3) {
          if (req.method == HTTPMethod.PUT) {
            res.writeJsonBody(_service.upsertServiceInstance(instanceId, req.json), 200);
            return;
          }
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.getServiceInstance(instanceId), 200);
            return;
          }
          if (req.method == HTTPMethod.DELETE) {
            res.writeJsonBody(_service.deleteServiceInstance(instanceId), 200);
            return;
          }
        }

        if (segments.length == 5 && segments[3] == "credentials") {
          auto credentialName = segments[4];
          if (req.method == HTTPMethod.PUT) {
            res.writeJsonBody(_service.upsertCredential(instanceId, credentialName, req.json, requestKey), 200);
            return;
          }
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.getCredential(instanceId, credentialName, requestKey), 200);
            return;
          }
          if (req.method == HTTPMethod.DELETE) {
            res.writeJsonBody(_service.deleteCredential(instanceId, credentialName), 200);
            return;
          }
        }

        if (segments.length == 4 && segments[3] == "credentials" && req.method == HTTPMethod.GET) {
          res.writeJsonBody(_service.listCredentials(instanceId), 200);
          return;
        }

        if (segments.length == 5 && segments[3] == "service_keys") {
          auto serviceKeyId = UUID(segments[4]);
          if (req.method == HTTPMethod.PUT) {
            res.writeJsonBody(_service.upsertServiceKey(instanceId, serviceKeyId, req.json, requestKey), 200);
            return;
          }
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.getServiceKey(instanceId, serviceKeyId, requestKey), 200);
            return;
          }
          if (req.method == HTTPMethod.DELETE) {
            res.writeJsonBody(_service.deleteServiceKey(instanceId, serviceKeyId), 200);
            return;
          }
        }
      }

      respondError(res, "Not found", 404);
    } catch (CREAuthorizationException e) {
      respondError(res, e.msg, 401);
    } catch (CRENotFoundException e) {
      respondError(res, e.msg, 404);
    } catch (CREValidationException e) {
      respondError(res, e.msg, 422);
    } catch (CREException e) {
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
      throw new CREAuthorizationException("Missing Authorization header");
    }

    auto expected = "Bearer " ~ _service.config.authToken;
    if (req.headers["Authorization"] != expected) {
      throw new CREAuthorizationException("Invalid token");
    }
  }
}
///
unittest {
  mixin(ShowTest!("Testing CREServer"));

  // TODO: Add tests for CREServer
}