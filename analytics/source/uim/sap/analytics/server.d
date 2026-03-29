/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.analytics.server;

import uim.sap.analytics;

mixin(ShowModule!());

@safe:

class AnalyticsServer : SAPServer {
  mixin(SAPServerTemplate!AnalyticsServer);

  protected AnalyticsService _service;

  this(AnalyticsService service) {
    _service = service;
  }

  override void handleRequest(HTTPServerRequest req, HTTPServerResponse res) {
    super.handleRequest(req, res);

    try {
      validateAuth(req, _service.config);

      auto segments = normalizedSegments(subPath);

      // ── Tenant-scoped routes: /v1/tenants/{tenant_id}/... ──

      if (segments.length >= 3 && segments[0] == "v1" && segments[1] == "tenants") {
        auto tenantId = segments[2];

        // ── Stories ──
        if (segments.length == 4 && segments[3] == "stories") {
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listStories(tenantId), 200);
            return;
          }
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.createStory(tenantId, req.json), 201);
            return;
          }
        }

        if (segments.length == 5 && segments[3] == "stories") {
          auto storyId = segments[4];
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.getStory(tenantId, storyId), 200);
            return;
          }
          if (req.method == HTTPMethod.PUT) {
            res.writeJsonBody(_service.updateStory(tenantId, storyId, req.json), 200);
            return;
          }
          if (req.method == HTTPMethod.DELETE) {
            res.writeJsonBody(_service.deleteStory(tenantId, storyId), 200);
            return;
          }
        }

        // ── Dashboards ──
        if (segments.length == 4 && segments[3] == "dashboards") {
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listDashboards(tenantId), 200);
            return;
          }
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.createDashboard(tenantId, req.json), 201);
            return;
          }
        }

        if (segments.length == 5 && segments[3] == "dashboards") {
          auto dashboardId = segments[4];
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.getDashboard(tenantId, dashboardId), 200);
            return;
          }
          if (req.method == HTTPMethod.PUT) {
            res.writeJsonBody(_service.updateDashboard(tenantId, dashboardId, req.json), 200);
            return;
          }
          if (req.method == HTTPMethod.DELETE) {
            res.writeJsonBody(_service.deleteDashboard(tenantId, dashboardId), 200);
            return;
          }
        }

        // ── Datasets ──
        if (segments.length == 4 && segments[3] == "datasets") {
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listDatasets(tenantId), 200);
            return;
          }
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.createDataset(tenantId, req.json), 201);
            return;
          }
        }

        if (segments.length == 5 && segments[3] == "datasets") {
          auto datasetId = segments[4];
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.getDataset(tenantId, datasetId), 200);
            return;
          }
          if (req.method == HTTPMethod.DELETE) {
            res.writeJsonBody(_service.deleteDataset(tenantId, datasetId), 200);
            return;
          }
        }

        // ── Data Models ──
        if (segments.length == 4 && segments[3] == "models") {
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listModels(tenantId), 200);
            return;
          }
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.createModel(tenantId, req.json), 201);
            return;
          }
        }

        if (segments.length == 5 && segments[3] == "models") {
          auto modelId = segments[4];
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.getModel(tenantId, modelId), 200);
            return;
          }
          if (req.method == HTTPMethod.DELETE) {
            res.writeJsonBody(_service.deleteModel(tenantId, modelId), 200);
            return;
          }
        }

        // ── Connections ──
        if (segments.length == 4 && segments[3] == "connections") {
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listConnections(tenantId), 200);
            return;
          }
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.createConnection(tenantId, req.json), 201);
            return;
          }
        }

        if (segments.length == 5 && segments[3] == "connections") {
          auto connectionId = segments[4];
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.getConnection(tenantId, connectionId), 200);
            return;
          }
          if (req.method == HTTPMethod.DELETE) {
            res.writeJsonBody(_service.deleteConnection(tenantId, connectionId), 200);
            return;
          }
        }

        if (segments.length == 6 && segments[3] == "connections" && segments[5] == "test") {
          auto connectionId = segments[4];
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.testConnection(tenantId, connectionId), 200);
            return;
          }
        }

        // ── Plans ──
        if (segments.length == 4 && segments[3] == "plans") {
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listPlans(tenantId), 200);
            return;
          }
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.createPlan(tenantId, req.json), 201);
            return;
          }
        }

        if (segments.length == 5 && segments[3] == "plans") {
          auto planId = segments[4];
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.getPlan(tenantId, planId), 200);
            return;
          }
          if (req.method == HTTPMethod.PUT) {
            res.writeJsonBody(_service.updatePlan(tenantId, planId, req.json), 200);
            return;
          }
          if (req.method == HTTPMethod.DELETE) {
            res.writeJsonBody(_service.deletePlan(tenantId, planId), 200);
            return;
          }
        }

        // ── Scenarios (What-If Simulation) ──
        if (segments.length == 5
          && segments[3] == "scenarios"
          && segments[4] == "simulate"
          && req.method == HTTPMethod.POST) {
          res.writeJsonBody(_service.simulateScenario(tenantId, req.json), 200);
          return;
        }

        // ── Predictions / Smart / AutoML ──
        if (segments.length == 4 && segments[3] == "predictions") {
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listPredictions(tenantId), 200);
            return;
          }
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.createPrediction(tenantId, req.json), 201);
            return;
          }
        }

        if (segments.length == 5 && segments[3] == "predictions") {
          auto predictionId = segments[4];
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.getPrediction(tenantId, predictionId), 200);
            return;
          }
        }

        // ── Ad-Hoc Analysis ──
        if (segments.length == 5
          && segments[3] == "analysis"
          && segments[4] == "query"
          && req.method == HTTPMethod.POST) {
          res.writeJsonBody(_service.queryAnalysis(tenantId, req.json), 200);
          return;
        }

        // ── Users (Administration) ──
        if (segments.length == 4 && segments[3] == "users") {
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listUsers(tenantId), 200);
            return;
          }
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.createUser(tenantId, req.json), 201);
            return;
          }
        }

        if (segments.length == 5 && segments[3] == "users") {
          auto userId = segments[4];
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.getUser(tenantId, userId), 200);
            return;
          }
          if (req.method == HTTPMethod.PUT) {
            res.writeJsonBody(_service.updateUser(tenantId, userId, req.json), 200);
            return;
          }
          if (req.method == HTTPMethod.DELETE) {
            res.writeJsonBody(_service.deleteUser(tenantId, userId), 200);
            return;
          }
        }

        // ── Tenant Overview (Administration) ──
        if (segments.length == 4
          && segments[3] == "overview"
          && req.method == HTTPMethod.GET) {
          res.writeJsonBody(_service.tenantOverview(tenantId), 200);
          return;
        }

        // ── Mobile Access ──
        if (segments.length == 4
          && segments[3] == "mobile"
          && req.method == HTTPMethod.GET) {
          res.writeJsonBody(_service.mobileAccess(tenantId), 200);
          return;
        }

        // ── SAP Datasphere Integration ──
        if (segments.length == 4
          && segments[3] == "datasphere"
          && req.method == HTTPMethod.GET) {
          res.writeJsonBody(_service.datasphereStatus(tenantId), 200);
          return;
        }

        // ── Embedding ──
        if (segments.length == 6
          && segments[3] == "embed"
          && req.method == HTTPMethod.GET) {
          auto resourceType = segments[4];
          auto resourceId = segments[5];
          res.writeJsonBody(_service.getEmbedInfo(tenantId, resourceType, resourceId), 200);
          return;
        }
      }

      respondError(res, "Not found", 404);
    } catch (AnalyticsAuthorizationException e) {
      respondError(res, e.msg, 401);
    } catch (AnalyticsNotFoundException e) {
      respondError(res, e.msg, 404);
    } catch (AnalyticsValidationException e) {
      respondError(res, e.msg, 422);
    } catch (AnalyticsException e) {
      respondError(res, e.msg, 500);
    } catch (Exception e) {
      respondError(res, e.msg, 500);
    }
  }
}
