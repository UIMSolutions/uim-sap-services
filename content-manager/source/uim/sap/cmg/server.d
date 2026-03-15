/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.cmg.server;

import uim.sap.cmg;

mixin(ShowModule!());

@safe:

/**
 * CMGServer is responsible for handling incoming HTTP requests and routing them to the appropriate service methods.
 * It also handles authentication and error responses.
 *
  * Fields:
  * - CMGService _service: An instance of the CMGService class that contains the business logic for handling requests.
  * Example usage:
  * CMGConfig config = CMGConfig(
  *     host: "0.0.0.0",
  *     port: 8095,
  *     basePath: "/api/cmg"
  * );
  * CMGService service = new CMGService(config);
  * CMGServer server = new CMGServer(service);
  * server.run();
  *
  * The server listens for HTTP requests on the configured host and port, and routes requests based on the URL path and HTTP method.
  * It provides endpoints for health checks, readiness checks, and operations related to tenants, content, and providers.
  * The server also validates authentication tokens if required by the configuration and returns appropriate error responses for unauthorized access, not found resources, validation errors, and other exceptions.
 *
 * Methods:
 * - void run(): Starts the HTTP server and listens for incoming requests.
 * - private void handleRequest(HTTPServerRequest req, HTTPServerResponse res): Handles incoming HTTP requests, routes them to the appropriate service methods, and returns responses.
 * - private void validateAuth(HTTPServerRequest req): Validates the authentication token in the request headers if required by the configuration.
 * - private string[] normalizedSegments(string subPath): Normalizes the URL path segments for easier routing.
 * - private void respondError(HTTPServerResponse res, string message, int statusCode): Sends an error response with a Json data containing the error message and status code.
 */ 
class CMGServer {
  private CMGService _service;

  this(CMGService service) {
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
      if (segments.length >= 3 && segments[0] == "v1" && segments[1] == "tenants") {
        auto tenantId = segments[2];

        if (segments.length == 5 && segments[3] == "content") {
          auto contentType = segments[4];
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listContent(tenantId, contentType), 200);
            return;
          }
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.upsertManualContent(tenantId, contentType, req.json), 200);
            return;
          }
        }

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

        if (segments.length == 6 && segments[3] == "providers" && segments[5] == "integrate" && req.method == HTTPMethod
          .POST) {
          auto providerId = segments[4];
          res.writeJsonBody(_service.integrateProviderContent(tenantId, providerId, req.json), 200);
          return;
        }
      }

      respondError(res, "Not found", 404);
    } catch (CMGAuthorizationException e) {
      respondError(res, e.msg, 401);
    } catch (CMGNotFoundException e) {
      respondError(res, e.msg, 404);
    } catch (CMGValidationException e) {
      respondError(res, e.msg, 422);
    } catch (CMGException e) {
      respondError(res, e.msg, 500);
    } catch (Exception e) {
      respondError(res, e.msg, 500);
    }
  }

  private void validateAuth(HTTPServerRequest req) {
    if (!_service.config.requireAuthToken)
      return;
    if (!("Authorization" in req.headers))
      throw new CMGAuthorizationException("Missing Authorization header");
    auto expected = "Bearer " ~ _service.config.authToken;
    if (req.headers["Authorization"] != expected)
      throw new CMGAuthorizationException("Invalid token");
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
