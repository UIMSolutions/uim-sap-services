/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.art.server;

import uim.sap.art;

mixin(ShowModule!());

@safe:

class ARTRuntimeServer {
  private ARTRuntime _runtime;

  this(ARTRuntime runtime) {
    _runtime = runtime;
  }

  ARTRuntime runtime() {
    return _runtime;
  }

  void run() {
    // auto settings = new HTTPServerSettings;
    // settings.port = _service.config.port;
    // settings.bindAddresses = [_service.config.host];
    // listenHTTP(settings, &handleRequest);
    // runApplication();
  }

  private void handleRequest(HTTPServerRequest req, HTTPServerResponse res) {
    foreach (key, value; _runtime.config.customHeaders) {
      res.headers[key] = value;
    }

    auto basePath = _runtime.config.basePath;
    auto path = req.path;

    if (!path.startsWith(basePath)) {
      respondError(res, "Not found", 404);
      return;
    }

    if (path.endsWith("/health") && req.method == HTTPMethod.GET) {
      res.statusCode = 200;
      res.writeJsonBody(_runtime.health().toJson());
      return;
    }

    if (path.endsWith("/programs") && req.method == HTTPMethod.GET) {
      Json programs = _runtime.listPrograms().map!(prog => Json(name)).toJson;

      Json payload = Json.emptyObject
        .set("programs", programs)
        .set("count", cast(long)_runtime.registeredProgramCount);

      res.statusCode = 200;
      res.writeJsonBody(payload);
      return;
    }

    if (path.endsWith("/run") && req.method == HTTPMethod.POST) {
      try {
        validateAuth(req);
        auto input = req.json;
        auto programRequest = ARTProgramRequest.fromJson(input);
        auto output = _runtime.execute(programRequest);
        res.statusCode = output.statusCode;
        res.writeJsonBody(output.toJson());
      } catch (ARTRuntimeAuthenticationException e) {
        respondError(res, e.msg, 401);
      } catch (ARTRuntimeProgramNotFoundException e) {
        respondError(res, e.msg, 404);
      } catch (ARTRuntimeExecutionException e) {
        respondError(res, e.msg, 422);
      } catch (ARTRuntimeException e) {
        respondError(res, e.msg, 500);
      } catch (Exception e) {
        respondError(res, e.msg, 500);
      }
      return;
    }

    respondError(res, "Not found", 404);
  }

  private void validateAuth(HTTPServerRequest req) {
    if (!_runtime.config.requireAuthToken) {
      return;
    }

    if (!("Authorization" in req.headers)) {
      throw new ARTRuntimeAuthenticationException("Missing Authorization header");
    }

    auto auth = req.headers["Authorization"];
    auto expected = "Bearer " ~ _runtime.config.authToken;
    if (auth != expected) {
      throw new ARTRuntimeAuthenticationException("Invalid token");
    }
  }

  private void respondError(HTTPServerResponse res, string message, int statusCode) {
    Json payload = Json.emptyObject;
    payload["success"] = false;
    payload["message"] = message;
    payload["statusCode"] = statusCode;
    res.statusCode = statusCode;
    res.writeJsonBody(payload);
  }
}
