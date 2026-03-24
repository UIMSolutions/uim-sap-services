/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.clg.server;

import uim.sap.clg;

mixin(ShowModule!());

@safe:

class CLGServer : SAPServer {
  mixin(SAPServerTemplate!CLGServer);

  private CLGService _service;

  this(CLGService service) {
    _service = service;
  }

  override void handleRequest(HTTPServerRequest req, HTTPServerResponse res) {
  super.handleRequest(req, res);



    if (!path.startsWith(basePath)) {
      respondError(res, "Not found", 404);
      return;
    }

    if (path.endsWith("/health") && req.method == HTTPMethod.GET) {
      res.statusCode = 200;
      res.writeJsonBody(_service.health());
      return;
    }

    if (path.endsWith("/ready") && req.method == HTTPMethod.GET) {
      res.statusCode = 200;
      res.writeJsonBody(_service.ready());
      return;
    }

    if (path.endsWith("/metrics") && req.method == HTTPMethod.GET) {
      res.statusCode = 200;
      res.writeJsonBody(_service.metrics());
      return;
    }

    if (path.endsWith("/logs") && req.method == HTTPMethod.POST) {
      handleAuthorizedRequest(req, res, (body) => _service.ingest(body));
      return;
    }

    if (path.endsWith("/logs/batch") && req.method == HTTPMethod.POST) {
      handleAuthorizedRequest(req, res, (body) => _service.ingestBatch(body));
      return;
    }

    if (path.endsWith("/logs/query") && req.method == HTTPMethod.POST) {
      handleAuthorizedRequest(req, res, (body) => _service.query(body));
      return;
    }

    respondError(res, "Not found", 404);
  }

  private void handleAuthorizedRequest(
    HTTPServerRequest req,
    HTTPServerResponse res,
    Json delegate(Json) @safe action
  ) {
    try {
      validateAuth(req, _service.config);
      auto input = req.json;
      auto output = action(input);
      res.statusCode = 200;
      res.writeJsonBody(output);
    } catch (CLGAuthorizationException e) {
      respondError(res, e.msg, 401);
    } catch (CLGLogValidationException e) {
      respondError(res, e.msg, 422);
    } catch (CLGException e) {
      respondError(res, e.msg, 500);
    } catch (Exception e) {
      respondError(res, e.msg, 500);
    }
  }
}
