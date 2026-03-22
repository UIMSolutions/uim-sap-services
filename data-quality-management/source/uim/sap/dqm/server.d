module uim.sap.dqm.server;

import uim.sap.dqm;

mixin(ShowModule!());

@safe:


class DQMServer {
  private DQMService _service;

  this(DQMService service) {
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

      if (segments.length == 3 && segments[0] == "v1" && segments[1] == "address" && segments[2] == "cleanse" && req
        .method == HTTPMethod.POST) {
        res.writeJsonBody(_service.cleanseAddress(req.json), 200);
        return;
      }

      if (segments.length == 2 && segments[0] == "v1" && segments[1] == "geocode" && req.method == HTTPMethod
        .POST) {
        res.writeJsonBody(_service.geocode(req.json), 200);
        return;
      }

      if (segments.length == 2 && segments[0] == "v1" && segments[1] == "reverse-geocode" && req.method == HTTPMethod
        .POST) {
        res.writeJsonBody(_service.reverseGeocode(req.json), 200);
        return;
      }

      if (segments.length == 3 && segments[0] == "v1" && segments[1] == "address" && segments[2] == "suggest" && req
        .method == HTTPMethod.POST) {
        res.writeJsonBody(_service.suggestAddresses(req.json), 200);
        return;
      }

      respondError(res, "Not found", 404);
    } catch (DQMAuthorizationException e) {
      respondError(res, e.msg, 401);
    } catch (DQMNotFoundException e) {
      respondError(res, e.msg, 404);
    } catch (DQMValidationException e) {
      respondError(res, e.msg, 422);
    } catch (DQMException e) {
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
      throw new DQMAuthorizationException("Missing Authorization header");
    }

    auto expected = "Bearer " ~ _service.config.authToken;
    if (req.headers["Authorization"] != expected) {
      throw new DQMAuthorizationException("Invalid token");
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
    Json payload = Json.emptyObject
      .set("success", false)
      .set("message", message)
      .set("statusCode", statusCode);
      
    res.writeJsonBody(payload, statusCode);
  }
}
