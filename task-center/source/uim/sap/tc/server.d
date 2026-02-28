module uim.sap.tc.server;

import std.array : split;
import std.conv : to;
import std.string : startsWith;

import vibe.data.json : Json;
import vibe.http.common : HTTPMethod;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse, HTTPServerSettings, listenHTTP;

import uim.sap.tc.exceptions;
import uim.sap.tc.service;

class TCServer {
  private TCService _service;
  private string _host;
  private ushort _port;
  private string _basePath;
  private bool _requireAuthToken;
  private string _authToken;
  private string[string] _customHeaders;

  this(TCService service) {
    _service = service;

    auto cfg = service.config;
    _host = cfg.host;
    _port = cfg.port;
    _basePath = cfg.basePath;
    _requireAuthToken = cfg.requireAuthToken;
    _authToken = cfg.authToken;
    _customHeaders = cfg.customHeaders;
  }

  void run() {
    auto settings = new HTTPServerSettings;
    settings.port = _service.config.port;
    settings.bindAddresses = [_service.config.host];
    listenHTTP(settings, &handleRequest);
    runApplication();
  }

  private void handleRequest(HTTPServerRequest req, HTTPServerResponse res) {
    foreach (key, value; _customHeaders)
      res.headers[key] = value;

    auto basePath = _basePath;
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

      if (segments.length == 2 && segments[0] == "v1" && segments[1] == "providers") {
        if (req.method == HTTPMethod.GET) {
          res.writeJsonBody(_service.listProviders(), 200);
          return;
        }
        if (req.method == HTTPMethod.POST) {
          res.writeJsonBody(_service.registerProvider(req.json), 201);
          return;
        }
      }

      if (
        segments.length == 6 && segments[0] == "v1" && segments[1] == "tenants" &&
        segments[3] == "providers" && segments[5] == "tasks"
        ) {
        if (req.method == HTTPMethod.POST) {
          auto tenantId = segments[2];
          auto providerId = segments[4];
          res.writeJsonBody(_service.federateTasks(tenantId, providerId, req.json), 200);
          return;
        }
      }

      if (
        segments.length == 4 && segments[0] == "v1" && segments[1] == "tenants" &&
        segments[3] == "tasks" && req.method == HTTPMethod.GET
        ) {
        auto tenantId = segments[2];
        auto assignee = req.query.get("assignee", "");
        auto status = req.query.get("status", "");
        auto providerId = req.query.get("provider_id", "");
        auto priority = req.query.get("priority", "");
        auto search = req.query.get("search", "");
        auto sortBy = req.query.get("sort_by", "updated_at");
        auto sortOrder = req.query.get("sort_order", "desc");

        auto limit = parseSizeT(req.query.get("limit", "100"), 100);
        auto offset = parseSizeT(req.query.get("offset", "0"), 0);

        res.writeJsonBody(
          _service.listTasks(
            tenantId,
            assignee,
            status,
            providerId,
            priority,
            search,
            sortBy,
            sortOrder,
            limit,
            offset
        ),
        200
        );
        return;
      }

      if (
        segments.length == 5 && segments[0] == "v1" && segments[1] == "tenants" &&
        segments[3] == "tasks" && req.method == HTTPMethod.GET
        ) {
        auto tenantId = segments[2];
        auto taskId = segments[4];
        res.writeJsonBody(_service.getTask(tenantId, taskId), 200);
        return;
      }

      if (
        segments.length == 6 && segments[0] == "v1" && segments[1] == "tenants" &&
        segments[3] == "tasks" && segments[5] == "actions" && req.method == HTTPMethod.POST
        ) {
        auto tenantId = segments[2];
        auto taskId = segments[4];
        res.writeJsonBody(_service.performTaskAction(tenantId, taskId, req.json), 200);
        return;
      }

      if (
        segments.length == 6 && segments[0] == "v1" && segments[1] == "tenants" &&
        segments[3] == "tasks" && segments[5] == "navigate" && req.method == HTTPMethod.GET
        ) {
        auto tenantId = segments[2];
        auto taskId = segments[4];
        res.writeJsonBody(_service.navigateToTaskApp(tenantId, taskId), 200);
        return;
      }

      respondError(res, "Not found", 404);
    } catch (TCAuthorizationException e) {
      respondError(res, e.msg, 401);
    } catch (TCValidationException e) {
      respondError(res, e.msg, 422);
    } catch (TCNotFoundException e) {
      respondError(res, e.msg, 404);
    } catch (TCStoreException e) {
      respondError(res, e.msg, 500);
    } catch (TCException e) {
      respondError(res, e.msg, 500);
    } catch (Exception e) {
      respondError(res, e.msg, 500);
    }
  }

  private void validateAuth(HTTPServerRequest req) {
    if (!_requireAuthToken)
      return;
    if (!("Authorization" in req.headers))
      throw new TCAuthorizationException("Missing Authorization header");

    auto expected = "Bearer " ~ _authToken;
    if (req.headers["Authorization"] != expected)
      throw new TCAuthorizationException("Invalid token");
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

  private size_t parseSizeT(string rawValue, size_t fallback) {
    try {
      auto parsed = to!long(rawValue);
      if (parsed < 0)
        return fallback;
      return cast(size_t)parsed;
    } catch (Exception) {
      return fallback;
    }
  }

  private void respondError(HTTPServerResponse res, string message, int statusCode) {
    Json payload = Json.emptyObject;
    payload["success"] = false;
    payload["message"] = message;
    payload["status_code"] = statusCode;
    res.writeJsonBody(payload, statusCode);
  }
}
