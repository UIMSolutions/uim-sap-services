module uim.sap.alertnotification.server;

import uim.sap.alertnotification;

mixin(ShowModule!());

@safe:

class AlertNotificationServer {
  private AlertNotificationService _service;

  this(AlertNotificationService service) {
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
      if (segments.length == 2 && segments[0] == "v1" && segments[1] == "built-in-events" && req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.listBuiltInEvents(), 200);
        return;
      }

      if (segments.length == 2 && segments[0] == "v1" && segments[1] == "delivery-options" && req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.listDeliveryOptions(), 200);
        return;
      }

      if (segments.length >= 3 && segments[0] == "v1" && segments[1] == "tenants") {
        auto tenantId = segments[2];

        if (segments.length == 4 && segments[3] == "overview" && req.method == HTTPMethod.GET) {
          res.writeJsonBody(_service.tenantOverview(tenantId), 200);
          return;
        }

        if (segments.length == 5 && segments[3] == "providers" && segments[4] == "alerts" && req.method == HTTPMethod.POST) {
          res.writeJsonBody(_service.publishAlert(tenantId, req.json), 200);
          return;
        }

        if (segments.length == 4 && segments[3] == "alerts" && req.method == HTTPMethod.GET) {
          res.writeJsonBody(_service.listAlerts(tenantId), 200);
          return;
        }

        if (segments.length == 5 && segments[3] == "alerts" && segments[4] == "search" && req.method == HTTPMethod.POST) {
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

  private void validateAuth(HTTPServerRequest req) {
    if (!_service.config.requireAuthToken) {
      return;
    }

    if (!("Authorization" in req.headers)) {
      throw new AlertNotificationAuthorizationException("Missing Authorization header");
    }

    auto expected = "Bearer " ~ _service.config.authToken;
    if (req.headers["Authorization"] != expected) {
      throw new AlertNotificationAuthorizationException("Invalid management token");
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
