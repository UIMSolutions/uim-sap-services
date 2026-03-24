/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.alertnotification.server;

import uim.sap.alertnotification;

mixin(ShowModule!());

@safe:

/**
  * The AlertNotificationServer class is responsible for handling incoming HTTP requests and routing them to the appropriate service methods.
  * It validates authentication, parses request paths, and constructs JSON responses based on the service's output.
  *
  * The server listens on the host and port specified in the service configuration and supports the following endpoints:
  * - GET /health: Returns the health status of the service.
  * - GET /ready: Returns the readiness status of the service.
  * - GET /v1/built-in-events: Lists the built-in events supported by the service.
  * - GET /v1/delivery-options: Lists the available delivery options for alerts.
  * - POST /v1/tenants/{tenantId}/providers/alerts: Publishes a new alert for the specified tenant.
  * - GET /v1/tenants/{tenantId}/alerts: Lists all alerts for the specified tenant.
  * - POST /v1/tenants/{tenantId}/alerts/search: Searches for alerts based on criteria specified in the request body.
  * - GET /v1/tenants/{tenantId}/subscriptions: Lists all subscriptions for the specified tenant.
  * - POST /v1/tenants/{tenantId}/subscriptions: Creates or updates a subscription for the specified tenant.
  * - GET /v1/tenants/{tenantId}/subscriptions/{subscriptionId}: Retrieves details of a specific subscription.
  * - PUT /v1/tenants/{tenantId}/subscriptions/{subscriptionId}: Updates a specific subscription.
  * - DELETE /v1/tenants/{tenantId}/subscriptions/{subscriptionId}: Deletes a specific subscription.
  * - POST /v1/tenants/{tenantId}/subscriptions/{subscriptionId}/test: Tests a specific subscription with provided data.
  * - GET /v1/tenants/{tenantId}/deliveries: Lists all deliveries for the specified tenant.
  * The server also handles authentication by validating the Authorization header against a configured token, if required.
  * Error handling is implemented to return appropriate HTTP status codes and messages for various exceptions that may occur during request processing.
  */
class AlertNotificationServer : SAPServer {
  mixin(SAPServerTemplate!AlertNotificationServer);

  private AlertNotificationService _service;

  this(AlertNotificationService service) {
    _service = service;
  }

  override void handleRequest(HTTPServerRequest req, HTTPServerResponse res) {
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
      validateAuth(req, _service.config);

      auto segments = normalizedSegments(subPath);
      if (segments.length == 2
          && segments[0] == "v1"
          && segments[1] == "built-in-events"
          && req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.listBuiltInEvents(), 200);
        return;
      }

      if (segments.length == 2
          && segments[0] == "v1"
          && segments[1] == "delivery-options"
          && req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.listDeliveryOptions(), 200);
        return;
      }

      if (segments.length >= 3 && segments[0] == "v1" && segments[1] == "tenants") {
        auto tenantId = segments[2];

        if (segments.length == 4 && segments[3] == "overview" && req.method == HTTPMethod.GET) {
          res.writeJsonBody(_service.tenantOverview(tenantId), 200);
          return;
        }

        if (segments.length == 5
            && segments[3] == "providers"
            && segments[4] == "alerts"
            && req.method == HTTPMethod.POST) {
          res.writeJsonBody(_service.publishAlert(tenantId, req.json), 200);
          return;
        }

        if (segments.length == 4 && segments[3] == "alerts" && req.method == HTTPMethod.GET) {
          res.writeJsonBody(_service.listAlerts(tenantId), 200);
          return;
        }

        if (segments.length == 5
            && segments[3] == "alerts"
            && segments[4] == "search"
            && req.method == HTTPMethod.POST) {
          res.writeJsonBody(_service.searchAlerts(tenantId, req.json), 200);
          return;
        }

        if (segments.length == 4 && segments[3] == "subscriptions") {
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listSubscriptions(tenantId), 200);
            return;
          }
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.upsertSubscription(tenantId, req.json), 200);
            return;
          }
        }

        if (segments.length == 5 && segments[3] == "subscriptions") {
          auto subscriptionId = segments[4];
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.getSubscription(tenantId, subscriptionId), 200);
            return;
          }
          if (req.method == HTTPMethod.PUT) {
            Json payload = req.json;
            payload["subscription_id"] = subscriptionId;
            res.writeJsonBody(_service.upsertSubscription(tenantId, payload), 200);
            return;
          }
          if (req.method == HTTPMethod.DELETE) {
            res.writeJsonBody(_service.deleteSubscription(tenantId, subscriptionId), 200);
            return;
          }
        }

        if (segments.length == 6
          && segments[3] == "subscriptions"
          && segments[5] == "test"
          && req.method == HTTPMethod.POST) {
          auto subscriptionId = segments[4];
          res.writeJsonBody(_service.testSubscription(tenantId, subscriptionId, req.json), 200);
          return;
        }

        if (segments.length == 4 && segments[3] == "deliveries" && req.method == HTTPMethod.GET) {
          res.writeJsonBody(_service.listDeliveries(tenantId), 200);
          return;
        }
      }

      respondError(res, "Not found", 404);
    } catch (AlertNotificationAuthorizationException e) {
      respondError(res, e.msg, 401);
    } catch (AlertNotificationNotFoundException e) {
      respondError(res, e.msg, 404);
    } catch (AlertNotificationValidationException e) {
      respondError(res, e.msg, 422);
    } catch (AlertNotificationException e) {
      respondError(res, e.msg, 500);
    } catch (Exception e) {
      respondError(res, e.msg, 500);
    }
  }
}
