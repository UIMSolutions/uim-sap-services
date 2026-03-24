/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.smg.server;

import uim.sap.smg;

mixin(ShowModule!());

@safe:
class SMGServer : SAPServer {
  mixin(SAPServerTemplate!SMGServer);

  private SMGService _service;

  this(SMGService service) {
    _service = service;
  }

  override void handleRequest(HTTPServerRequest req, HTTPServerResponse res) {
    super.handleRequest(req, res);


    if (subPath == "/health" && req.method == HTTPMethod.GET) {
      res.writeJsonBody(_service.health(), 200);
      return;
    }

    if (subPath == "/ready" && req.method == HTTPMethod.GET) {
      res.writeJsonBody(_service.ready(), 200);
      return;
    }

    try {
      validateAuth(req, _service.config);

      auto segments = normalizedSegments(subPath);
      if (segments.length >= 3 && segments[0] == "v1" && segments[1] == "tenants") {
        auto tenantId = segments[2];

        if (segments.length == 4 && segments[3] == "sites") {
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listSites(tenantId), 200);
            return;
          }
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.upsertSite(tenantId, req.json), 200);
            return;
          }
        }

        if (segments.length == 5 && segments[3] == "sites") {
          auto siteId = segments[4];
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.getSite(tenantId, siteId), 200);
            return;
          }
          if (req.method == HTTPMethod.PUT) {
            Json payload = req.json;
            payload["site_id"] = siteId;
            res.writeJsonBody(_service.upsertSite(tenantId, payload), 200);
            return;
          }
          if (req.method == HTTPMethod.DELETE) {
            res.writeJsonBody(_service.deleteSite(tenantId, siteId), 200);
            return;
          }
        }

        if (segments.length == 5 && segments[3] == "subaccount" && segments[4] == "settings") {
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.getSubaccountSettings(tenantId), 200);
            return;
          }
          if (req.method == HTTPMethod.PUT) {
            res.writeJsonBody(_service.upsertSubaccountSettings(tenantId, req.json), 200);
            return;
          }
        }
      }

      respondError(res, "Not found", 404);
    } catch (SMGAuthorizationException e) {
      respondError(res, e.msg, 401);
    } catch (SMGNotFoundException e) {
      respondError(res, e.msg, 404);
    } catch (SMGValidationException e) {
      respondError(res, e.msg, 422);
    } catch (SMGException e) {
      respondError(res, e.msg, 500);
    } catch (Exception e) {
      respondError(res, e.msg, 500);
    }
  }
}
