module uim.sap.mdg.server;

import uim.sap.mdg;

mixin(ShowModule!());

@safe:

class MDGServer : SAPServer {
  mixin(SAPServerTemplate!MDGServer);

  private MDGService _service;

  this(MDGService service) {
    _service = service;
  }

  override void handleRequest(HTTPServerRequest req, HTTPServerResponse res) {
    super.handleRequest(req, res);

    try {
      validateAuth(req, _service.config);

      auto segments = normalizedSegments(subPath);
      if (segments.length >= 3 && segments[0] == "v1" && segments[1] == "tenants") {
        auto tenantId = segments[2];

        if (segments.length == 4 && segments[3] == "business-partners") {
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listBusinessPartners(tenantId), 200);
            return;
          }
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.upsertBusinessPartner(tenantId, req.json), 200);
            return;
          }
        }

        if (segments.length == 5 && segments[3] == "business-partners" && segments[4] == "batch" && req.method == HTTPMethod
          .POST) {
          res.writeJsonBody(_service.upsertBusinessPartnersBatch(tenantId, req.json), 200);
          return;
        }

        if (segments.length == 5 && segments[3] == "business-partners") {
          auto bpId = segments[4];
          if (req.method == HTTPMethod.PATCH) {
            res.writeJsonBody(_service.updateWorkflowState(tenantId, bpId, req.json), 200);
            return;
          }
        }

        if (segments.length == 5 && segments[3] == "consolidation" && segments[4] == "ingest" && req.method == HTTPMethod
          .POST) {
          res.writeJsonBody(_service.ingestBusinessPartners(tenantId, req.json), 200);
          return;
        }

        if (segments.length == 5 && segments[3] == "consolidation" && segments[4] == "duplicates" && req.method == HTTPMethod
          .GET) {
          res.writeJsonBody(_service.detectDuplicates(tenantId), 200);
          return;
        }

        if (segments.length == 5 && segments[3] == "consolidation" && segments[4] == "merge" && req.method == HTTPMethod
          .POST) {
          res.writeJsonBody(_service.mergeDuplicates(tenantId, req.json), 200);
          return;
        }

        if (segments.length == 4 && segments[3] == "quality-rules") {
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listRules(tenantId), 200);
            return;
          }
        }

        if (segments.length == 5 && segments[3] == "quality-rules" && req.method == HTTPMethod.PUT) {
          auto ruleId = segments[4];
          res.writeJsonBody(_service.upsertRule(tenantId, ruleId, req.json), 200);
          return;
        }

        if (segments.length == 5 && segments[3] == "quality" && segments[4] == "evaluate" && req.method == HTTPMethod
          .POST) {
          res.writeJsonBody(_service.evaluateDataQuality(tenantId), 200);
          return;
        }
      }

      respondError(res, "Not found", 404);
    } catch (MDGAuthorizationException e) {
      respondError(res, e.msg, 401);
    } catch (MDGNotFoundException e) {
      respondError(res, e.msg, 404);
    } catch (MDGValidationException e) {
      respondError(res, e.msg, 422);
    } catch (MDGException e) {
      respondError(res, e.msg, 500);
    } catch (Exception e) {
      respondError(res, e.msg, 500);
    }
  }
}
