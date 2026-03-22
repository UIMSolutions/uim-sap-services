module uim.sap.integrationsuite.server;

import uim.sap.integrationsuite;

mixin(ShowModule!());

@safe:

/**
 * INTServer — HTTP front-end for the Integration Suite service.
 *
 * Routes are organised under `/api/is/v1/tenants/{tenantId}/...`
 */
class INTServer : SAPServer {
  private INTService _service;

  this(INTService service) {
    _service = service;
  }

  void run() {
    auto settings = new HTTPServerSettings;
    settings.port = _service.config.port;
    settings.bindAddresses = [_service.config.host];
    listenHTTP(settings, &handleRequest);
    runApplication();
  }

  // ---- request dispatcher ----

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

    // --- Platform ---
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

      // All business routes: /v1/tenants/{tenantId}/...
      if (segments.length >= 3 && segments[0] == "v1" && segments[1] == "tenants") {
        auto tenantId = segments[2];
        routeTenant(req, res, tenantId, segments[3 .. $]);
        return;
      }

      respondError(res, "Not found", 404);
    } catch (INTAuthorizationException e) {
      respondError(res, e.msg, 401);
    } catch (INTNotFoundException e) {
      respondError(res, e.msg, 404);
    } catch (INTValidationException e) {
      respondError(res, e.msg, 422);
    } catch (INTException e) {
      respondError(res, e.msg, 500);
    } catch (Exception e) {
      respondError(res, e.msg, 500);
    }
  }

  // ---- tenant sub-router ----

  private void routeTenant(
    HTTPServerRequest req,
    HTTPServerResponse res,
    UUID tenantId,
    string[] segs
  ) {
    if (segs.length == 0) {
      respondError(res, "Not found", 404);
      return;
    }

    auto resource = segs[0];
    auto rest = segs.length > 1 ? segs[1 .. $] : (string[]).init;

    switch (resource) {
      // Cloud Integration
    case "iflows":
      routeIFlows(req, res, tenantId, rest);
      return;
    case "message-logs":
      routeMessageLogs(req, res, tenantId, rest);
      return;

      // API Management
    case "api-proxies":
      routeApiProxies(req, res, tenantId, rest);
      return;
    case "api-products":
      routeApiProducts(req, res, tenantId, rest);
      return;
    case "api-policies":
      routeApiPolicies(req, res, tenantId, rest);
      return;

      // Event Management
    case "event-topics":
      routeEventTopics(req, res, tenantId, rest);
      return;
    case "event-subscriptions":
      routeEventSubscriptions(req, res, tenantId, rest);
      return;

      // Open Connectors
    case "connectors":
      routeConnectors(req, res, tenantId, rest);
      return;

      // Integration Advisor
    case "mappings":
      routeMappings(req, res, tenantId, rest);
      return;

      // Trading Partner Management
    case "trading-partners":
      routeTradingPartners(req, res, tenantId, rest);
      return;
    case "agreements":
      routeAgreements(req, res, tenantId, rest);
      return;

      // OData Provisioning
    case "odata-services":
      routeODataServices(req, res, tenantId, rest);
      return;

      // Integration Assessment
    case "assessments":
      routeAssessments(req, res, tenantId, rest);
      return;

      // Migration Assessment
    case "migrations":
      routeMigrations(req, res, tenantId, rest);
      return;

      // Hybrid Integration
    case "hybrid-runtimes":
      routeHybridRuntimes(req, res, tenantId, rest);
      return;

      // Data Space Integration
    case "data-assets":
      routeDataAssets(req, res, tenantId, rest);
      return;

      // Content Packs
    case "content-packs":
      routeContentPacks(req, res, tenantId, rest);
      return;

      // Dashboard
    case "dashboard":
      if (rest.length == 0 && req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.dashboard(tenantId), 200);
        return;
      }
      break;

    default:
      break;
    }

    respondError(res, "Not found", 404);
  }

  // ================================================================
  //  Cloud Integration — IFlows
  // ================================================================

  private void routeIFlows(
    HTTPServerRequest req, HTTPServerResponse res,
    UUID tenantId, string[] rest
  ) {
    // POST / GET  .../iflows
    if (rest.length == 0) {
      if (req.method == HTTPMethod.POST) {
        res.writeJsonBody(_service.createIFlow(tenantId, req.json), 201);
        return;
      }
      if (req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.listIFlows(tenantId), 200);
        return;
      }
    }
    // GET / DELETE  .../iflows/{id}
    if (rest.length == 1) {
      auto id = rest[0];
      if (req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.getIFlow(tenantId, id), 200);
        return;
      }
      if (req.method == HTTPMethod.DELETE) {
        res.writeJsonBody(_service.deleteIFlow(tenantId, id), 200);
        return;
      }
    }
    // POST .../iflows/{id}/deploy
    if (rest.length == 2 && rest[1] == "deploy" && req.method == HTTPMethod.POST) {
      res.writeJsonBody(_service.deployIFlow(tenantId, rest[0]), 200);
      return;
    }
    respondError(res, "Not found", 404);
  }

  // ================================================================
  //  Cloud Integration — Message Logs
  // ================================================================

  private void routeMessageLogs(
    HTTPServerRequest req, HTTPServerResponse res,
    UUID tenantId, string[] rest
  ) {
    if (rest.length == 0) {
      if (req.method == HTTPMethod.POST) {
        res.writeJsonBody(_service.createMessageLog(tenantId, req.json), 201);
        return;
      }
      if (req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.listMessageLogs(tenantId), 200);
        return;
      }
    }
    respondError(res, "Not found", 404);
  }

  // ================================================================
  //  API Management — Proxies
  // ================================================================

  private void routeApiProxies(
    HTTPServerRequest req, HTTPServerResponse res,
    UUID tenantId, string[] rest
  ) {
    if (rest.length == 0) {
      if (req.method == HTTPMethod.POST) {
        res.writeJsonBody(_service.createApiProxy(tenantId, req.json), 201);
        return;
      }
      if (req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.listApiProxies(tenantId), 200);
        return;
      }
    }
    if (rest.length == 1) {
      auto id = rest[0];
      if (req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.getApiProxy(tenantId, id), 200);
        return;
      }
      if (req.method == HTTPMethod.DELETE) {
        res.writeJsonBody(_service.deleteApiProxy(tenantId, id), 200);
        return;
      }
    }
    respondError(res, "Not found", 404);
  }

  // ================================================================
  //  API Management — Products
  // ================================================================

  private void routeApiProducts(
    HTTPServerRequest req, HTTPServerResponse res,
    UUID tenantId, string[] rest
  ) {
    if (rest.length == 0) {
      if (req.method == HTTPMethod.POST) {
        res.writeJsonBody(_service.createApiProduct(tenantId, req.json), 201);
        return;
      }
      if (req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.listApiProducts(tenantId), 200);
        return;
      }
    }
    if (rest.length == 1) {
      auto id = rest[0];
      if (req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.getApiProduct(tenantId, id), 200);
        return;
      }
      if (req.method == HTTPMethod.DELETE) {
        res.writeJsonBody(_service.deleteApiProduct(tenantId, id), 200);
        return;
      }
    }
    respondError(res, "Not found", 404);
  }

  // ================================================================
  //  API Management — Policies
  // ================================================================

  private void routeApiPolicies(
    HTTPServerRequest req, HTTPServerResponse res,
    UUID tenantId, string[] rest
  ) {
    if (rest.length == 0) {
      if (req.method == HTTPMethod.POST) {
        res.writeJsonBody(_service.createApiPolicy(tenantId, req.json), 201);
        return;
      }
      if (req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.listApiPolicies(tenantId), 200);
        return;
      }
    }
    if (rest.length == 1 && req.method == HTTPMethod.DELETE) {
      res.writeJsonBody(_service.deleteApiPolicy(tenantId, rest[0]), 200);
      return;
    }
    respondError(res, "Not found", 404);
  }

  // ================================================================
  //  Event Management — Topics
  // ================================================================

  private void routeEventTopics(
    HTTPServerRequest req, HTTPServerResponse res,
    UUID tenantId, string[] rest
  ) {
    if (rest.length == 0) {
      if (req.method == HTTPMethod.POST) {
        res.writeJsonBody(_service.createEventTopic(tenantId, req.json), 201);
        return;
      }
      if (req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.listEventTopics(tenantId), 200);
        return;
      }
    }
    // DELETE .../event-topics/{id}
    if (rest.length == 1 && req.method == HTTPMethod.DELETE) {
      res.writeJsonBody(_service.deleteEventTopic(tenantId, rest[0]), 200);
      return;
    }
    // POST .../event-topics/{topicName}/publish
    if (rest.length == 2 && rest[1] == "publish" && req.method == HTTPMethod.POST) {
      res.writeJsonBody(_service.publishEvent(tenantId, rest[0], req.json), 200);
      return;
    }
    respondError(res, "Not found", 404);
  }

  // ================================================================
  //  Event Management — Subscriptions
  // ================================================================

  private void routeEventSubscriptions(
    HTTPServerRequest req, HTTPServerResponse res,
    UUID tenantId, string[] rest
  ) {
    if (rest.length == 0) {
      if (req.method == HTTPMethod.POST) {
        res.writeJsonBody(_service.createEventSubscription(tenantId, req.json), 201);
        return;
      }
      if (req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.listEventSubscriptions(tenantId), 200);
        return;
      }
    }
    if (rest.length == 1 && req.method == HTTPMethod.DELETE) {
      res.writeJsonBody(_service.deleteEventSubscription(tenantId, rest[0]), 200);
      return;
    }
    respondError(res, "Not found", 404);
  }

  // ================================================================
  //  Open Connectors
  // ================================================================

  private void routeConnectors(
    HTTPServerRequest req, HTTPServerResponse res,
    UUID tenantId, string[] rest
  ) {
    if (rest.length == 0) {
      if (req.method == HTTPMethod.POST) {
        res.writeJsonBody(_service.createConnector(tenantId, req.json), 201);
        return;
      }
      if (req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.listConnectors(tenantId), 200);
        return;
      }
    }
    if (rest.length == 1) {
      auto id = rest[0];
      if (req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.getConnector(tenantId, id), 200);
        return;
      }
      if (req.method == HTTPMethod.DELETE) {
        res.writeJsonBody(_service.deleteConnector(tenantId, id), 200);
        return;
      }
    }
    respondError(res, "Not found", 404);
  }

  // ================================================================
  //  Integration Advisor — Mappings
  // ================================================================

  private void routeMappings(
    HTTPServerRequest req, HTTPServerResponse res,
    UUID tenantId, string[] rest
  ) {
    if (rest.length == 0) {
      if (req.method == HTTPMethod.POST) {
        res.writeJsonBody(_service.createMapping(tenantId, req.json), 201);
        return;
      }
      if (req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.listMappings(tenantId), 200);
        return;
      }
    }
    if (rest.length == 1) {
      auto id = rest[0];
      if (req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.getMapping(tenantId, id), 200);
        return;
      }
      if (req.method == HTTPMethod.DELETE) {
        res.writeJsonBody(_service.deleteMapping(tenantId, id), 200);
        return;
      }
    }
    respondError(res, "Not found", 404);
  }

  // ================================================================
  //  Trading Partner Management — Partners
  // ================================================================

  private void routeTradingPartners(
    HTTPServerRequest req, HTTPServerResponse res,
    UUID tenantId, string[] rest
  ) {
    if (rest.length == 0) {
      if (req.method == HTTPMethod.POST) {
        res.writeJsonBody(_service.createTradingPartner(tenantId, req.json), 201);
        return;
      }
      if (req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.listTradingPartners(tenantId), 200);
        return;
      }
    }
    if (rest.length == 1) {
      auto id = rest[0];
      if (req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.getTradingPartner(tenantId, id), 200);
        return;
      }
      if (req.method == HTTPMethod.DELETE) {
        res.writeJsonBody(_service.deleteTradingPartner(tenantId, id), 200);
        return;
      }
    }
    respondError(res, "Not found", 404);
  }

  // ================================================================
  //  Trading Partner Management — Agreements
  // ================================================================

  private void routeAgreements(
    HTTPServerRequest req, HTTPServerResponse res,
    UUID tenantId, string[] rest
  ) {
    if (rest.length == 0) {
      if (req.method == HTTPMethod.POST) {
        res.writeJsonBody(_service.createAgreement(tenantId, req.json), 201);
        return;
      }
      if (req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.listAgreements(tenantId), 200);
        return;
      }
    }
    if (rest.length == 1) {
      auto id = rest[0];
      if (req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.getAgreement(tenantId, id), 200);
        return;
      }
      if (req.method == HTTPMethod.DELETE) {
        res.writeJsonBody(_service.deleteAgreement(tenantId, id), 200);
        return;
      }
    }
    respondError(res, "Not found", 404);
  }

  // ================================================================
  //  OData Provisioning
  // ================================================================

  private void routeODataServices(
    HTTPServerRequest req, HTTPServerResponse res,
    UUID tenantId, string[] rest
  ) {
    if (rest.length == 0) {
      if (req.method == HTTPMethod.POST) {
        res.writeJsonBody(_service.createODataService(tenantId, req.json), 201);
        return;
      }
      if (req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.listODataServices(tenantId), 200);
        return;
      }
    }
    if (rest.length == 1) {
      auto id = rest[0];
      if (req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.getODataService(tenantId, id), 200);
        return;
      }
      if (req.method == HTTPMethod.DELETE) {
        res.writeJsonBody(_service.deleteODataService(tenantId, id), 200);
        return;
      }
    }
    respondError(res, "Not found", 404);
  }

  // ================================================================
  //  Integration Assessment
  // ================================================================

  private void routeAssessments(
    HTTPServerRequest req, HTTPServerResponse res,
    UUID tenantId, string[] rest
  ) {
    if (rest.length == 0) {
      if (req.method == HTTPMethod.POST) {
        res.writeJsonBody(_service.createAssessment(tenantId, req.json), 201);
        return;
      }
      if (req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.listAssessments(tenantId), 200);
        return;
      }
    }
    if (rest.length == 1) {
      auto id = rest[0];
      if (req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.getAssessment(tenantId, id), 200);
        return;
      }
      if (req.method == HTTPMethod.DELETE) {
        res.writeJsonBody(_service.deleteAssessment(tenantId, id), 200);
        return;
      }
    }
    respondError(res, "Not found", 404);
  }

  // ================================================================
  //  Migration Assessment
  // ================================================================

  private void routeMigrations(
    HTTPServerRequest req, HTTPServerResponse res,
    UUID tenantId, string[] rest
  ) {
    if (rest.length == 0) {
      if (req.method == HTTPMethod.POST) {
        res.writeJsonBody(_service.createMigration(tenantId, req.json), 201);
        return;
      }
      if (req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.listMigrations(tenantId), 200);
        return;
      }
    }
    if (rest.length == 1) {
      auto id = rest[0];
      if (req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.getMigration(tenantId, id), 200);
        return;
      }
      if (req.method == HTTPMethod.DELETE) {
        res.writeJsonBody(_service.deleteMigration(tenantId, id), 200);
        return;
      }
    }
    // POST .../migrations/{id}/complete
    if (rest.length == 2 && rest[1] == "complete" && req.method == HTTPMethod.POST) {
      res.writeJsonBody(_service.completeMigration(tenantId, rest[0]), 200);
      return;
    }
    respondError(res, "Not found", 404);
  }

  // ================================================================
  //  Hybrid Integration
  // ================================================================

  private void routeHybridRuntimes(
    HTTPServerRequest req, HTTPServerResponse res,
    UUID tenantId, string[] rest
  ) {
    if (rest.length == 0) {
      if (req.method == HTTPMethod.POST) {
        res.writeJsonBody(_service.registerHybridRuntime(tenantId, req.json), 201);
        return;
      }
      if (req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.listHybridRuntimes(tenantId), 200);
        return;
      }
    }
    if (rest.length == 1) {
      auto id = rest[0];
      if (req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.getHybridRuntime(tenantId, id), 200);
        return;
      }
      if (req.method == HTTPMethod.DELETE) {
        res.writeJsonBody(_service.deleteHybridRuntime(tenantId, id), 200);
        return;
      }
    }
    // POST .../hybrid-runtimes/{id}/heartbeat
    if (rest.length == 2 && rest[1] == "heartbeat" && req.method == HTTPMethod.POST) {
      res.writeJsonBody(_service.heartbeatHybridRuntime(tenantId, rest[0]), 200);
      return;
    }
    respondError(res, "Not found", 404);
  }

  // ================================================================
  //  Data Space Integration
  // ================================================================

  private void routeDataAssets(
    HTTPServerRequest req, HTTPServerResponse res,
    UUID tenantId, string[] rest
  ) {
    if (rest.length == 0) {
      if (req.method == HTTPMethod.POST) {
        res.writeJsonBody(_service.createDataAsset(tenantId, req.json), 201);
        return;
      }
      if (req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.listDataAssets(tenantId), 200);
        return;
      }
    }
    if (rest.length == 1) {
      auto id = rest[0];
      if (req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.getDataAsset(tenantId, id), 200);
        return;
      }
      if (req.method == HTTPMethod.DELETE) {
        res.writeJsonBody(_service.deleteDataAsset(tenantId, id), 200);
        return;
      }
    }
    respondError(res, "Not found", 404);
  }

  // ================================================================
  //  Content Packs
  // ================================================================

  private void routeContentPacks(
    HTTPServerRequest req, HTTPServerResponse res,
    UUID tenantId, string[] rest
  ) {
    if (rest.length == 0) {
      if (req.method == HTTPMethod.POST) {
        res.writeJsonBody(_service.createContentPack(tenantId, req.json), 201);
        return;
      }
      if (req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.listContentPacks(tenantId), 200);
        return;
      }
    }
    if (rest.length == 1) {
      auto id = rest[0];
      if (req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.getContentPack(tenantId, id), 200);
        return;
      }
      if (req.method == HTTPMethod.DELETE) {
        res.writeJsonBody(_service.deleteContentPack(tenantId, id), 200);
        return;
      }
    }
    // POST .../content-packs/{id}/install
    if (rest.length == 2 && rest[1] == "install" && req.method == HTTPMethod.POST) {
      res.writeJsonBody(_service.installContentPack(tenantId, rest[0]), 200);
      return;
    }
    respondError(res, "Not found", 404);
  }

  // ================================================================
  //  Auth & helpers
  // ================================================================

  private void validateAuth(HTTPServerRequest req) {
    if (!_service.config.requireAuthToken)
      return;

    if (!("Authorization" in req.headers))
      throw new INTAuthorizationException("Missing Authorization header");

    auto expected = "Bearer " ~ _service.config.authToken;
    if (req.headers["Authorization"] != expected)
      throw new INTAuthorizationException("Invalid token");
  }

}
