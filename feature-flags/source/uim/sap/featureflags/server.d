/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.featureflags.server;

import uim.sap.featureflags;

mixin(ShowModule!());

@safe:

/**
 * FFLServer handles HTTP requests and routes them to the Feature Flags service.
 *
 * Platform:
 * - GET  /health                                              Health check
 * - GET  /ready                                               Readiness check
 *
 * Flags CRUD:
 * - POST   /v1/tenants/{tenantId}/flags                      Create flag
 * - GET    /v1/tenants/{tenantId}/flags                       List flags
 * - GET    /v1/tenants/{tenantId}/flags/{flagName}            Get flag
 * - PUT    /v1/tenants/{tenantId}/flags/{flagName}            Update flag
 * - DELETE /v1/tenants/{tenantId}/flags/{flagName}            Delete flag
 * - POST   /v1/tenants/{tenantId}/flags/{flagName}/toggle     Toggle on/off
 *
 * Evaluation:
 * - GET    /v1/tenants/{tenantId}/flags/{flagName}/evaluate   Evaluate flag
 *          ?identifier=<value>                                (optional query param)
 *
 * Export / Import:
 * - GET    /v1/tenants/{tenantId}/export                      Export all flags
 * - POST   /v1/tenants/{tenantId}/import                      Import flags
 *
 * Dashboard:
 * - GET    /v1/tenants/{tenantId}/dashboard                   Dashboard metrics
 */
class FFLServer : SAPServer {
  mixin(SAPServerTemplate!FFLServer);

  private FFLService _service;

  this(FFLService service) {
    _service = service;
  }

  override void handleRequest(HTTPServerRequest req, HTTPServerResponse res) {
    super.handleRequest(req, res);

    try {
      validateAuth(req, _service.config);

      auto segments = normalizedSegments(subPath);

      // All business routes are under /v1/tenants/{tenantId}/...
      if (segments.length >= 3 && segments[0] == "v1" && segments[1] == "tenants") {
        auto tenantId = segments[2];

        // --- Flags collection ---
        // POST /v1/tenants/{tenantId}/flags
        // GET  /v1/tenants/{tenantId}/flags
        if (segments.length == 4 && segments[3] == "flags") {
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.createFlag(tenantId, req.json), 201);
            return;
          }
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listFlags(tenantId), 200);
            return;
          }
        }

        // --- Single flag ---
        // GET    /v1/tenants/{tenantId}/flags/{flagName}
        // PUT    /v1/tenants/{tenantId}/flags/{flagName}
        // DELETE /v1/tenants/{tenantId}/flags/{flagName}
        if (segments.length == 5 && segments[3] == "flags") {
          auto flagName = segments[4];
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.getFlag(tenantId, flagName), 200);
            return;
          }
          if (req.method == HTTPMethod.PUT) {
            res.writeJsonBody(_service.updateFlag(tenantId, flagName, req.json), 200);
            return;
          }
          if (req.method == HTTPMethod.DELETE) {
            res.writeJsonBody(_service.deleteFlag(tenantId, flagName), 200);
            return;
          }
        }

        // --- Flag actions ---
        if (segments.length == 6 && segments[3] == "flags") {
          auto flagName = segments[4];

          // POST /v1/tenants/{tenantId}/flags/{flagName}/toggle
          if (segments[5] == "toggle" && req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.toggleFlag(tenantId, flagName), 200);
            return;
          }

          // GET /v1/tenants/{tenantId}/flags/{flagName}/evaluate?identifier=...
          if (segments[5] == "evaluate" && req.method == HTTPMethod.GET) {
            string identifier = "";
            if ("identifier" in req.query) {
              identifier = req.query["identifier"];
            }
            res.writeJsonBody(_service.evaluateFlag(tenantId, flagName, identifier), 200);
            return;
          }
        }

        // --- Export ---
        // GET /v1/tenants/{tenantId}/export
        if (segments.length == 4 && segments[3] == "export" && req.method == HTTPMethod.GET) {
          res.writeJsonBody(_service.exportFlags(tenantId), 200);
          return;
        }

        // --- Import ---
        // POST /v1/tenants/{tenantId}/import
        if (segments.length == 4 && segments[3] == "import" && req.method == HTTPMethod.POST) {
          res.writeJsonBody(_service.importFlags(tenantId, req.json), 200);
          return;
        }

        // --- Dashboard ---
        // GET /v1/tenants/{tenantId}/dashboard
        if (segments.length == 4 && segments[3] == "dashboard" && req.method == HTTPMethod.GET) {
          res.writeJsonBody(_service.dashboard(tenantId), 200);
          return;
        }
      }

      respondError(res, "Not found", 404);
    } catch (FFLAuthorizationException e) {
      respondError(res, e.msg, 401);
    } catch (FFLNotFoundException e) {
      respondError(res, e.msg, 404);
    } catch (FFLValidationException e) {
      respondError(res, e.msg, 422);
    } catch (FFLException e) {
      respondError(res, e.msg, 500);
    } catch (Exception e) {
      respondError(res, e.msg, 500);
    }
  }
}
