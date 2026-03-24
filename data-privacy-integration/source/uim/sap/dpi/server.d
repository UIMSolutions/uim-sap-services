/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.dpi.server;

import uim.sap.dpi;

mixin(ShowModule!());

@safe:


class DPIServer : SAPServer {
  mixin(SAPServerTemplate!DPIServer);

  private DPIService _service;

  this(DPIService service) {
    _service = service;
  }

  override void handleRequest(HTTPServerRequest req, HTTPServerResponse res) {
    super.handleRequest(req, res);

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
}
