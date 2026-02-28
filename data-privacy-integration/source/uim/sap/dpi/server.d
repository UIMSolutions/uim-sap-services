module uim.sap.dpi.server;

import std.array : split;
import std.string : startsWith;

import vibe.data.json : Json;
import vibe.http.common : HTTPMethod;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse, HTTPServerSettings, listenHTTP;

import uim.sap.dpi.exceptions;
import uim.sap.dpi.service;

class DPIServer {
  private DPIService _service;

  this(DPIService service) {
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
    foreach (key, value; _service.config.customHeaders)
      res.headers[key] = value;

    auto basePath = _service.config.basePath;
    auto path = req.path;
    if (!path.startsWith(basePath)) {
      respondError(res, "Not found", 404);
      return;
    }

    auto subPath = path[basePath.length .. $];
    if (subPath.length == 0)
      subPath = "/";

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

      if (segments.length == 3 && segments[0] == "v1" && segments[1] == "privacy" && segments[2] == "anonymize" && req
        .method == HTTPMethod.POST) {
        res.writeJsonBody(_service.anonymize(req.json), 200);
        return;
      }

      if (segments.length >= 3 && segments[0] == "v1" && segments[1] == "tenants") {
        auto tenantId = segments[2];

        if (segments.length == 4 && segments[3] == "records" && req.method == HTTPMethod.POST) {
          res.writeJsonBody(_service.ingestRecord(tenantId, req.json), 200);
          return;
        }

        if (segments.length == 5 && segments[3] == "retention" && segments[4] == "rules" && req.method == HTTPMethod
          .GET) {
          res.writeJsonBody(_service.listRetentionRules(tenantId), 200);
          return;
        }

        if (segments.length == 6 && segments[3] == "retention" && segments[4] == "rules" && req.method == HTTPMethod
          .PUT) {
          auto ruleId = segments[5];
          res.writeJsonBody(_service.upsertRetentionRule(tenantId, ruleId, req.json), 200);
          return;
        }

        if (segments.length == 5 && segments[3] == "retention" && segments[4] == "trigger" && req.method == HTTPMethod
          .POST) {
          res.writeJsonBody(_service.triggerRetentionDeletion(tenantId, req.json), 200);
          return;
        }

        if (segments.length == 5 && segments[3] == "reporting" && segments[4] == "report" && req.method == HTTPMethod
          .POST) {
          res.writeJsonBody(_service.generateReport(tenantId, req.json), 200);
          return;
        }

        if (segments.length == 5 && segments[3] == "reporting" && segments[4] == "export" && req.method == HTTPMethod
          .POST) {
          res.writeJsonBody(_service.exportReport(tenantId, req.json), 200);
          return;
        }

        if (segments.length == 5 && segments[3] == "reporting" && segments[4] == "correct" && req.method == HTTPMethod
          .POST) {
          res.writeJsonBody(_service.triggerCorrection(tenantId, req.json), 200);
          return;
        }

        if (segments.length == 5 && segments[3] == "reporting" && segments[4] == "delete" && req.method == HTTPMethod
          .POST) {
          res.writeJsonBody(_service.triggerDeletion(tenantId, req.json), 200);
          return;
        }
      }

      respondError(res, "Not found", 404);
    } catch (DPIAuthorizationException e) {
      respondError(res, e.msg, 401);
    } catch (DPINotFoundException e) {
      respondError(res, e.msg, 404);
    } catch (DPIValidationException e) {
      respondError(res, e.msg, 422);
    } catch (DPIException e) {
      respondError(res, e.msg, 500);
    } catch (Exception e) {
      respondError(res, e.msg, 500);
    }
  }

  private void validateAuth(HTTPServerRequest req) {
    if (!_service.config.requireAuthToken)
      return;
    if (!("Authorization" in req.headers))
      throw new DPIAuthorizationException("Missing Authorization header");
    auto expected = "Bearer " ~ _service.config.authToken;
    if (req.headers["Authorization"] != expected)
      throw new DPIAuthorizationException("Invalid token");
  }

  private string[] normalizedSegments(string subPath) {
    auto clean = subPath;
    if (clean.length > 0 && clean[0] == '/')
      clean = clean[1 .. $];
    if (clean.length > 0 && clean[$ - 1] == '/')
      clean = clean[0 .. $ - 1];
    if (clean.length == 0)
      return [];
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
