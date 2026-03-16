/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.agentry.server;

import uim.sap.agentry;

mixin(ShowModule!());

@safe:

/** 
 * The AgentryServer class is responsible for handling incoming HTTP requests and routing them to the appropriate service methods.
 * It also handles authentication and error responses.
 *
  * The server listens on the configured host and port, and exposes endpoints for managing mobile apps, runtime instances, devices, backend systems, and operations dashboard.
  *
  * Endpoints:
  * - GET /v1/tenants/{tenantId}/mobile-apps: List mobile apps for a tenant
  * - POST /v1/tenants/{tenantId}/mobile-apps: Create or update a mobile app for a tenant
  * - GET /v1/tenants/{tenantId}/mobile-apps/{appId}/versions: List versions of a mobile app
  * - POST /v1/tenants/{tenantId}/mobile-apps/{appId}/versions: Create a new version of a mobile app
  * - GET /v1/tenants/{tenantId}/mobile-apps/{appId}/test-runs: List test runs for a mobile app version
  * - POST /v1/tenants/{tenantId}/mobile-apps/{appId}/test-runs: Trigger a new test run for a mobile app version
  * - GET /v1/tenants/{tenantId}/operations-instances: List runtime instances for a tenant
  * - POST /v1/tenants/{tenantId}/operations-instances: Create or update a runtime instance for a tenant
  * - POST /v1/tenants/{tenantId}/operations-instances/{instanceId}/deploy: Deploy a mobile app version to a runtime instance
  * - GET /v1/tenants/{tenantId}/devices: List devices for a tenant
  * - POST /v1/tenants/{tenantId}/devices: Create or update a device for a tenant
  * - POST /v1/tenants/{tenantId}/devices/{deviceId}/sync: Sync a device for a tenant
  * - GET /v1/tenants/{tenantId}/backend-systems: List backend systems for a tenant
  * - POST /v1/tenants/{tenantId}/backend-systems: Create or update a backend system for a tenant
  * - GET /v1/tenants/{tenantId}/operations/dashboard: Get operations dashboard data for a tenant
 */
class AGTServer {
  private AgentryService _service;

  this(AgentryService service) {
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

        if (segments.length == 4 && segments[3] == "mobile-apps") {
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listMobileApps(tenantId), 200);
            return;
          }
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.upsertMobileApp(tenantId, req.json), 200);
            return;
          }
        }

        if (segments.length == 6
          && segments[3] == "mobile-apps"
          && segments[5] == "versions") {
          auto appId = segments[4];
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listVersions(tenantId, appId), 200);
            return;
          }
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.createVersion(tenantId, appId, req.json), 200);
            return;
          }
        }

        if (segments.length == 6
          && segments[3] == "mobile-apps"
          && segments[5] == "test-runs") {
          auto appId = segments[4];
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listTestRuns(tenantId, appId), 200);
            return;
          }
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.triggerTestRun(tenantId, appId, req.json), 200);
            return;
          }
        }

        if (segments.length == 4 && segments[3] == "operations-instances") {
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listRuntimeInstances(tenantId), 200);
            return;
          }
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.upsertRuntimeInstance(tenantId, req.json), 200);
            return;
          }
        }

        if (segments.length == 6
          && segments[3] == "operations-instances"
          && segments[5] == "deploy"
          && req.method == HTTPMethod.POST) {
          auto instanceId = segments[4];
          res.writeJsonBody(_service.deployVersion(tenantId, instanceId, req.json), 200);
          return;
        }

        if (segments.length == 4 && segments[3] == "devices") {
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listDevices(tenantId), 200);
            return;
          }
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.upsertDevice(tenantId, req.json), 200);
            return;
          }
        }

        if (segments.length == 6
          && segments[3] == "devices"
          && segments[5] == "sync"
          && req.method == HTTPMethod.POST) {
          auto deviceId = segments[4];
          res.writeJsonBody(_service.syncDevice(tenantId, deviceId, req.json), 200);
          return;
        }

        if (segments.length == 4 && segments[3] == "backend-systems") {
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listBackendSystems(tenantId), 200);
            return;
          }
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.upsertBackendSystem(tenantId, req.json), 200);
            return;
          }
        }

        if (segments.length == 5
          && segments[3] == "operations"
          && segments[4] == "dashboard"
          && req.method == HTTPMethod.GET) {
          res.writeJsonBody(_service.operationsDashboard(tenantId), 200);
          return;
        }
      }

      respondError(res, "Not found", 404);
    } catch (AgentryAuthorizationException e) {
      respondError(res, e.msg, 401);
    } catch (AgentryNotFoundException e) {
      respondError(res, e.msg, 404);
    } catch (AgentryValidationException e) {
      respondError(res, e.msg, 422);
    } catch (AGTException e) {
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
      throw new AgentryAuthorizationException("Missing Authorization header");
    }

    auto expected = "Bearer " ~ _service.config.authToken;
    if (req.headers["Authorization"] != expected) {
      throw new AgentryAuthorizationException("Invalid token");
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
