module uim.sap.auditlog.server;

import std.array : split;
import std.string : startsWith;

import vibe.data.json : Json;
import vibe.http.common : HTTPMethod;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse, HTTPServerSettings, listenHTTP;

import uim.sap.auditlog.exceptions;
import uim.sap.auditlog.service;

class AuditLogServer {
  private AuditLogService _service;

  this(AuditLogService service) {
    _service = service;
  }

  void run() {
    auto settings = new HTTPServerSettings;
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

        if (segments.length == 4
          && segments[3] == "event-types"
          && req.method == HTTPMethod.GET) {
          res.writeJsonBody(_service.listRecommendedEventTypes(), 200);
          return;
        }

        if (segments.length == 4 && segments[3] == "events") {
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listEvents(tenantId), 200);
            return;
          }
          if (req.method == HTTPMethod.POST) {
            validateOAuthForWrite(req);
            res.writeJsonBody(_service.writeEvent(tenantId, req.json), 200);
            return;
          }
        }

        if (segments.length == 5
          && segments[3] == "events"
          && segments[4] == "retrieve"
          && req.method == HTTPMethod.POST) {
          res.writeJsonBody(_service.retrieveEvents(tenantId, req.json), 200);
          return;
        }

        if (segments.length == 5
          && segments[3] == "viewer"
          && segments[4] == "logs"
          && req.method == HTTPMethod.GET) {
          res.writeJsonBody(_service.viewer(tenantId), 200);
          return;
        }

        if (segments.length == 4 && segments[3] == "retention") {
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.getRetentionPolicy(tenantId), 200);
            return;
          }
          if (req.method == HTTPMethod.PUT) {
            res.writeJsonBody(_service.updateRetentionPolicy(tenantId, req.json), 200);
            return;
          }
        }

        if (segments.length == 5
          && segments[3] == "usage"
          && segments[4] == "cost"
          && req.method == HTTPMethod.GET) {
          res.writeJsonBody(_service.usageAndCost(tenantId), 200);
          return;
        }
      }

      respondError(res, "Not found", 404);
    } catch (AuditLogAuthorizationException e) {
      respondError(res, e.msg, 401);
    } catch (AuditLogNotFoundException e) {
      respondError(res, e.msg, 404);
    } catch (AuditLogValidationException e) {
      respondError(res, e.msg, 422);
    } catch (AuditLogException e) {
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
      throw new AuditLogAuthorizationException("Missing Authorization header");
    }

    auto expected = "Bearer " ~ _service.config.authToken;
    if (req.headers["Authorization"] != expected) {
      throw new AuditLogAuthorizationException("Invalid management token");
    }
  }

  private void validateOAuthForWrite(HTTPServerRequest req) {
    if (!_service.config.requireOAuthToken) {
      return;
    }

    if (!("Authorization" in req.headers)) {
      throw new AuditLogAuthorizationException("Missing OAuth Authorization header for write API");
    }

    auto expected = "Bearer " ~ _service.config.oauthToken;
    if (req.headers["Authorization"] != expected) {
      throw new AuditLogAuthorizationException("Invalid OAuth token for write API");
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
