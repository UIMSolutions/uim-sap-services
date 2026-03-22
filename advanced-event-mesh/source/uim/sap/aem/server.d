/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.aem.server;

import uim.sap.aem;

mixin(ShowModule!());

@safe:

/**
 * AEMServer is responsible for handling HTTP requests and routing them to the appropriate service methods.
 *
  * It listens on the configured host and port, and supports the following endpoints:
  * - GET /health: Returns the health status of the service.
  * - GET /ready: Returns the readiness status of the service.
  * - POST /v1/tenants/{tenantId}/broker-services: Creates a new broker service for the tenant.
  * - GET /v1/tenants/{tenantId}/broker-services: Lists all broker services for the tenant.
  * - POST /v1/tenants/{tenantId}/broker-services/{brokerServiceId}/event-meshes: Creates a new event mesh under the specified broker service.
  * - GET /v1/tenants/{tenantId}/event-meshes: Lists all event meshes for the tenant.
  * - POST /v1/tenants/{tenantId}/event-meshes/{meshId}/topics: Registers a new topic under the specified event mesh.
  * - POST /v1/tenants/{tenantId}/event-meshes/{meshId}/publish: Publishes an event to the specified event mesh.
  * - GET /v1/tenants/{tenantId}/event-meshes/{meshId}/topics/{topic}/events: Lists events for the specified topic under the event mesh.
  * - POST /v1/tenants/{tenantId}/components: Upserts a component for the tenant.
  * - GET /v1/tenants/{tenantId}/components: Lists all components for the tenant.
  * - POST /v1/tenants/{tenantId}/components/{componentId}/subscriptions: Adds a subscription to the specified component.
  * - GET /v1/tenants/{tenantId}/eda/model: Returns the EDA model for the tenant.
  * - GET /v1/tenants/{tenantId}/monitoring/dashboard: Returns monitoring dashboard data for the tenant.
  * - GET /v1/tenants/{tenantId}/monitoring/alerts: Lists monitoring alerts for the tenant.
  * - GET /v1/tenants/{tenantId}/monitoring/notifications: Lists notification rules for the tenant.
  * - PUT /v1/tenants/{tenantId}/monitoring/notifications/{ruleId}: Upserts a notification rule for the tenant.
 * The server also handles authentication if enabled in the configuration, by validating the Authorization header against the expected token.
 *
 * Fields:
 * - _service: The AEMService instance that contains the business logic for handling requests.
 * Methods:
 * - this(AEMService service): Constructor that initializes the server with the given service instance.
 * - run(): Starts the HTTP server and begins listening for requests.
 * - handleRequest(HTTPServerRequest req, HTTPServerResponse res): Handles incoming HTTP requests, routes them to the appropriate service methods, and sends responses back to the client.
 * - validateAuth(HTTPServerRequest req): Validates the Authorization header of the request if token authentication is enabled in the configuration.
 * - normalizedSegments(string subPath): Utility method to normalize and split the request path into segments for routing.
 * - respondError(HTTPServerResponse res, string message, int statusCode): Utility method to send an error response with a Json data containing the error message and status code.
 */
class AEMServer : SAPServer {
  mixin(SAPServerTemplate!AEMServer);
  
  private AEMService _service;

  this(AEMService service) {
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

        if (segments.length == 4 && segments[3] == "broker-services") {
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listBrokerServices(tenantId), 200);
            return;
          }
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.createBrokerService(tenantId, req.json), 200);
            return;
          }
        }

        if (segments.length == 6
          && segments[3] == "broker-services"
          && segments[5] == "event-meshes"
          && req.method == HTTPMethod.POST) {
          res.writeJsonBody(_service.createEventMesh(tenantId, segments[4], req.json), 200);
          return;
        }

        if (segments.length == 4 && segments[3] == "event-meshes" && req.method == HTTPMethod.GET) {
          res.writeJsonBody(_service.listEventMeshes(tenantId), 200);
          return;
        }

        if (segments.length == 6
          && segments[3] == "event-meshes"
          && segments[5] == "topics"
          && req.method == HTTPMethod.POST) {
          res.writeJsonBody(_service.registerTopic(tenantId, segments[4], req.json), 200);
          return;
        }

        if (segments.length == 6
          && segments[3] == "event-meshes"
          && segments[5] == "publish"
          && req.method == HTTPMethod.POST) {
          res.writeJsonBody(_service.publishEvent(tenantId, segments[4], req.json), 200);
          return;
        }

        if (segments.length == 8
          && segments[3] == "event-meshes"
          && segments[5] == "topics"
          && segments[7] == "events"
          && req.method == HTTPMethod.GET) {
          auto meshId = segments[4];
          auto topic = segments[6];
          res.writeJsonBody(_service.listTopicEvents(tenantId, meshId, topic), 200);
          return;
        }

        if (segments.length == 4 && segments[3] == "components") {
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listComponents(tenantId), 200);
            return;
          }
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.upsertComponent(tenantId, req.json), 200);
            return;
          }
        }

        if (segments.length == 6
          && segments[3] == "components"
          && segments[5] == "subscriptions"
          && req.method == HTTPMethod.POST) {
          res.writeJsonBody(_service.addSubscription(tenantId, segments[4], req.json), 200);
          return;
        }

        if (segments.length == 5
          && segments[3] == "eda"
          && segments[4] == "model"
          && req.method == HTTPMethod.GET) {
          res.writeJsonBody(_service.modelEDA(tenantId), 200);
          return;
        }

        if (segments.length == 5
          && segments[3] == "monitoring"
          && segments[4] == "dashboard"
          && req.method == HTTPMethod.GET) {
          res.writeJsonBody(_service.monitoringDashboard(tenantId), 200);
          return;
        }

        if (segments.length == 5
          && segments[3] == "monitoring"
          && segments[4] == "alerts"
          && req.method == HTTPMethod.GET) {
          res.writeJsonBody(_service.listAlerts(tenantId), 200);
          return;
        }

        if (segments.length == 5
          && segments[3] == "monitoring"
          && segments[4] == "notifications"
          && req.method == HTTPMethod.GET) {
          res.writeJsonBody(_service.listNotificationRules(tenantId), 200);
          return;
        }

        if (segments.length == 6
          && segments[3] == "monitoring"
          && segments[4] == "notifications"
          && req.method == HTTPMethod.PUT) {
          auto ruleId = segments[5];
          res.writeJsonBody(_service.upsertNotificationRule(tenantId, ruleId, req.json), 200);
          return;
        }
      }

      respondError(res, "Not found", 404);
    } catch (AEMAuthorizationException e) {
      respondError(res, e.msg, 401);
    } catch (AEMNotFoundException e) {
      respondError(res, e.msg, 404);
    } catch (AEMValidationException e) {
      respondError(res, e.msg, 422);
    } catch (AEMException e) {
      respondError(res, e.msg, 500);
    } catch (Exception e) {
      respondError(res, e.msg, 500);
    }
  }

  private void validateAuth(HTTPServerRequest req) {
    AEMConfig cfg = cast(AEMConfig)_service.config;
    if (!cfg.requireAuthToken) {
      return;
    }

    if (!("Authorization" in req.headers)) {
      throw new AEMAuthorizationException("Missing Authorization header");
    }

    auto expected = "Bearer " ~ cfg.authToken;
    if (req.headers["Authorization"] != expected) {
      throw new AEMAuthorizationException("Invalid token");
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

  private void respondError(HTTPServerResponse res, string message, int statusCode) {
    Json payload = Json.emptyObject;
    payload["success"] = false;
    payload["message"] = message;
    payload["statusCode"] = statusCode;
    res.writeJsonBody(payload, statusCode);
  }
}
