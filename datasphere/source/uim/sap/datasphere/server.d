module uim.sap.datasphere.server;

import std.array : split;
import std.string : startsWith;

import vibe.data.json : Json;
import vibe.http.common : HTTPMethod;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse, HTTPServerSettings, listenHTTP;

import uim.sap.datasphere.exceptions;
import uim.sap.datasphere.service;

class DatasphereServer {
  private DatasphereService _service;

  this(DatasphereService service) {
    _service = service;
  }

  void run() {
    auto settings = new HTTPServerSettings;
    settings.port = _service.config.port;
    settings.bindAddresses = [_service.config.host];
    listenHTTP(settings, &handleRequest);
    runApplication();
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
      validateAuth(req);
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
    } catch (DatasphereAuthorizationException e) {
      respondError(res, e.msg, 401);
    } catch (DatasphereNotFoundException e) {
      respondError(res, e.msg, 404);
    } catch (DatasphereValidationException e) {
      respondError(res, e.msg, 422);
    } catch (DatasphereException e) {
      respondError(res, e.msg, 500);
    } catch (Exception e) {
      respondError(res, e.msg, 500);
    }
  }

  private void validateAuth(HTTPServerRequest req) {
    if (!_service.config.requireAuthToken)
      return;
    if (!("Authorization" in req.headers)) {
      throw new DatasphereAuthorizationException("Missing Authorization header");
    }
    auto expected = "Bearer " ~ _service.config.authToken;
    if (req.headers["Authorization"] != expected)
      throw new DatasphereAuthorizationException("Invalid token");
  }

  private string[] normalizedSegments(string subPath) {
    auto clean = subPath;
    if (clean.length > 0 && clean[0] == '/')
      clean = clean[1 .. $];
    if (clean.length > 0 && clean[$ - 1] == '/')
      clean = clean[0 .. $ - 1];
    if (clean.length == 0)
      return [];
    return clean.split("/");
  }

  private void respondError(HTTPServerResponse res, string message, int statusCode) {
    Json payload = Json.emptyObject;
    payload["success"] = false;
    payload["message"] = message;
    payload["statusCode"] = statusCode;
    res.writeJsonBody(payload, statusCode);
  }
}
