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

    Json createIFlow(string tenantId, Json request) {
        validateId(tenantId, "Tenant ID");
        auto f = iflowFromJson(tenantId, request);
        if (f.name.length == 0) throw new INTValidationException("name is required");

        auto saved = _store.upsertIFlow(f);
        Json r = Json.emptyObject;
        r["success"] = true;
        r["iflow"] = saved.toJson();
        return r;
    }

    Json listIFlows(string tenantId) {
        validateId(tenantId, "Tenant ID");
        Json resources = Json.emptyArray;
        foreach (f; _store.listIFlows(tenantId)) resources ~= f.toJson();
        return listResult(tenantId, resources);
    }

    Json getIFlow(string tenantId, string iflowId) {
        validateId(tenantId, "Tenant ID");
        auto f = _store.getIFlow(tenantId, iflowId);
        if (f.iflowId.length == 0) throw new INTNotFoundException("IFlow", iflowId);
        Json r = Json.emptyObject;
        r["iflow"] = f.toJson();
        return r;
    }

    Json deployIFlow(string tenantId, string iflowId) {
        validateId(tenantId, "Tenant ID");
        auto f = _store.getIFlow(tenantId, iflowId);
        if (f.iflowId.length == 0) throw new INTNotFoundException("IFlow", iflowId);

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

    Json deleteIFlow(string tenantId, string iflowId) {
        validateId(tenantId, "Tenant ID");
        if (!_store.deleteIFlow(tenantId, iflowId))
            throw new INTNotFoundException("IFlow", iflowId);
        return deleteResult("IFlow deleted");
    }

    // --- Message Processing Logs ---

    Json createMessageLog(string tenantId, Json request) {
        validateId(tenantId, "Tenant ID");
        auto l = messageLogFromJson(tenantId, request);
        auto saved = _store.appendMessageLog(l);
        Json r = Json.emptyObject;
        r["success"] = true;
        r["log"] = saved.toJson();
        return r;
    }

    Json listMessageLogs(string tenantId) {
        validateId(tenantId, "Tenant ID");
        Json resources = Json.emptyArray;
        foreach (l; _store.listMessageLogs(tenantId)) resources ~= l.toJson();
        return listResult(tenantId, resources);
    }

    // =================================================================
    //  API Management — Proxies
    // =================================================================

    Json createApiProxy(string tenantId, Json request) {
        validateId(tenantId, "Tenant ID");
        auto p = apiProxyFromJson(tenantId, request);
        if (p.name.length == 0) throw new INTValidationException("name is required");
        if (p.targetUrl.length == 0) throw new INTValidationException("target_url is required");

        auto saved = _store.upsertApiProxy(p);
        Json r = Json.emptyObject;
        r["success"] = true;
        r["api_proxy"] = saved.toJson();
        return r;
    }

    Json listApiProxies(string tenantId) {
        validateId(tenantId, "Tenant ID");
        Json resources = Json.emptyArray;
        foreach (p; _store.listApiProxies(tenantId)) resources ~= p.toJson();
        return listResult(tenantId, resources);
    }

    Json getApiProxy(string tenantId, string proxyId) {
        validateId(tenantId, "Tenant ID");
        auto p = _store.getApiProxy(tenantId, proxyId);
        if (p.proxyId.length == 0) throw new INTNotFoundException("API Proxy", proxyId);
        Json r = Json.emptyObject;
        r["api_proxy"] = p.toJson();
        return r;
    }

    Json deleteApiProxy(string tenantId, string proxyId) {
        validateId(tenantId, "Tenant ID");
        if (!_store.deleteApiProxy(tenantId, proxyId))
            throw new INTNotFoundException("API Proxy", proxyId);
        return deleteResult("API Proxy deleted");
    }

    // =================================================================
    //  API Management — Products
    // =================================================================

    Json createApiProduct(string tenantId, Json request) {
        validateId(tenantId, "Tenant ID");
        auto p = apiProductFromJson(tenantId, request);
        if (p.name.length == 0) throw new INTValidationException("name is required");

        auto saved = _store.upsertApiProduct(p);
        Json r = Json.emptyObject;
        r["success"] = true;
        r["api_product"] = saved.toJson();
        return r;
    }

    Json listApiProducts(string tenantId) {
        validateId(tenantId, "Tenant ID");
        Json resources = Json.emptyArray;
        foreach (p; _store.listApiProducts(tenantId)) resources ~= p.toJson();
        return listResult(tenantId, resources);
    }

    Json getApiProduct(string tenantId, string productId) {
        validateId(tenantId, "Tenant ID");
        auto p = _store.getApiProduct(tenantId, productId);
        if (p.productId.length == 0) throw new INTNotFoundException("API Product", productId);
        Json r = Json.emptyObject;
        r["api_product"] = p.toJson();
        return r;
    }

    Json deleteApiProduct(string tenantId, string productId) {
        validateId(tenantId, "Tenant ID");
        if (!_store.deleteApiProduct(tenantId, productId))
            throw new INTNotFoundException("API Product", productId);
        return deleteResult("API Product deleted");
    }

    // =================================================================
    //  API Management — Policies
    // =================================================================

    Json createApiPolicy(string tenantId, Json request) {
        validateId(tenantId, "Tenant ID");
        auto p = apiPolicyFromJson(tenantId, request);
        if (p.name.length == 0) throw new INTValidationException("name is required");

        auto saved = _store.upsertApiPolicy(p);
        Json r = Json.emptyObject;
        r["success"] = true;
        r["api_policy"] = saved.toJson();
        return r;
    }

    Json listApiPolicies(string tenantId) {
        validateId(tenantId, "Tenant ID");
        Json resources = Json.emptyArray;
        foreach (p; _store.listApiPolicies(tenantId)) resources ~= p.toJson();
        return listResult(tenantId, resources);
    }

    Json deleteApiPolicy(string tenantId, string policyId) {
        validateId(tenantId, "Tenant ID");
        if (!_store.deleteApiPolicy(tenantId, policyId))
            throw new INTNotFoundException("API Policy", policyId);
        return deleteResult("API Policy deleted");
    }

    // =================================================================
    //  Event Management
    // =================================================================

    Json createEventTopic(string tenantId, Json request) {
        validateId(tenantId, "Tenant ID");
        auto t = eventTopicFromJson(tenantId, request);
        if (t.topicName.length == 0) throw new INTValidationException("topic_name is required");

        auto existing = _store.getEventTopicByName(tenantId, t.topicName);
        if (existing.topicId.length > 0)
            throw new INTValidationException("Event topic already exists: " ~ t.topicName);

        auto saved = _store.upsertEventTopic(t);
        Json r = Json.emptyObject;
        r["success"] = true;
        r["event_topic"] = saved.toJson();
        return r;
    }

    Json listEventTopics(string tenantId) {
        validateId(tenantId, "Tenant ID");
        Json resources = Json.emptyArray;
        foreach (t; _store.listEventTopics(tenantId)) resources ~= t.toJson();
        return listResult(tenantId, resources);
    }

    Json publishEvent(string tenantId, string topicName, Json request) {
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

    Json deleteEventTopic(string tenantId, string topicId) {
        validateId(tenantId, "Tenant ID");
        if (!_store.deleteEventTopic(tenantId, topicId))
            throw new INTNotFoundException("Event Topic", topicId);
        return deleteResult("Event Topic deleted");
    }

    Json createEventSubscription(string tenantId, Json request) {
        validateId(tenantId, "Tenant ID");
        auto s = eventSubscriptionFromJson(tenantId, request);
        if (s.topicName.length == 0) throw new INTValidationException("topic_name is required");
        if (s.callbackUrl.length == 0) throw new INTValidationException("callback_url is required");

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

    Json listEventSubscriptions(string tenantId) {
        validateId(tenantId, "Tenant ID");
        Json resources = Json.emptyArray;
        foreach (s; _store.listEventSubscriptions(tenantId)) resources ~= s.toJson();
        return listResult(tenantId, resources);
    }

    Json deleteEventSubscription(string tenantId, string subscriptionId) {
        validateId(tenantId, "Tenant ID");
        if (!_store.deleteEventSubscription(tenantId, subscriptionId))
            throw new INTNotFoundException("Event Subscription", subscriptionId);
        return deleteResult("Event Subscription deleted");
    }

    // =================================================================
    //  Open Connectors
    // =================================================================

    Json createConnector(string tenantId, Json request) {
        validateId(tenantId, "Tenant ID");
        auto c = connectorFromJson(tenantId, request);
        if (c.name.length == 0) throw new INTValidationException("name is required");
        if (c.provider.length == 0) throw new INTValidationException("provider is required");

        auto saved = _store.upsertConnector(c);
        Json r = Json.emptyObject;
        r["success"] = true;
        r["connector"] = saved.toJson();
        return r;
    }

    Json listConnectors(string tenantId) {
        validateId(tenantId, "Tenant ID");
        Json resources = Json.emptyArray;
        foreach (c; _store.listConnectors(tenantId)) resources ~= c.toJson();
        return listResult(tenantId, resources);
    }

    Json getConnector(string tenantId, string connectorId) {
        validateId(tenantId, "Tenant ID");
        auto c = _store.getConnector(tenantId, connectorId);
        if (c.connectorId.length == 0) throw new INTNotFoundException("Connector", connectorId);
        Json r = Json.emptyObject;
        r["connector"] = c.toJson();
        return r;
    }

    Json deleteConnector(string tenantId, string connectorId) {
        validateId(tenantId, "Tenant ID");
        if (!_store.deleteConnector(tenantId, connectorId))
            throw new INTNotFoundException("Connector", connectorId);
        return deleteResult("Connector deleted");
    }

    // =================================================================
    //  Integration Advisor — Mappings
    // =================================================================

    Json createMapping(string tenantId, Json request) {
        validateId(tenantId, "Tenant ID");
        auto m = mappingFromJson(tenantId, request);
        if (m.name.length == 0) throw new INTValidationException("name is required");

        auto saved = _store.upsertMapping(m);
        Json r = Json.emptyObject;
        r["success"] = true;
        r["mapping"] = saved.toJson();
        return r;
    }

    Json listMappings(string tenantId) {
        validateId(tenantId, "Tenant ID");
        Json resources = Json.emptyArray;
        foreach (m; _store.listMappings(tenantId)) resources ~= m.toJson();
        return listResult(tenantId, resources);
    }

    Json getMapping(string tenantId, string mappingId) {
        validateId(tenantId, "Tenant ID");
        auto m = _store.getMapping(tenantId, mappingId);
        if (m.mappingId.length == 0) throw new INTNotFoundException("Mapping", mappingId);
        Json r = Json.emptyObject;
        r["mapping"] = m.toJson();
        return r;
    }

    Json deleteMapping(string tenantId, string mappingId) {
        validateId(tenantId, "Tenant ID");
        if (!_store.deleteMapping(tenantId, mappingId))
            throw new INTNotFoundException("Mapping", mappingId);
        return deleteResult("Mapping deleted");
    }

    // =================================================================
    //  Trading Partner Management — Partners
    // =================================================================

    Json createTradingPartner(string tenantId, Json request) {
        validateId(tenantId, "Tenant ID");
        auto tp = tradingPartnerFromJson(tenantId, request);
        if (tp.name.length == 0) throw new INTValidationException("name is required");

        auto saved = _store.upsertTradingPartner(tp);
        Json r = Json.emptyObject;
        r["success"] = true;
        r["trading_partner"] = saved.toJson();
        return r;
    }

    Json listTradingPartners(string tenantId) {
        validateId(tenantId, "Tenant ID");
        Json resources = Json.emptyArray;
        foreach (tp; _store.listTradingPartners(tenantId)) resources ~= tp.toJson();
        return listResult(tenantId, resources);
    }

    Json getTradingPartner(string tenantId, string partnerId) {
        validateId(tenantId, "Tenant ID");
        auto tp = _store.getTradingPartner(tenantId, partnerId);
        if (tp.partnerId.length == 0) throw new INTNotFoundException("Trading Partner", partnerId);
        Json r = Json.emptyObject;
        r["trading_partner"] = tp.toJson();
        return r;
    }

    Json deleteTradingPartner(string tenantId, string partnerId) {
        validateId(tenantId, "Tenant ID");
        if (!_store.deleteTradingPartner(tenantId, partnerId))
            throw new INTNotFoundException("Trading Partner", partnerId);
        return deleteResult("Trading Partner deleted");
    }

    // =================================================================
    //  Trading Partner Management — Agreements
    // =================================================================

    Json createAgreement(string tenantId, Json request) {
        validateId(tenantId, "Tenant ID");
        auto a = agreementFromJson(tenantId, request);
        if (a.partnerId.length == 0) throw new INTValidationException("partner_id is required");
        if (a.name.length == 0) throw new INTValidationException("name is required");

        auto partner = _store.getTradingPartner(tenantId, a.partnerId);
        if (partner.partnerId.length == 0)
            throw new INTNotFoundException("Trading Partner", a.partnerId);

        auto saved = _store.upsertAgreement(a);

        partner.agreementCount = partner.agreementCount + 1;
        partner.updatedAt = Clock.currTime().toINTOExtString();
        _store.upsertTradingPartner(partner);

        Json r = Json.emptyObject;
        r["success"] = true;
        r["agreement"] = saved.toJson();
        return r;
    }

    Json listAgreements(string tenantId) {
        validateId(tenantId, "Tenant ID");
        Json resources = Json.emptyArray;
        foreach (a; _store.listAgreements(tenantId)) resources ~= a.toJson();
        return listResult(tenantId, resources);
    }

    Json getAgreement(string tenantId, string agreementId) {
        validateId(tenantId, "Tenant ID");
        auto a = _store.getAgreement(tenantId, agreementId);
        if (a.agreementId.length == 0) throw new INTNotFoundException("Agreement", agreementId);
        Json r = Json.emptyObject;
        r["agreement"] = a.toJson();
        return r;
    }

    Json deleteAgreement(string tenantId, string agreementId) {
        validateId(tenantId, "Tenant ID");
        if (!_store.deleteAgreement(tenantId, agreementId))
            throw new INTNotFoundException("Agreement", agreementId);
        return deleteResult("Agreement deleted");
    }

    // =================================================================
    //  OData Provisioning
    // =================================================================

    Json createODataService(string tenantId, Json request) {
        validateId(tenantId, "Tenant ID");
        auto svc = odataServiceFromJson(tenantId, request);
        if (svc.name.length == 0) throw new INTValidationException("name is required");
        if (svc.serviceUrl.length == 0) throw new INTValidationException("service_url is required");

        auto saved = _store.upsertODataService(svc);
        Json r = Json.emptyObject;
        r["success"] = true;
        r["odata_service"] = saved.toJson();
        return r;
    }

    Json listODataServices(string tenantId) {
        validateId(tenantId, "Tenant ID");
        Json resources = Json.emptyArray;
        foreach (svc; _store.listODataServices(tenantId)) resources ~= svc.toJson();
        return listResult(tenantId, resources);
    }

    Json getODataService(string tenantId, string serviceId) {
        validateId(tenantId, "Tenant ID");
        auto svc = _store.getODataService(tenantId, serviceId);
        if (svc.serviceId.length == 0) throw new INTNotFoundException("OData Service", serviceId);
        Json r = Json.emptyObject;
        r["odata_service"] = svc.toJson();
        return r;
    }

    Json deleteODataService(string tenantId, string serviceId) {
        validateId(tenantId, "Tenant ID");
        if (!_store.deleteODataService(tenantId, serviceId))
            throw new INTNotFoundException("OData Service", serviceId);
        return deleteResult("OData Service deleted");
    }

    // =================================================================
    //  Integration Assessment
    // =================================================================

    Json createAssessment(string tenantId, Json request) {
        validateId(tenantId, "Tenant ID");
        auto a = assessmentFromJson(tenantId, request);
        if (a.name.length == 0) throw new INTValidationException("name is required");

        auto saved = _store.upsertAssessment(a);
        Json r = Json.emptyObject;
        r["success"] = true;
        r["assessment"] = saved.toJson();
        return r;
    }

    Json listAssessments(string tenantId) {
        validateId(tenantId, "Tenant ID");
        Json resources = Json.emptyArray;
        foreach (a; _store.listAssessments(tenantId)) resources ~= a.toJson();
        return listResult(tenantId, resources);
    }

    Json getAssessment(string tenantId, string assessmentId) {
        validateId(tenantId, "Tenant ID");
        auto a = _store.getAssessment(tenantId, assessmentId);
        if (a.assessmentId.length == 0) throw new INTNotFoundException("Assessment", assessmentId);
        Json r = Json.emptyObject;
        r["assessment"] = a.toJson();
        return r;
    }

    Json deleteAssessment(string tenantId, string assessmentId) {
        validateId(tenantId, "Tenant ID");
        if (!_store.deleteAssessment(tenantId, assessmentId))
            throw new INTNotFoundException("Assessment", assessmentId);
        return deleteResult("Assessment deleted");
    }

    // =================================================================
    //  Migration Assessment
    // =================================================================

    Json createMigration(string tenantId, Json request) {
        validateId(tenantId, "Tenant ID");
        auto m = migrationFromJson(tenantId, request);
        if (m.name.length == 0) throw new INTValidationException("name is required");

        // Auto-estimate hours based on complexity
        if (m.estimatedHours == 0) {
            if (m.complexity == "low") m.estimatedHours = 8;
            else if (m.complexity == "medium") m.estimatedHours = 40;
            else if (m.complexity == "high") m.estimatedHours = 120;
            else if (m.complexity == "critical") m.estimatedHours = 240;
        }

        m.assessedAt = Clock.currTime().toINTOExtString();
        auto saved = _store.upsertMigration(m);
        Json r = Json.emptyObject;
        r["success"] = true;
        r["migration"] = saved.toJson();
        return r;
    }

    Json listMigrations(string tenantId) {
        validateId(tenantId, "Tenant ID");
        Json resources = Json.emptyArray;
        foreach (m; _store.listMigrations(tenantId)) resources ~= m.toJson();
        return listResult(tenantId, resources);
    }

    Json getMigration(string tenantId, string migrationId) {
        validateId(tenantId, "Tenant ID");
        auto m = _store.getMigration(tenantId, migrationId);
        if (m.migrationId.length == 0) throw new INTNotFoundException("Migration", migrationId);
        Json r = Json.emptyObject;
        r["migration"] = m.toJson();
        return r;
    }

    Json completeMigration(string tenantId, string migrationId) {
        validateId(tenantId, "Tenant ID");
        auto m = _store.getMigration(tenantId, migrationId);
        if (m.migrationId.length == 0) throw new INTNotFoundException("Migration", migrationId);

        m.status = "completed";
        m.completedAt = Clock.currTime().toINTOExtString();
        m.updatedAt = m.completedAt;
        _store.upsertMigration(m);

        Json r = Json.emptyObject;
        r["success"] = true;
        r["message"] = "Migration completed";
        r["migration"] = m.toJson();
        return r;
    }

    Json deleteMigration(string tenantId, string migrationId) {
        validateId(tenantId, "Tenant ID");
        if (!_store.deleteMigration(tenantId, migrationId))
            throw new INTNotFoundException("Migration", migrationId);
        return deleteResult("Migration deleted");
    }

    // =================================================================
    //  Hybrid Integration
    // =================================================================

    Json registerHybridRuntime(string tenantId, Json request) {
        validateId(tenantId, "Tenant ID");
        auto rt = hybridRuntimeFromJson(tenantId, request);
        if (rt.name.length == 0) throw new INTValidationException("name is required");

        rt.lastHeartbeat = Clock.currTime().toINTOExtString();
        auto saved = _store.upsertHybridRuntime(rt);
        Json r = Json.emptyObject;
        r["success"] = true;
        r["hybrid_runtime"] = saved.toJson();
        return r;
    }

    Json listHybridRuntimes(string tenantId) {
        validateId(tenantId, "Tenant ID");
        Json resources = Json.emptyArray;
        foreach (rt; _store.listHybridRuntimes(tenantId)) resources ~= rt.toJson();
        return listResult(tenantId, resources);
    }

    Json getHybridRuntime(string tenantId, string runtimeId) {
        validateId(tenantId, "Tenant ID");
        auto rt = _store.getHybridRuntime(tenantId, runtimeId);
        if (rt.runtimeId.length == 0) throw new INTNotFoundException("Hybrid Runtime", runtimeId);
        Json r = Json.emptyObject;
        r["hybrid_runtime"] = rt.toJson();
        return r;
    }

    Json heartbeatHybridRuntime(string tenantId, string runtimeId) {
        validateId(tenantId, "Tenant ID");
        auto rt = _store.getHybridRuntime(tenantId, runtimeId);
        if (rt.runtimeId.length == 0) throw new INTNotFoundException("Hybrid Runtime", runtimeId);

        rt.lastHeartbeat = Clock.currTime().toINTOExtString();
        rt.status = "online";
        rt.updatedAt = rt.lastHeartbeat;
        _store.upsertHybridRuntime(rt);

        Json r = Json.emptyObject;
        r["success"] = true;
        r["message"] = "Heartbeat recorded";
        return r;
    }

    Json deleteHybridRuntime(string tenantId, string runtimeId) {
        validateId(tenantId, "Tenant ID");
        if (!_store.deleteHybridRuntime(tenantId, runtimeId))
            throw new INTNotFoundException("Hybrid Runtime", runtimeId);
        return deleteResult("Hybrid Runtime deleted");
    }

    // =================================================================
    //  Data Space Integration
    // =================================================================

    Json createDataAsset(string tenantId, Json request) {
        validateId(tenantId, "Tenant ID");
        auto a = dataAssetFromJson(tenantId, request);
        if (a.name.length == 0) throw new INTValidationException("name is required");

        auto saved = _store.upsertDataAsset(a);
        Json r = Json.emptyObject;
        r["success"] = true;
        r["data_asset"] = saved.toJson();
        return r;
    }

    Json listDataAssets(string tenantId) {
        validateId(tenantId, "Tenant ID");
        Json resources = Json.emptyArray;
        foreach (a; _store.listDataAssets(tenantId)) resources ~= a.toJson();
        return listResult(tenantId, resources);
    }

    Json getDataAsset(string tenantId, string assetId) {
        validateId(tenantId, "Tenant ID");
        auto a = _store.getDataAsset(tenantId, assetId);
        if (a.assetId.length == 0) throw new INTNotFoundException("Data Asset", assetId);
        Json r = Json.emptyObject;
        r["data_asset"] = a.toJson();
        return r;
    }

    Json deleteDataAsset(string tenantId, string assetId) {
        validateId(tenantId, "Tenant ID");
        if (!_store.deleteDataAsset(tenantId, assetId))
            throw new INTNotFoundException("Data Asset", assetId);
        return deleteResult("Data Asset deleted");
    }

    // =================================================================
    //  Content Packs
    // =================================================================

    Json createContentPack(string tenantId, Json request) {
        validateId(tenantId, "Tenant ID");
        auto p = contentPackFromJson(tenantId, request);
        if (p.name.length == 0) throw new INTValidationException("name is required");

        auto saved = _store.upsertContentPack(p);
        Json r = Json.emptyObject;
        r["success"] = true;
        r["content_pack"] = saved.toJson();
        return r;
    }

    Json listContentPacks(string tenantId) {
        validateId(tenantId, "Tenant ID");
        Json resources = Json.emptyArray;
        foreach (p; _store.listContentPacks(tenantId)) resources ~= p.toJson();
        return listResult(tenantId, resources);
    }

    Json getContentPack(string tenantId, string packId) {
        validateId(tenantId, "Tenant ID");
        auto p = _store.getContentPack(tenantId, packId);
        if (p.packId.length == 0) throw new INTNotFoundException("Content Pack", packId);
        Json r = Json.emptyObject;
        r["content_pack"] = p.toJson();
        return r;
    }

    Json installContentPack(string tenantId, string packId) {
        validateId(tenantId, "Tenant ID");
        auto p = _store.getContentPack(tenantId, packId);
        if (p.packId.length == 0) throw new INTNotFoundException("Content Pack", packId);

        p.status = "installed";
        p.installedAt = Clock.currTime().toINTOExtString();
        p.updatedAt = p.installedAt;
        _store.upsertContentPack(p);

        Json r = Json.emptyObject;
        r["success"] = true;
        r["message"] = "Content pack installed";
        r["content_pack"] = p.toJson();
        return r;
    }

    Json deleteContentPack(string tenantId, string packId) {
        validateId(tenantId, "Tenant ID");
        if (!_store.deleteContentPack(tenantId, packId))
            throw new INTNotFoundException("Content Pack", packId);
        return deleteResult("Content Pack deleted");
    }

    // =================================================================
    //  Dashboard
    // =================================================================

    Json dashboard(string tenantId) {
        validateId(tenantId, "Tenant ID");

        Json r = Json.emptyObject;
        r["tenant_id"] = tenantId;
        r["iflows"] = cast(long)_store.listIFlows(tenantId).length;
        r["message_logs"] = cast(long)_store.listMessageLogs(tenantId).length;
        r["api_proxies"] = cast(long)_store.listApiProxies(tenantId).length;
        r["api_products"] = cast(long)_store.listApiProducts(tenantId).length;
        r["api_policies"] = cast(long)_store.listApiPolicies(tenantId).length;
        r["event_topics"] = cast(long)_store.listEventTopics(tenantId).length;
        r["event_subscriptions"] = cast(long)_store.listEventSubscriptions(tenantId).length;
        r["connectors"] = cast(long)_store.listConnectors(tenantId).length;
        r["mappings"] = cast(long)_store.listMappings(tenantId).length;
        r["trading_partners"] = cast(long)_store.listTradingPartners(tenantId).length;
        r["agreements"] = cast(long)_store.listAgreements(tenantId).length;
        r["odata_services"] = cast(long)_store.listODataServices(tenantId).length;
        r["assessments"] = cast(long)_store.listAssessments(tenantId).length;
        r["migrations"] = cast(long)_store.listMigrations(tenantId).length;
        r["hybrid_runtimes"] = cast(long)_store.listHybridRuntimes(tenantId).length;
        r["data_assets"] = cast(long)_store.listDataAssets(tenantId).length;
        r["content_packs"] = cast(long)_store.listContentPacks(tenantId).length;
        return r;
    }

    // =================================================================
    //  Helpers
    // =================================================================

    private void validateId(string value, string fieldName) {
        if (value.length == 0)
            throw new INTValidationException(fieldName ~ " cannot be empty");
    }

    private Json listResult(string tenantId, Json resources) {
        Json r = Json.emptyObject;
        r["tenant_id"] = tenantId;
        r["resources"] = resources;
        r["total_results"] = cast(long)resources.length;
        return r;
    }

    private Json deleteResult(string message) {
        Json r = Json.emptyObject;
        r["success"] = true;
        r["message"] = message;
        return r;
    }
}
