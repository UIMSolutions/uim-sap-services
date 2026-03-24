/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.datasphere.server;

import uim.sap.datasphere;

mixin(ShowModule!());

@safe:

/**
  * DSPServer is the main HTTP server for the DataSphere service. It listens for incoming requests and routes them to the appropriate service methods based on the URL path and HTTP method.
  * The server also handles authentication if enabled in the configuration, and adds any custom headers specified in the configuration to each response.
  * It defines endpoints for health checks, tenant administration, data modeling, business modeling, integration, spaces, security, governance, and consumption.
  *
  * The handleRequest method parses the incoming request, validates authentication, and dispatches to the correct service method based on the URL path segments. It also handles errors and returns appropriate HTTP status codes and messages.
  *
  * The validateAuth method checks for the presence of an Authorization header and validates the token if token-based authentication is enabled in the configuration.
  * The normalizedSegments method cleans and splits the URL path into segments for easier routing.
  * The respondError method is a helper for sending JSON error responses with a consistent structure.
  *
  * Note: This server implementation is basic and may not be suitable for production use without additional features such as logging, metrics, CORS handling, rate limiting, etc.
  */
class DSPServer : SAPServer {
  mixin(SAPServerTemplate!DSPServer);

  private DSPService _service;

  this(DSPService service) {
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
      validateAuth(req, _service.config);
      auto segments = normalizedSegments(subPath);

      if (segments.length == 3 && segments[0] == "v1" && segments[1] == "admin" && segments[2] == "tenant") {
        if (req.method == HTTPMethod.GET) {
          res.writeJsonBody(_service.getTenantAdminState(), 200);
          return;
        }
        if (req.method == HTTPMethod.PUT) {
          res.writeJsonBody(_service.upsertTenantAdminState(req.json), 200);
          return;
        }
      }

      if (segments.length >= 3 && segments[0] == "v1" && segments[1] == "tenants") {
        auto tenantId = segments[2];

        if (segments.length == 5 && segments[3] == "modeling" && segments[4] == "data-models") {
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.createDataModel(tenantId, req.json), 200);
            return;
          }
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listDataModels(tenantId), 200);
            return;
          }
        }

        if (
          segments.length == 5 &&
          segments[3] == "modeling" &&
          segments[4] == "external-datasets" &&
          req.method == HTTPMethod.POST
          ) {
          res.writeJsonBody(_service.createExternalDataset(tenantId, req.json), 200);
          return;
        }

        if (
          segments.length == 5 &&
          segments[3] == "modeling" &&
          segments[4] == "data-flows" &&
          req.method == HTTPMethod.POST
          ) {
          res.writeJsonBody(_service.runDataFlow(tenantId, req.json), 200);
          return;
        }

        if (
          segments.length == 5 &&
          segments[3] == "modeling" &&
          segments[4] == "replications" &&
          req.method == HTTPMethod.POST
          ) {
          res.writeJsonBody(_service.replicateModel(tenantId, req.json), 200);
          return;
        }

        if (segments.length == 5 && segments[3] == "business-modeling" && segments[4] == "models") {
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.createBusinessModel(tenantId, req.json), 200);
            return;
          }
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listBusinessModels(tenantId), 200);
            return;
          }
        }

        if (
          segments.length == 7 &&
          segments[3] == "business-modeling" &&
          segments[4] == "models" &&
          segments[6] == "preview" &&
          req.method == HTTPMethod.POST
          ) {
          res.writeJsonBody(_service.previewBusinessModel(tenantId, segments[5]), 200);
          return;
        }

        if (segments.length == 5 && segments[3] == "integration" && segments[4] == "connections") {
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.createConnection(tenantId, req.json), 200);
            return;
          }
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listConnections(tenantId), 200);
            return;
          }
        }

        if (
          segments.length == 5 &&
          segments[3] == "integration" &&
          segments[4] == "migrations" &&
          req.method == HTTPMethod.POST
          ) {
          res.writeJsonBody(_service.migrateTrustedModels(tenantId, req.json), 200);
          return;
        }

        if (segments.length == 4 && segments[3] == "spaces") {
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.createSpace(tenantId, req.json), 200);
            return;
          }
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listSpaces(tenantId), 200);
            return;
          }
        }

        if (segments.length == 5 && segments[3] == "spaces" && req.method == HTTPMethod.PUT) {
          res.writeJsonBody(_service.updateSpace(tenantId, segments[4], req.json), 200);
          return;
        }

        if (
          segments.length == 6 &&
          segments[3] == "spaces" &&
          segments[5] == "users" &&
          req.method == HTTPMethod.POST
          ) {
          res.writeJsonBody(_service.addSpaceUser(tenantId, segments[4], req.json), 200);
          return;
        }

        if (
          segments.length == 7 &&
          segments[3] == "security" &&
          segments[4] == "functional-access" &&
          req.method == HTTPMethod.PUT
          ) {
          res.writeJsonBody(_service.setFunctionalAccess(tenantId, segments[5], req.json), 200);
          return;
        }

        if (
          segments.length == 7 &&
          segments[3] == "security" &&
          segments[4] == "space-access" &&
          req.method == HTTPMethod.PUT
          ) {
          res.writeJsonBody(_service.setSpaceAccess(tenantId, segments[5], req.json), 200);
          return;
        }

        if (segments.length == 7 && segments[3] == "security" && segments[4] == "row-policies") {
          if (req.method == HTTPMethod.PUT) {
            res.writeJsonBody(_service.upsertRowPolicy(tenantId, segments[5], req.json), 200);
            return;
          }
        }

        if (
          segments.length == 6 &&
          segments[3] == "security" &&
          segments[4] == "row-policies" &&
          req.method == HTTPMethod.GET
          ) {
          res.writeJsonBody(_service.listRowPolicies(tenantId), 200);
          return;
        }

        if (segments.length == 6 && segments[3] == "security" && segments[4] == "audit") {
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.addAuditEvent(tenantId, req.json), 200);
            return;
          }
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listAuditEvents(tenantId), 200);
            return;
          }
        }

        if (
          segments.length == 6 &&
          segments[3] == "governance" &&
          segments[4] == "catalog" &&
          segments[5] == "assets"
          ) {
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.publishCatalogAsset(tenantId, req.json), 200);
            return;
          }
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listCatalogAssets(tenantId), 200);
            return;
          }
        }

        if (
          segments.length == 6 &&
          segments[3] == "governance" &&
          segments[4] == "glossary" &&
          segments[5] == "terms"
          ) {
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.createGlossaryTerm(tenantId, req.json), 200);
            return;
          }
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listGlossaryTerms(tenantId), 200);
            return;
          }
        }

        if (
          segments.length == 6 &&
          segments[3] == "governance" &&
          segments[4] == "kpis" &&
          segments[5] == "definitions"
          ) {
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.createKPI(tenantId, req.json), 200);
            return;
          }
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listKPIs(tenantId), 200);
            return;
          }
        }

        if (
          segments.length == 5 &&
          segments[3] == "consumption" &&
          segments[4] == "connectors" &&
          req.method == HTTPMethod.GET
          ) {
          res.writeJsonBody(_service.listConsumptionConnectors(tenantId), 200);
          return;
        }

        if (
          segments.length == 6 &&
          segments[3] == "consumption" &&
          segments[4] == "odata" &&
          req.method == HTTPMethod.GET
          ) {
          res.writeJsonBody(_service.odataEntity(tenantId, segments[5]), 200);
          return;
        }
      }

      respondError(res, "Not found", 404);
    } catch (DSPAuthorizationException e) {
      respondError(res, e.msg, 401);
    } catch (DSPNotFoundException e) {
      respondError(res, e.msg, 404);
    } catch (DSPValidationException e) {
      respondError(res, e.msg, 422);
    } catch (DSPException e) {
      respondError(res, e.msg, 500);
    } catch (Exception e) {
      respondError(res, e.msg, 500);
    }
  }
}
