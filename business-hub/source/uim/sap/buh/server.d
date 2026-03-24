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
  
  override void handleRequest(HTTPServerRequest req, HTTPServerResponse res) {
    super.handleRequest(req, res);

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
