/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.cps.server;

import uim.sap.cps;

mixin(ShowModule!());

@safe:

class CPSServer : SAPServer {
  mixin(SAPServerTemplate!CPSServer);

  private CPSService _service;

  this(CPSService service) {
    _service = service;
  }

  override void handleRequest(HTTPServerRequest req, HTTPServerResponse res) {
    super.handleRequest(req, res);

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

        if (segments.length == 5 && segments[3] == "navigation" && segments[4] == "resolve" && req.method == HTTPMethod
          .POST) {
          res.writeJsonBody(_service.resolveNavigation(tenantId, req.json), 200);
          return;
        }

        if (segments.length == 4 && segments[3] == "entrypoints" && req.method == HTTPMethod.GET) {
          res.writeJsonBody(_service.listEntryPoints(tenantId), 200);
          return;
        }

        if (segments.length == 5 && segments[3] == "admin" && segments[4] == "site-tools") {
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.getSiteAdministration(tenantId), 200);
            return;
          }
          if (req.method == HTTPMethod.PUT) {
            res.writeJsonBody(_service.upsertSiteAdministration(tenantId, req.json), 200);
            return;
          }
        }

        if (segments.length == 5 && segments[3] == "content") {
          auto contentType = segments[4];
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listContent(tenantId, contentType), 200);
            return;
          }
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.upsertContent(tenantId, contentType, req.json), 200);
            return;
          }
        }

        if (segments.length == 5 && segments[3] == "launchpad" && segments[4] == "modules") {
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listLaunchpadModules(tenantId), 200);
            return;
          }
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.upsertLaunchpadModule(tenantId, req.json), 200);
            return;
          }
        }

        if (segments.length == 5 && segments[3] == "providers") {
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listProviders(tenantId), 200);
            return;
          }
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.upsertProvider(tenantId, req.json), 200);
            return;
          }
        }

        if (segments.length == 6 && segments[3] == "providers" && segments[5] == "consume" && req.method == HTTPMethod
          .POST) {
          auto providerId = segments[4];
          res.writeJsonBody(_service.consumeProvider(tenantId, providerId), 200);
          return;
        }
      }

      respondError(res, "Not found", 404);
    } catch (CPSAuthorizationException e) {
      respondError(res, e.msg, 401);
    } catch (CPSNotFoundException e) {
      respondError(res, e.msg, 404);
    } catch (CPSValidationException e) {
      respondError(res, e.msg, 422);
    } catch (CPSException e) {
      respondError(res, e.msg, 500);
    } catch (Exception e) {
      respondError(res, e.msg, 500);
    }
  }
}
