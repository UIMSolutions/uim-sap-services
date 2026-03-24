/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.aas.server;

import uim.sap.aas;

@safe:

class AASServer : SAPServer {
  mixin(SAPServerTemplate!AASServer);

  private AASService _service;

  this(AASService service) {
    _service = service;
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
      if (subPath == "/apps") {
        validateAuth(req, _service.config);
        if (req.method == HTTPMethod.GET) {
          res.writeJsonBody(_service.listApps(), 200);
          return;
        }
        if (req.method == HTTPMethod.POST) {
          res.writeJsonBody(_service.registerApp(req.json), 201);
          return;
        }
      }

      if (subPath.startsWith("/apps/") && req.method == HTTPMethod.GET && !subPath.endsWith(
          "/policies")) {
        validateAuth(req, _service.config);
        auto appId = secondSegment(subPath);
        res.writeJsonBody(_service.getApp(appId), 200);
        return;
      }

      if (subPath.startsWith("/apps/") && subPath.endsWith("/policies")) {
        validateAuth(req, _service.config);
        auto appId = secondSegment(subPath);
        if (req.method == HTTPMethod.GET) {
          res.writeJsonBody(_service.listPolicies(appId), 200);
          return;
        }
        if (req.method == HTTPMethod.POST) {
          res.writeJsonBody(_service.createPolicy(appId, req.json), 201);
          return;
        }
      }

      if (subPath.startsWith("/apps/")
        && subPath.endsWith("/metrics/evaluate")
        && req.method == HTTPMethod.POST) {
        validateAuth(req, _service.config);
        auto appId = secondSegment(subPath);
        res.writeJsonBody(_service.evaluate(appId, req.json, false), 200);
        return;
      }

      if (subPath.startsWith("/apps/")
        && subPath.endsWith("/metrics/evaluate/apply")
        && req.method == HTTPMethod.POST) {
        validateAuth(req, _service.config);

        auto appId = secondSegment(subPath);
        res.writeJsonBody(_service.evaluate(appId, req.json, true), 200);
        return;
      }

      if (subPath.startsWith("/cf/apps/") && subPath.endsWith("/scale") && req.method == HTTPMethod
        .POST) {
        validateAuth(req, _service.config);
        auto appId = thirdSegment(subPath);
        res.writeJsonBody(_service.triggerCFScale(appId, req.json), 202);
        return;
      }

      respondError(res, "Not found", 404);
    } catch (AASAuthorizationException e) {
      respondError(res, e.msg, 401);
    } catch (AASNotFoundException e) {
      respondError(res, e.msg, 404);
    } catch (AASValidationException e) {
      respondError(res, e.msg, 422);
    } catch (AASException e) {
      respondError(res, e.msg, 500);
    } catch (Exception e) {
      respondError(res, e.msg, 500);
    }
  }

  private string secondSegment(string path) {
    auto parts = path.split("/");
    return parts.length >= 3 ? parts[2] : "";
  }

  private string thirdSegment(string path) {
    auto parts = path.split("/");
    return parts.length >= 4 ? parts[3] : "";
  }
}
