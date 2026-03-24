/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.sdi.server;

import uim.sap.sdi;

mixin(ShowModule!());

@safe:

class SDIServer : SAPServer {
  mixin(SAPServerTemplate!SDIServer);
  
  private SDIService _service;

  this(SDIService service) {
    _service = service;
  }

  private void handleRequest(HTTPServerRequest req, HTTPServerResponse res) {
    foreach (key, value; _service.config.customHeaders)
      res.headers[key] = value;

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
      validateAuth(req, _service.config);

      auto segments = normalizedSegments(subPath);
      if (segments.length >= 3 && segments[0] == "v1" && segments[1] == "tenants") {
        auto tenantId = segments[2];

        if (segments.length == 4 && segments[3] == "sites") {
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listSiteTiles(tenantId), 200);
            return;
          }
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.createSite(tenantId, req.json), 200);
            return;
          }
        }

        if (segments.length == 5 && segments[3] == "sites") {
          auto siteId = segments[4];
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.getSite(tenantId, siteId), 200);
            return;
          }
          if (req.method == HTTPMethod.DELETE) {
            res.writeJsonBody(_service.deleteSite(tenantId, siteId), 200);
            return;
          }
        }

        if (segments.length == 6 && segments[3] == "sites") {
          auto siteId = segments[4];
          auto action = segments[5];

          if (action == "import" && req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.importSite(tenantId, siteId, req.json), 200);
            return;
          }
          if (action == "export" && req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.exportSite(tenantId, siteId), 200);
            return;
          }
          if (action == "alias" && req.method == HTTPMethod.PUT) {
            res.writeJsonBody(_service.updateAlias(tenantId, siteId, req.json), 200);
            return;
          }
          if (action == "default" && req.method == HTTPMethod.PUT) {
            res.writeJsonBody(_service.setDefaultSite(tenantId, siteId), 200);
            return;
          }
          if (action == "settings") {
            if (req.method == HTTPMethod.GET) {
              res.writeJsonBody(_service.getSiteSettings(tenantId, siteId), 200);
              return;
            }
            if (req.method == HTTPMethod.PUT) {
              res.writeJsonBody(_service.updateSiteSettings(tenantId, siteId, req.json), 200);
              return;
            }
          }
          if (action == "roles" && req.method == HTTPMethod.PUT) {
            res.writeJsonBody(_service.assignRoles(tenantId, siteId, req.json), 200);
            return;
          }
        }

        if (segments.length == 7 && segments[3] == "sites" && segments[5] == "runtime" && segments[6] == "open" && req
          .method == HTTPMethod.POST) {
          auto siteId = segments[4];
          res.writeJsonBody(_service.openRuntimeSite(tenantId, siteId), 200);
          return;
        }
      }

      respondError(res, "Not found", 404);
    } catch (SDIAuthorizationException e) {
      respondError(res, e.msg, 401);
    } catch (SDINotFoundException e) {
      respondError(res, e.msg, 404);
    } catch (SDIValidationException e) {
      respondError(res, e.msg, 422);
    } catch (SDIException e) {
      respondError(res, e.msg, 500);
    } catch (Exception e) {
      respondError(res, e.msg, 500);
    }
  }
}
