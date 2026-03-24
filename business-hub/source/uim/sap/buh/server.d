/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.buh.server;

import uim.sap.buh;

mixin(ShowModule!());

@safe:

class BUHServer : SAPServer {
  mixin(SAPServerTemplate!BUHServer);

  private BUHService _service;

  this(BUHService service) {
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
      if (subPath == "/catalog/apis") {
        validateAuth(req, _service.config);
        if (req.method == HTTPMethod.GET) {
          res.writeJsonBody(_service.listApis(), 200);
          return;
        }
        if (req.method == HTTPMethod.POST) {
          res.writeJsonBody(_service.createApi(req.json), 201);
          return;
        }
      }

      if (subPath.startsWith("/catalog/apis/") && req.method == HTTPMethod.GET) {
        validateAuth(req, _service.config);
        auto id = lastSegment(subPath);
        res.writeJsonBody(_service.getApi(id), 200);
        return;
      }

      if (subPath == "/catalog/products") {
        validateAuth(req, _service.config);
         if (req.method == HTTPMethod.GET) {
          res.writeJsonBody(_service.listProducts(), 200);
          return;
        }
        if (req.method == HTTPMethod.GET) {
          res.writeJsonBody(_service.listProducts(), 200);
          return;
        }
        if (req.method == HTTPMethod.POST) {
          res.writeJsonBody(_service.createProduct(req.json), 201);
          return;
        }
      }

      if (subPath == "/subscriptions") {
        validateAuth(req, _service.config);
        if (req.method == HTTPMethod.GET) {
          res.writeJsonBody(_service.listSubscriptions(), 200);
          return;
        }
        if (req.method == HTTPMethod.POST) {
          res.writeJsonBody(_service.createSubscription(req.json), 201);
          return;
        }
      }

      respondError(res, "Not found", 404);
    } catch (BUHAuthorizationException e) {
      respondError(res, e.msg, 401);
    } catch (BUHNotFoundException e) {
      respondError(res, e.msg, 404);
    } catch (BUHValidationException e) {
      respondError(res, e.msg, 422);
    } catch (BUHException e) {
      respondError(res, e.msg, 500);
    } catch (Exception e) {
      respondError(res, e.msg, 500);
    }
  }

  private string lastSegment(string path) {
    auto parts = path.split("/");
    if (parts.length == 0) {
      return "";
    }
    return parts[$ - 1];
  }
}
