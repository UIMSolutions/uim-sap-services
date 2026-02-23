module uim.sap.mon.server;

import std.array : split;
import std.string : startsWith;

import vibe.data.json : Json;
import vibe.http.common : HTTPMethod;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse, HTTPServerSettings, listenHTTP;

import uim.sap.mon.exceptions;
import uim.sap.mon.service;

class MONServer {
  private MONService _service;

  this(MONService service) {
    _service = service;
  }

  void run() {
    HTTPServerSettings settings;
    settings.port = _service.config.port;
    settings.bindAddresses = [_service.config.host];
    listenHTTP(settings, &handleRequest);
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

    try {
      if (subPath == "/health" && req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.health(), 200);
        return;
      }

      if (subPath == "/ready" && req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.ready(), 200);
        return;
      }

      validateAuth(req);

      auto segments = normalizedSegments(subPath);

      if (segments.length == 4 &&
        segments[0] == "v1" &&
        segments[1] == "applications" &&
        segments[3] == "metrics" &&
        req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.fetchApplicationMetrics(segments[2]), 200);
        return;
      }

      if (segments.length == 4 &&
        segments[0] == "v1" &&
        segments[1] == "databases" &&
        segments[3] == "metrics" &&
        req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.fetchDatabaseMetrics(segments[2]), 200);
        return;
      }

      if (segments.length == 5 &&
        segments[0] == "v1" &&
        segments[1] == "metrics" &&
        segments[2] == "history" &&
        req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.metricHistory(segments[3], segments[4]), 200);
        return;
      }

      if (segments.length == 3 &&
        segments[0] == "v1" &&
        segments[1] == "checks" &&
        segments[2] == "availability" &&
        req.method == HTTPMethod.POST) {
        res.writeJsonBody(_service.registerAvailabilityCheck(req.json), 201);
        return;
      }

      if (segments.length == 4 &&
        segments[0] == "v1" &&
        segments[1] == "alerts" &&
        segments[2] == "channels" &&
        segments[3] == "email" &&
        req.method == HTTPMethod.PUT) {
        res.writeJsonBody(_service.setAlertEmailChannel(req.json), 200);
        return;
      }

      if (segments.length == 4 &&
        segments[0] == "v1" &&
        segments[1] == "alerts" &&
        segments[2] == "channels" &&
        segments[3] == "webhook" &&
        req.method == HTTPMethod.PUT) {
        res.writeJsonBody(_service.setAlertWebhookChannel(req.json), 200);
        return;
      }

      if (segments.length == 3 &&
        segments[0] == "v1" &&
        segments[1] == "alerts" &&
        segments[2] == "channels" &&
        req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.getAlertChannels(), 200);
        return;
      }

      if (segments.length == 3 &&
        segments[0] == "v1" &&
        segments[1] == "checks" &&
        segments[2] == "jmx" &&
        req.method == HTTPMethod.POST) {
        res.writeJsonBody(_service.configureJMXCheck(req.json), 201);
        return;
      }

      if (segments.length == 3 &&
        segments[0] == "v1" &&
        segments[1] == "jmx" &&
        segments[2] == "operations" &&
        req.method == HTTPMethod.POST) {
        res.writeJsonBody(_service.performJMXOperation(req.json), 200);
        return;
      }

      if (segments.length == 3 &&
        segments[0] == "v1" &&
        segments[1] == "checks" &&
        segments[2] == "custom" &&
        req.method == HTTPMethod.POST) {
        res.writeJsonBody(_service.registerCustomCheck(req.json), 201);
        return;
      }

      if (segments.length == 5 &&
        segments[0] == "v1" &&
        segments[1] == "checks" &&
        segments[2] == "default" &&
        segments[4] == "thresholds") {
        if (req.method == HTTPMethod.PUT) {
          res.writeJsonBody(_service.overrideDefaultThreshold(segments[3], req.json), 200);
          return;
        }
        if (req.method == HTTPMethod.GET) {
          res.writeJsonBody(_service.getThresholdOverride(segments[3]), 200);
          return;
        }
      }

      respondError(res, "Not found", 404);
    } catch (MONAuthorizationException e) {
      respondError(res, e.msg, 401);
    } catch (MONNotFoundException e) {
      respondError(res, e.msg, 404);
    } catch (MONValidationException e) {
      respondError(res, e.msg, 422);
    } catch (MONException e) {
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
      throw new MONAuthorizationException("Missing Authorization header");
    }

    auto expected = "Bearer " ~ _service.config.authToken;
    if (req.headers["Authorization"] != expected) {
      throw new MONAuthorizationException("Invalid token");
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
