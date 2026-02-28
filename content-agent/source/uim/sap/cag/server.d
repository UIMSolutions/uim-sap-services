module uim.sap.cag.server;

import std.array : split;
import std.string : startsWith;

import vibe.data.json : Json;
import vibe.http.common : HTTPMethod;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse, HTTPServerSettings, listenHTTP;

import uim.sap.cag.exceptions;
import uim.sap.cag.service;

class CAGServer {
  private CAGService _service;

  this(CAGService service) {
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

    if (subPath == "/" && req.method == HTTPMethod.GET) {
      res.contentType = "text/html; charset=utf-8";
      res.writeBody(_service.dashboardHtml());
      return;
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

        if (segments.length == 4 && segments[3] == "providers") {
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listProviders(tenantId), 200);
            return;
          }
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.upsertProvider(tenantId, req.json), 200);
            return;
          }
        }

        if (segments.length == 4 && segments[3] == "content") {
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listContent(tenantId), 200);
            return;
          }
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.upsertContent(tenantId, req.json), 200);
            return;
          }
        }

        if (segments.length == 5 && segments[3] == "content" && req.method == HTTPMethod.GET) {
          res.writeJsonBody(_service.getContent(tenantId, segments[4]), 200);
          return;
        }

        if (segments.length == 4 && segments[3] == "queues") {
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listQueues(tenantId), 200);
            return;
          }
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.upsertQueue(tenantId, req.json), 200);
            return;
          }
        }

        if (segments.length == 4 && segments[3] == "assemblies") {
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listAssemblies(tenantId), 200);
            return;
          }
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.createAssembly(tenantId, req.json), 200);
            return;
          }
        }

        if (segments.length == 5 && segments[3] == "assemblies" && req.method == HTTPMethod.GET) {
          res.writeJsonBody(_service.getAssembly(tenantId, segments[4]), 200);
          return;
        }

        if (segments.length == 6
          && segments[3] == "assemblies"
          && segments[5] == "mtar"
          && req.method == HTTPMethod.GET) {
          res.writeJsonBody(_service.getMtarMetadata(tenantId, segments[4]), 200);
          return;
        }

        if (segments.length == 6
          && segments[3] == "assemblies"
          && segments[5] == "export"
          && req.method == HTTPMethod.POST) {
          res.writeJsonBody(_service.exportAssembly(tenantId, segments[4], req.json), 200);
          return;
        }

        if (segments.length == 4 && segments[3] == "activities" && req.method == HTTPMethod.GET) {
          res.writeJsonBody(_service.listActivities(tenantId), 200);
          return;
        }
      }

      respondError(res, "Not found", 404);
    } catch (CAGAuthorizationException e) {
      respondError(res, e.msg, 401);
    } catch (CAGNotFoundException e) {
      respondError(res, e.msg, 404);
    } catch (CAGValidationException e) {
      respondError(res, e.msg, 422);
    } catch (CAGException e) {
      respondError(res, e.msg, 500);
    } catch (Exception e) {
      respondError(res, e.msg, 500);
    }
  }

  private void validateAuth(HTTPServerRequest req) {
    if (!_service.config.requireAuthToken)
      return;
    if (!("Authorization" in req.headers))
      throw new CAGAuthorizationException("Missing Authorization header");
    auto expected = "Bearer " ~ _service.config.authToken;
    if (req.headers["Authorization"] != expected)
      throw new CAGAuthorizationException("Invalid token");
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
