module uim.sap.integrationsuite.service;

import uim.sap.integrationsuite;

mixin(ShowModule!());

@safe:

/**
 * INTService — business logic for all Integration Suite capabilities.
 */
class INTService : SAPService {
  private INTStore _store;

  this(INTConfig config) {
    super(config);
    _store = new INTStore;
  }

  // =================================================================
  //  Cloud Integration — IFlows
  // =================================================================

  Json createIFlow(UUID tenantId, Json request) {
    validateId(tenantId, "Tenant ID");
    auto f = iflowFromJson(tenantId, request);
    if (f.name.length == 0)
      throw new INTValidationException("name is required");

    auto saved = _store.upsertIFlow(f);
    Json r = Json.emptyObject;
    r["success"] = true;
    r["iflow"] = saved.toJson();
    return r;
  }

  Json listIFlows(UUID tenantId) {
    validateId(tenantId, "Tenant ID");
    Json resources = Json.emptyArray;
    foreach (f; _store.listIFlows(tenantId))
      resources ~= f.toJson();
    return listResult(tenantId, resources);
  }

  Json getIFlow(UUID tenantId, string iflowId) {
    validateId(tenantId, "Tenant ID");
    auto f = _store.getIFlow(tenantId, iflowId);
    if (f.iflowId.length == 0)
      throw new INTNotFoundException("IFlow", iflowId);
    Json r = Json.emptyObject;
    r["iflow"] = f.toJson();
    return r;
  }

  Json deployIFlow(UUID tenantId, string iflowId) {
    validateId(tenantId, "Tenant ID");
    auto f = _store.getIFlow(tenantId, iflowId);
    if (f.iflowId.length == 0)
      throw new INTNotFoundException("IFlow", iflowId);

    f.status = "deployed";
    f.deployedAt = Clock.currTime().toINTOExtString();
    f.updatedAt = f.deployedAt;
    _store.upsertIFlow(f);

    Json r = Json.emptyObject;
    r["success"] = true;
    r["message"] = "IFlow deployed";
    r["iflow"] = f.toJson();
    return r;
  }

  Json deleteIFlow(UUID tenantId, string iflowId) {
    validateId(tenantId, "Tenant ID");
    if (!_store.deleteIFlow(tenantId, iflowId))
      throw new INTNotFoundException("IFlow", iflowId);
    return deleteResult("IFlow deleted");
  }

  // --- Message Processing Logs ---

  Json createMessageLog(UUID tenantId, Json request) {
    validateId(tenantId, "Tenant ID");
    auto l = messageLogFromJson(tenantId, request);
    auto saved = _store.appendMessageLog(l);
    Json r = Json.emptyObject;
    r["success"] = true;
    r["log"] = saved.toJson();
    return r;
  }

  Json listMessageLogs(UUID tenantId) {
    validateId(tenantId, "Tenant ID");
    Json resources = Json.emptyArray;
    foreach (l; _store.listMessageLogs(tenantId))
      resources ~= l.toJson();
    return listResult(tenantId, resources);
  }

  // =================================================================
  //  API Management — Proxies
  // =================================================================

  Json createApiProxy(UUID tenantId, Json request) {
    validateId(tenantId, "Tenant ID");
    auto p = apiProxyFromJson(tenantId, request);
    if (p.name.length == 0)
      throw new INTValidationException("name is required");
    if (p.targetUrl.length == 0)
      throw new INTValidationException("target_url is required");

    auto saved = _store.upsertApiProxy(p);
    Json r = Json.emptyObject;
    r["success"] = true;
    r["api_proxy"] = saved.toJson();
    return r;
  }

  Json listApiProxies(UUID tenantId) {
    validateId(tenantId, "Tenant ID");
    Json resources = Json.emptyArray;
    foreach (p; _store.listApiProxies(tenantId))
      resources ~= p.toJson();
    return listResult(tenantId, resources);
  }

  Json getApiProxy(UUID tenantId, string proxyId) {
    validateId(tenantId, "Tenant ID");
    auto p = _store.getApiProxy(tenantId, proxyId);
    if (p.proxyId.length == 0)
      throw new INTNotFoundException("API Proxy", proxyId);
    Json r = Json.emptyObject;
    r["api_proxy"] = p.toJson();
    return r;
  }

  Json deleteApiProxy(UUID tenantId, string proxyId) {
    validateId(tenantId, "Tenant ID");
    if (!_store.deleteApiProxy(tenantId, proxyId))
      throw new INTNotFoundException("API Proxy", proxyId);
    return deleteResult("API Proxy deleted");
  }

  // =================================================================
  //  API Management — Products
  // =================================================================

  Json createApiProduct(UUID tenantId, Json request) {
    validateId(tenantId, "Tenant ID");
    auto p = apiProductFromJson(tenantId, request);
    if (p.name.length == 0)
      throw new INTValidationException("name is required");

    auto saved = _store.upsertApiProduct(p);
    Json r = Json.emptyObject;
    r["success"] = true;
    r["api_product"] = saved.toJson();
    return r;
  }

  Json listApiProducts(UUID tenantId) {
    validateId(tenantId, "Tenant ID");
    Json resources = Json.emptyArray;
    foreach (p; _store.listApiProducts(tenantId))
      resources ~= p.toJson();
    return listResult(tenantId, resources);
  }

  Json getApiProduct(UUID tenantId, string productId) {
    validateId(tenantId, "Tenant ID");
    auto p = _store.getApiProduct(tenantId, productId);
    if (p.productId.length == 0)
      throw new INTNotFoundException("API Product", productId);
    
    return Json.emptyObject
      .set("api_product", p.toJson());
  }

  Json deleteApiProduct(UUID tenantId, string productId) {
    validateId(tenantId, "Tenant ID");
    if (!_store.deleteApiProduct(tenantId, productId))
      throw new INTNotFoundException("API Product", productId);
    return deleteResult("API Product deleted");
  }

  // =================================================================
  //  API Management — Policies
  // =================================================================

  Json createApiPolicy(UUID tenantId, Json request) {
    validateId(tenantId, "Tenant ID");
    auto p = apiPolicyFromJson(tenantId, request);
    if (p.name.length == 0)
      throw new INTValidationException("name is required");

    auto saved = _store.upsertApiPolicy(p);
    Json r = Json.emptyObject;
    r["success"] = true;
    r["api_policy"] = saved.toJson();
    return r;
  }

  Json listApiPolicies(UUID tenantId) {
    validateId(tenantId, "Tenant ID");
    Json resources = Json.emptyArray;
    foreach (p; _store.listApiPolicies(tenantId))
      resources ~= p.toJson();
    return listResult(tenantId, resources);
  }

  Json deleteApiPolicy(UUID tenantId, string policyId) {
    validateId(tenantId, "Tenant ID");
    if (!_store.deleteApiPolicy(tenantId, policyId))
      throw new INTNotFoundException("API Policy", policyId);
    return deleteResult("API Policy deleted");
  }

  // =================================================================
  //  Event Management
  // =================================================================

  Json createEventTopic(UUID tenantId, Json request) {
    validateId(tenantId, "Tenant ID");
    auto t = eventTopicFromJson(tenantId, request);
    if (t.topicName.length == 0)
      throw new INTValidationException("topic_name is required");

    auto existing = _store.getEventTopicByName(tenantId, t.topicName);
    if (existing.topicId.length > 0)
      throw new INTValidationException("Event topic already exists: " ~ t.topicName);

    auto saved = _store.upsertEventTopic(t);
    Json r = Json.emptyObject;
    r["success"] = true;
    r["event_topic"] = saved.toJson();
    return r;
  }

  Json listEventTopics(UUID tenantId) {
    validateId(tenantId, "Tenant ID");
    Json resources = Json.emptyArray;
    foreach (t; _store.listEventTopics(tenantId))
      resources ~= t.toJson();
    return listResult(tenantId, resources);
  }

  Json publishEvent(UUID tenantId, string topicName, Json request) {
    validateId(tenantId, "Tenant ID");
    auto topic = _store.getEventTopicByName(tenantId, topicName);
    if (topic.topicId.length == 0)
      throw new INTNotFoundException("Event Topic", topicName);

    topic.messagesPublished = topic.messagesPublished + 1;
    topic.updatedAt = Clock.currTime().toINTOExtString();
    _store.upsertEventTopic(topic);

    auto subs = _store.subscriptionsForTopic(tenantId, topicName);
    long routedCount = 0;
    foreach (sub; subs) {
      ++sub.deliveredCount;
      sub.updatedAt = Clock.currTime().toINTOExtString();
      _store.upsertEventSubscription(sub);
      ++routedCount;
    }

    Json r = Json.emptyObject;
    r["success"] = true;
    r["topic"] = topicName;
    r["routed_to_subscribers"] = routedCount;
    r["message"] = "Event published successfully";
    return r;
  }

  Json deleteEventTopic(UUID tenantId, string topicId) {
    validateId(tenantId, "Tenant ID");
    if (!_store.deleteEventTopic(tenantId, topicId))
      throw new INTNotFoundException("Event Topic", topicId);
    return deleteResult("Event Topic deleted");
  }

  Json createEventSubscription(UUID tenantId, Json request) {
    validateId(tenantId, "Tenant ID");
    auto s = eventSubscriptionFromJson(tenantId, request);
    if (s.topicName.length == 0)
      throw new INTValidationException("topic_name is required");
    if (s.callbackUrl.length == 0)
      throw new INTValidationException("callback_url is required");

    auto topic = _store.getEventTopicByName(tenantId, s.topicName);
    if (topic.topicId.length == 0)
      throw new INTNotFoundException("Event Topic", s.topicName);

    auto saved = _store.upsertEventSubscription(s);

    topic.subscriberCount = topic.subscriberCount + 1;
    topic.updatedAt = Clock.currTime().toINTOExtString();
    _store.upsertEventTopic(topic);

    Json r = Json.emptyObject;
    r["success"] = true;
    r["event_subscription"] = saved.toJson();
    return r;
  }

  Json listEventSubscriptions(UUID tenantId) {
    validateId(tenantId, "Tenant ID");
    Json resources = Json.emptyArray;
    foreach (s; _store.listEventSubscriptions(tenantId))
      resources ~= s.toJson();
    return listResult(tenantId, resources);
  }

  Json deleteEventSubscription(UUID tenantId, string subscriptionId) {
    validateId(tenantId, "Tenant ID");
    if (!_store.deleteEventSubscription(tenantId, subscriptionId))
      throw new INTNotFoundException("Event Subscription", subscriptionId);
    return deleteResult("Event Subscription deleted");
  }

  // =================================================================
  //  Open Connectors
  // =================================================================

  Json createConnector(UUID tenantId, Json request) {
    validateId(tenantId, "Tenant ID");
    auto c = connectorFromJson(tenantId, request);
    if (c.name.length == 0)
      throw new INTValidationException("name is required");
    if (c.provider.length == 0)
      throw new INTValidationException("provider is required");

    auto saved = _store.upsertConnector(c);
    Json r = Json.emptyObject;
    r["success"] = true;
    r["connector"] = saved.toJson();
    return r;
  }

  Json listConnectors(UUID tenantId) {
    validateId(tenantId, "Tenant ID");
    
    Json resources = _store.listConnectors(tenantId).map!(c => c.toJson).array.toJson();
    return listResult(tenantId, resources);
  }

  Json getConnector(UUID tenantId, string connectorId) {
    validateId(tenantId, "Tenant ID");
    auto c = _store.getConnector(tenantId, connectorId);
    if (c.connectorId.length == 0)
      throw new INTNotFoundException("Connector", connectorId);
    Json r = Json.emptyObject;
    r["connector"] = c.toJson();
    return r;
  }

  Json deleteConnector(UUID tenantId, string connectorId) {
    validateId(tenantId, "Tenant ID");
    if (!_store.deleteConnector(tenantId, connectorId)) {
      throw new INTNotFoundException("Connector", connectorId);
    }
    
    return deleteResult("Connector deleted");
  }

  // =================================================================
  //  Integration Advisor — Mappings
  // =================================================================

  Json createMapping(UUID tenantId, Json request) {
    validateId(tenantId, "Tenant ID");
    auto m = mappingFromJson(tenantId, request);
    if (m.name.length == 0)
      throw new INTValidationException("name is required");

    auto saved = _store.upsertMapping(m);
    Json r = Json.emptyObject;
    r["success"] = true;
    r["mapping"] = saved.toJson();
    return r;
  }

  Json listMappings(UUID tenantId) {
    validateId(tenantId, "Tenant ID");
    Json resources = Json.emptyArray;
    foreach (m; _store.listMappings(tenantId))
      resources ~= m.toJson();
    return listResult(tenantId, resources);
  }

  Json getMapping(UUID tenantId, string mappingId) {
    validateId(tenantId, "Tenant ID");
    auto m = _store.getMapping(tenantId, mappingId);
    if (m.mappingId.length == 0)
      throw new INTNotFoundException("Mapping", mappingId);
    Json r = Json.emptyObject;
    r["mapping"] = m.toJson();
    return r;
  }

  Json deleteMapping(UUID tenantId, string mappingId) {
    validateId(tenantId, "Tenant ID");

    if (!_store.deleteMapping(tenantId, mappingId))
      throw new INTNotFoundException("Mapping", mappingId);
    return deleteResult("Mapping deleted");
  }

  // =================================================================
  //  Trading Partner Management — Partners
  // =================================================================

  Json createTradingPartner(UUID tenantId, Json request) {
    validateId(tenantId, "Tenant ID");

    auto tp = tradingPartnerFromJson(tenantId, request);
    if (tp.name.length == 0) {
      throw new INTValidationException("name is required");
    }

    auto saved = _store.upsertTradingPartner(tp);
    Json r = Json.emptyObject;
    r["success"] = true;
    r["trading_partner"] = saved.toJson();
    return r;
  }

  Json listTradingPartners(UUID tenantId) {
    validateId(tenantId, "Tenant ID");
    Json resources = Json.emptyArray;
    foreach (tp; _store.listTradingPartners(tenantId))
      resources ~= tp.toJson();
    return listResult(tenantId, resources);
  }

  Json getTradingPartner(UUID tenantId, string partnerId) {
    validateId(tenantId, "Tenant ID");
    auto tp = _store.getTradingPartner(tenantId, partnerId);
    if (tp.partnerId.length == 0)
      throw new INTNotFoundException("Trading Partner", partnerId);
    Json r = Json.emptyObject;
    r["trading_partner"] = tp.toJson();
    return r;
  }

  Json deleteTradingPartner(UUID tenantId, string partnerId) {
    validateId(tenantId, "Tenant ID");
    if (!_store.deleteTradingPartner(tenantId, partnerId))
      throw new INTNotFoundException("Trading Partner", partnerId);
    return deleteResult("Trading Partner deleted");
  }

  // =================================================================
  //  Trading Partner Management — Agreements
  // =================================================================

  Json createAgreement(UUID tenantId, Json request) {
    validateId(tenantId, "Tenant ID");
    auto a = INTAgreement(tenantId, request);
    if (a.partnerId.length == 0)
      throw new INTValidationException("partner_id is required");
    if (a.name.length == 0)
      throw new INTValidationException("name is required");

    auto partner = _store.getTradingPartner(tenantId, a.partnerId);
    if (partner.partnerId.length == 0)
      throw new INTNotFoundException("Trading Partner", a.partnerId);

    auto saved = _store.upsertAgreement(a);

    partner.agreementCount = partner.agreementCount + 1;
    partner.updatedAt = Clock.currTime().toINTOExtString();
    _store.upsertTradingPartner(partner);

    Json json = Json.emptyObject;
    return json
      .set("success", true)
      .set("agreement", saved.toJson());
  }

  Json listAgreements(UUID tenantId) {
    validateId(tenantId, "Tenant ID");
    Json resources = _store.listAgreements(tenantId).map!(a => a.toJson).array.toJson();
    return listResult(tenantId, resources);
  }

  Json getAgreement(UUID tenantId, string agreementId) {
    validateId(tenantId, "Tenant ID");
    auto a = _store.getAgreement(tenantId, agreementId);
    if (a.agreementId.length == 0)
      throw new INTNotFoundException("Agreement", agreementId);
    Json r = Json.emptyObject;
    r["agreement"] = a.toJson();
    return r;
  }

  Json deleteAgreement(UUID tenantId, string agreementId) {
    validateId(tenantId, "Tenant ID");

    if (!_store.deleteAgreement(tenantId, agreementId)) {
      throw new INTNotFoundException("Agreement", agreementId);
    }

    return deleteResult("Agreement deleted");
  }

  // =================================================================
  //  OData Provisioning
  // =================================================================

  Json createODataService(UUID tenantId, Json request) {
    validateId(tenantId, "Tenant ID");
    auto svc = odataServiceFromJson(tenantId, request);
    if (svc.name.length == 0)
      throw new INTValidationException("name is required");
    if (svc.serviceUrl.length == 0)
      throw new INTValidationException("service_url is required");

    auto saved = _store.upsertODataService(svc);
    Json json = Json.emptyObject;
    return json
      .set("success", true)
      .set("odata_service", saved.toJson());
  }

  Json listODataServices(UUID tenantId) {
    return listODataServices(tenantId.toString());
  }

  Json listODataServices(UUID tenantId) {
    validateId(tenantId, "Tenant ID");

    Json resources = _store.listODataServices(tenantId).map!(svc => svc.toJson).array.toJson();
    return listResult(tenantId, resources);
  }

  Json getODataService(UUID tenantId, UUID serviceId) {
    return getODataService(tenantId.toString(), serviceId.toString());
  }

  Json getODataService(UUID tenantId, string serviceId) {
    validateId(tenantId, "Tenant ID");

    auto svc = _store.getODataService(tenantId, serviceId);
    if (svc.serviceId.length == 0) {
      throw new INTNotFoundException("OData Service", serviceId);
    }

    Json json = Json.emptyObject;
    return json.set("odata_service", svc.toJson());
  }

  Json deleteODataService(UUID tenantId, string serviceId) {
    validateId(tenantId, "Tenant ID");
    if (!_store.deleteODataService(tenantId, serviceId)) {
      throw new INTNotFoundException("OData Service", serviceId);
    }
    return deleteResult("OData Service deleted");
  }

  // =================================================================
  //  Integration Assessment
  // =================================================================

  Json createAssessment(UUID tenantId, Json request) {
    validateId(tenantId, "Tenant ID");
    auto a = assessmentFromJson(tenantId, request);
    if (a.name.length == 0)
      throw new INTValidationException("name is required");

    auto saved = _store.upsertAssessment(a);
    Json r = Json.emptyObject;
    r["success"] = true;
    r["assessment"] = saved.toJson();
    return r;
  }

  Json listAssessments(UUID tenantId) {
    return listAssessments(tenantId.toString());
  }

  Json listAssessments(UUID tenantId) {
    validateId(tenantId, "Tenant ID");
    Json resources = _store.listAssessments(tenantId).map!(a => a.toJson).array.toJson();
    return listResult(tenantId, resources);
  }

  Json getAssessment(UUID tenantId, UUID assessmentId) {
    return getAssessment(tenantId.toString(), assessmentId.toString());
  }

  Json getAssessment(UUID tenantId, string assessmentId) {
    validateId(tenantId, "Tenant ID");
    auto a = _store.getAssessment(tenantId, assessmentId);
    if (a.assessmentId.length == 0)
      throw new INTNotFoundException("Assessment", assessmentId);
    Json r = Json.emptyObject;
    r["assessment"] = a.toJson();
    return r;
  }

  Json deleteAssessment(UUID tenantId, UUID assessmentId) {
    return deleteAssessment(tenantId.toString(), assessmentId.toString());
  }

  Json deleteAssessment(UUID tenantId, string assessmentId) {
    validateId(tenantId, "Tenant ID");
    if (!_store.deleteAssessment(tenantId, assessmentId))
      throw new INTNotFoundException("Assessment", assessmentId);
    return deleteResult("Assessment deleted");
  }

  // =================================================================
  //  Migration Assessment
  // =================================================================

  Json createMigration(UUID tenantId, Json request) {
    validateId(tenantId, "Tenant ID");
    auto m = migrationFromJson(tenantId, request);
    if (m.name.length == 0)
      throw new INTValidationException("name is required");

    // Auto-estimate hours based on complexity
    if (m.estimatedHours == 0) {
      if (m.complexity == "low")
        m.estimatedHours = 8;
      else if (m.complexity == "medium")
        m.estimatedHours = 40;
      else if (m.complexity == "high")
        m.estimatedHours = 120;
      else if (m.complexity == "critical")
        m.estimatedHours = 240;
    }

    m.assessedAt = Clock.currTime().toINTOExtString();
    auto saved = _store.upsertMigration(m);
    Json r = Json.emptyObject;
    r["success"] = true;
    r["migration"] = saved.toJson();
    return r;
  }

  Json listMigrations(UUID tenantId) {
    validateId(tenantId, "Tenant ID");
    Json resources = Json.emptyArray;
    foreach (m; _store.listMigrations(tenantId))
      resources ~= m.toJson();
    return listResult(tenantId, resources);
  }

  Json getMigration(UUID tenantId, string migrationId) {
    validateId(tenantId, "Tenant ID");
    auto m = _store.getMigration(tenantId, migrationId);
    if (m.migrationId.length == 0)
      throw new INTNotFoundException("Migration", migrationId);
    
    return Json.emptyObject
      .set("migration", m.toJson());
  }

  Json completeMigration(UUID tenantId, string migrationId) {
    validateId(tenantId, "Tenant ID");
    auto m = _store.getMigration(tenantId, migrationId);
    if (m.migrationId.length == 0)
      throw new INTNotFoundException("Migration", migrationId);

    m.status = "completed";
    m.completedAt = Clock.currTime().toINTOExtString();
    m.updatedAt = m.completedAt;
    _store.upsertMigration(m);

    return Json.emptyObject
      .set("success", true)
      .set("message", "Migration completed")
      .set("migration", m.toJson());
  }

  Json deleteMigration(UUID tenantId, string migrationId) {
    validateId(tenantId, "Tenant ID");
    if (!_store.deleteMigration(tenantId, migrationId))
      throw new INTNotFoundException("Migration", migrationId);
    return deleteResult("Migration deleted");
  }

  // =================================================================
  //  Hybrid Integration
  // =================================================================

  Json registerHybridRuntime(UUID tenantId, Json request) {
    validateId(tenantId, "Tenant ID");
    auto rt = hybridRuntimeFromJson(tenantId, request);
    if (rt.name.length == 0)
      throw new INTValidationException("name is required");

    rt.lastHeartbeat = Clock.currTime().toINTOExtString();
    auto saved = _store.upsertHybridRuntime(rt);
    Json r = Json.emptyObject;
    r["success"] = true;
    r["hybrid_runtime"] = saved.toJson();
    return r;
  }

  Json listHybridRuntimes(UUID tenantId) {
    validateId(tenantId, "Tenant ID");
    Json resources = Json.emptyArray;
    foreach (rt; _store.listHybridRuntimes(tenantId))
      resources ~= rt.toJson();
    return listResult(tenantId, resources);
  }

  Json getHybridRuntime(UUID tenantId, string runtimeId) {
    validateId(tenantId, "Tenant ID");
    auto rt = _store.getHybridRuntime(tenantId, runtimeId);
    if (rt.runtimeId.length == 0)
      throw new INTNotFoundException("Hybrid Runtime", runtimeId);
    Json r = Json.emptyObject;
    r["hybrid_runtime"] = rt.toJson();
    return r;
  }

  Json heartbeatHybridRuntime(UUID tenantId, string runtimeId) {
    validateId(tenantId, "Tenant ID");
    auto rt = _store.getHybridRuntime(tenantId, runtimeId);
    if (rt.runtimeId.length == 0)
      throw new INTNotFoundException("Hybrid Runtime", runtimeId);

    rt.lastHeartbeat = Clock.currTime().toINTOExtString();
    rt.status = "online";
    rt.updatedAt = rt.lastHeartbeat;
    _store.upsertHybridRuntime(rt);

    Json r = Json.emptyObject;
    r["success"] = true;
    r["message"] = "Heartbeat recorded";
    return r;
  }

  Json deleteHybridRuntime(UUID tenantId, string runtimeId) {
    validateId(tenantId, "Tenant ID");
    if (!_store.deleteHybridRuntime(tenantId, runtimeId))
      throw new INTNotFoundException("Hybrid Runtime", runtimeId);
    return deleteResult("Hybrid Runtime deleted");
  }

  // =================================================================
  //  Data Space Integration
  // =================================================================

  Json createDataAsset(UUID tenantId, Json request) {
    validateId(tenantId, "Tenant ID");
    auto a = dataAssetFromJson(tenantId, request);
    if (a.name.length == 0)
      throw new INTValidationException("name is required");

    auto saved = _store.upsertDataAsset(a);
    Json r = Json.emptyObject;
    r["success"] = true;
    r["data_asset"] = saved.toJson();
    return r;
  }

  Json listDataAssets(UUID tenantId) {
    validateId(tenantId, "Tenant ID");
    Json resources = Json.emptyArray;
    foreach (a; _store.listDataAssets(tenantId))
      resources ~= a.toJson();
    return listResult(tenantId, resources);
  }

  Json getDataAsset(UUID tenantId, string assetId) {
    validateId(tenantId, "Tenant ID");
    auto a = _store.getDataAsset(tenantId, assetId);
    if (a.assetId.length == 0)
      throw new INTNotFoundException("Data Asset", assetId);
    Json r = Json.emptyObject;
    r["data_asset"] = a.toJson();
    return r;
  }

  Json deleteDataAsset(UUID tenantId, string assetId) {
    validateId(tenantId, "Tenant ID");
    if (!_store.deleteDataAsset(tenantId, assetId))
      throw new INTNotFoundException("Data Asset", assetId);
    return deleteResult("Data Asset deleted");
  }

  // =================================================================
  //  Content Packs
  // =================================================================

  Json createContentPack(UUID tenantId, Json request) {
    validateId(tenantId, "Tenant ID");
    auto p = contentPackFromJson(tenantId, request);
    if (p.name.length == 0)
      throw new INTValidationException("name is required");

    auto saved = _store.upsertContentPack(p);
    Json r = Json.emptyObject;
    r["success"] = true;
    r["content_pack"] = saved.toJson();
    return r;
  }

  Json listContentPacks(UUID tenantId) {
    validateId(tenantId, "Tenant ID");
    Json resources = Json.emptyArray;
    foreach (p; _store.listContentPacks(tenantId))
      resources ~= p.toJson();
    return listResult(tenantId, resources);
  }

  Json getContentPack(UUID tenantId, string packId) {
    validateId(tenantId, "Tenant ID");
    auto p = _store.getContentPack(tenantId, packId);
    if (p.packId.length == 0)
      throw new INTNotFoundException("Content Pack", packId);
    Json r = Json.emptyObject;
    r["content_pack"] = p.toJson();
    return r;
  }

  Json installContentPack(UUID tenantId, string packId) {
    validateId(tenantId, "Tenant ID");
    auto p = _store.getContentPack(tenantId, packId);
    if (p.packId.length == 0)
      throw new INTNotFoundException("Content Pack", packId);

    p.status = "installed";
    p.installedAt = Clock.currTime().toINTOExtString();
    p.updatedAt = p.installedAt;
    _store.upsertContentPack(p);

    return Json.emptyObject
      .set("success", true)
      .set("message", "Content pack installed")
      .set("content_pack", p.toJson());
  }

  Json deleteContentPack(UUID tenantId, string packId) {
    validateId(tenantId, "Tenant ID");
    if (!_store.deleteContentPack(tenantId, packId))
      throw new INTNotFoundException("Content Pack", packId);
    return deleteResult("Content Pack deleted");
  }

  // =================================================================
  //  Dashboard
  // =================================================================

  Json dashboard(UUID tenantId) {
    validateId(tenantId, "Tenant ID");

    return Json.emptyObject
      .set("tenant_id", tenantId)
      .set("iflows", cast(long)_store.listIFlows(tenantId).length)
      .set("message_logs", cast(long)_store.listMessageLogs(tenantId).length)
      .set("api_proxies", cast(long)_store.listApiProxies(tenantId).length)
      .set("api_products", cast(long)_store.listApiProducts(tenantId).length)
      .set("api_policies", cast(long)_store.listApiPolicies(tenantId).length)
      .set("event_topics", cast(long)_store.listEventTopics(tenantId).length)
      .set("event_subscriptions", cast(long)_store.listEventSubscriptions(tenantId).length)
      .set("connectors", cast(long)_store.listConnectors(tenantId).length)
      .set("mappings", cast(long)_store.listMappings(tenantId).length)
      .set("trading_partners", cast(long)_store.listTradingPartners(tenantId).length)
      .set("agreements", cast(long)_store.listAgreements(tenantId).length)
      .set("odata_services", cast(long)_store.listODataServices(tenantId).length)
      .set("assessments", cast(long)_store.listAssessments(tenantId).length)
      .set("migrations", cast(long)_store.listMigrations(tenantId).length)
      .set("hybrid_runtimes", cast(long)_store.listHybridRuntimes(tenantId).length)
      .set("data_assets", cast(long)_store.listDataAssets(tenantId).length)
      .set("content_packs", cast(long)_store.listContentPacks(tenantId).length);
  }

  // =================================================================
  //  Helpers
  // =================================================================

  private Json listResult(UUID tenantId, Json resources) {
    return Json.emptyObject
      .set("tenant_id", tenantId)
      .set("resources", resources)
      .set("total_results", cast(long)resources.length);
  }

  private Json deleteResult(string message) {
    return Json.emptyObject
      .set("success", true)
      .set("message", message);
  }
}
