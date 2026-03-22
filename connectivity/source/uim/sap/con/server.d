/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.con.server;

import uim.sap.con;

mixin(ShowModule!());

@safe:

class CONServer {
  private CONService _service;

  this(CONService service) {
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

      if (subPath == "/v1/protocols" && req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.supportedProtocols(), 200);
        return;
      }

      if (subPath == "/v1/tenants" && req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.listTenants(), 200);
        return;
      }

      auto segments = normalizedSegments(subPath);
      if (segments.length >= 3 && segments[0] == "v1" && segments[1] == "tenants") {
        auto tenantId = segments[2];

        if (segments.length == 4 && segments[3] == "destinations" && req.method == HTTPMethod.GET) {
          res.writeJsonBody(_service.listDestinations(tenantId), 200);
          return;
        }

        if (segments.length == 4 && segments[3] == "cloud-databases" && req.method == HTTPMethod
          .GET) {
          res.writeJsonBody(_service.listCloudDatabases(tenantId), 200);
          return;
        }

        if (segments.length == 5 && segments[3] == "destinations") {
          auto destinationName = segments[4];

          if (req.method == HTTPMethod.PUT) {
            res.writeJsonBody(_service.upsertDestination(tenantId, destinationName, req.json), 200);
            return;
          }

          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.getDestination(tenantId, destinationName), 200);
            return;
          }

          if (req.method == HTTPMethod.DELETE) {
            res.writeJsonBody(_service.deleteDestination(tenantId, destinationName), 200);
            return;
          }
        }

        if (segments.length == 5 && segments[3] == "connect" && req.method == HTTPMethod.POST) {
          auto destinationName = segments[4];
          auto cloudIdentity = req.headers.get("X-Cloud-User", "");
          res.writeJsonBody(_service.connect(tenantId, destinationName, req.json, cloudIdentity), 200);
          return;
        }
      }

      respondError(res, "Not found", 404);
    } catch (CONAuthorizationException e) {
      respondError(res, e.msg, 401);
    } catch (CONNotFoundException e) {
      respondError(res, e.msg, 404);
    } catch (CONValidationException e) {
      respondError(res, e.msg, 422);
    } catch (CONException e) {
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
      throw new CONAuthorizationException("Missing Authorization header");
    }

    auto expected = "Bearer " ~ _service.config.authToken;
    if (req.headers["Authorization"] != expected) {
      throw new CONAuthorizationException("Invalid token");
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
      return null;
    }
    return clean.split("/");
  }
}
