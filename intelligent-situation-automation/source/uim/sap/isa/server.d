/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.isa.server;

import uim.sap.isa;

mixin(ShowModule!());

@safe:

class ISAServer : SAPServer {
  private ISAService _service;

  this(ISAService service) {
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
      if (segments.length >= 3 && segments[0] == "v1" && segments[1] == "tenants") {
        auto tenantId = segments[2];

        if (segments.length == 4 && segments[3] == "configurations") {
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listConfigurations(tenantId), 200);
            return;
          }
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.createConfiguration(tenantId, req.json), 201);
            return;
          }
        }

        if (segments.length == 5 && segments[3] == "configurations") {
          auto configId = segments[4];
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.getConfiguration(tenantId, configId), 200);
            return;
          }
          if (req.method == HTTPMethod.PUT) {
            res.writeJsonBody(_service.updateConfiguration(tenantId, configId, req.json), 200);
            return;
          }
          if (req.method == HTTPMethod.DELETE) {
            res.writeJsonBody(_service.deleteConfiguration(tenantId, configId), 200);
            return;
          }
        }

        if (segments.length == 4 && segments[3] == "situations") {
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listSituations(tenantId), 200);
            return;
          }
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.createSituation(tenantId, req.json), 201);
            return;
          }
        }

        if (segments.length == 4 && segments[3] == "dashboard" && req.method == HTTPMethod.GET) {
          res.writeJsonBody(_service.dashboard(tenantId), 200);
          return;
        }

        if (segments.length == 5
          && segments[3] == "situations"
          && segments[4] == "analysis"
          && req.method == HTTPMethod.GET) {
          auto filterType = req.query.get("type", "");
          res.writeJsonBody(_service.analyzeSituations(tenantId, filterType), 200);
          return;
        }

        if (segments.length == 5
          && segments[3] == "situations"
          && segments[4] == "explore"
          && req.method == HTTPMethod.GET) {
          res.writeJsonBody(_service.exploreRelatedSituations(tenantId), 200);
          return;
        }

        if (segments.length == 5
          && segments[3] == "reports"
          && segments[4] == "context"
          && req.method == HTTPMethod.GET) {
          res.writeJsonBody(_service.contextReports(tenantId), 200);
          return;
        }
      }

      respondError(res, "Not found", 404);
    } catch (ISAAuthorizationException e) {
      respondError(res, e.msg, 401);
    } catch (ISANotFoundException e) {
      respondError(res, e.msg, 404);
    } catch (ISAValidationException e) {
      respondError(res, e.msg, 422);
    } catch (ISAException e) {
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
      throw new ISAAuthorizationException("Missing Authorization header");
    }

    auto expected = "Bearer " ~ _service.config.authToken;
    if (req.headers["Authorization"] != expected) {
      throw new ISAAuthorizationException("Invalid token");
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
    payload["status_code"] = statusCode;
    res.writeJsonBody(payload, statusCode);
  }
}
