module uim.sap.integrationsuite.store;

import core.sync.mutex : Mutex;

import uim.sap.integrationsuite;

mixin(ShowModule!());

@safe:

/**
 * In-memory store for all Integration Suite resources.
 *
 * Thread-safe via Mutex. In production this would be backed by a
 * persistent data store.
 */
class INTStore : SAPStore {
    // ---- Cloud Integration ----
    private INTIFlow[string] _iflows;
    private INTMessageLog[][string] _messageLogs;  // keyed by tenantId

    // ---- API Management ----
    private INTApiProxy[string] _apiProxies;
    private INTApiProduct[string] _apiProducts;
    private INTApiPolicy[string] _apiPolicies;

    // ---- Event Management ----
    private INTEventTopic[string] _eventTopics;
    private INTEventSubscription[string] _eventSubscriptions;

    // ---- Open Connectors ----
    private INTConnector[string] _connectors;

    // ---- Integration Advisor ----
    private INTMapping[string] _mappings;

    // ---- Trading Partner Management ----
    private INTTradingPartner[string] _tradingPartners;
    private INTAgreement[string] _agreements;

    // ---- OData Provisioning ----
    private INTODataService[string] _odataServices;

    // ---- Integration Assessment ----
    private INTAssessment[string] _assessments;

    // ---- Migration Assessment ----
    private INTMigration[string] _migrations;

    // ---- Hybrid Integration ----
    private INTHybridRuntime[string] _hybridRuntimes;

    // ---- Data Space Integration ----
    private INTDataAsset[string] _dataAssets;

    // ---- Content Packs ----
    private INTContentPack[string] _contentPacks;

    private Mutex _lock;

    this() {
        _lock = new Mutex;
    }

    // =====================================================================
    //  Cloud Integration — IFlows
    // =====================================================================

    INTIFlow upsertIFlow(INTIFlow f) {
        synchronized (_lock) {
            auto key = tenantKey(f.tenantId, f.iflowId);
            if (auto existing = key in _iflows) {
                f.createdAt = existing.createdAt;
            }
            _iflows[key] = f;
            return f;
        }
    }

    INTIFlow getIFlow(UUID tenantId, string iflowId) {
        synchronized (_lock) {
            auto key = tenantKey(tenantId, iflowId);
            if (auto v = key in _iflows) return *v;
        }
        return INTIFlow.init;
    }

    INTIFlow[] listIFlows(UUID tenantId) {
        INTIFlow[] list;
        synchronized (_lock) {
            foreach (key, f; _iflows) {
                if (belongsTo(key, tenantId)) list ~= f;
            }
        }
        return list;
    }

    bool deleteIFlow(UUID tenantId, string iflowId) {
        synchronized (_lock) {
            auto key = tenantKey(tenantId, iflowId);
            if (key in _iflows) { _iflows.remove(key); return true; }
        }
        return false;
    }

    // =====================================================================
    //  Cloud Integration — Message Logs
    // =====================================================================

    INTMessageLog appendMessageLog(INTMessageLog l) {
        synchronized (_lock) {
            _messageLogs[l.tenantId] ~= l;
            return l;
        }
    }

    INTMessageLog[] listMessageLogs(UUID tenantId) {
        synchronized (_lock) {
            if (auto logs = tenantId in _messageLogs)
                return (*logs).dup;
        }
        return null;
    }

    INTMessageLog[] listMessageLogsByIFlow(UUID tenantId, string iflowId) {
        INTMessageLog[] result;
        synchronized (_lock) {
            if (auto logs = tenantId in _messageLogs) {
                foreach (l; *logs) {
                    if (l.iflowId == iflowId) result ~= l;
                }
            }
        }
        return result;
    }

    // =====================================================================
    //  API Management — Proxies
    // =====================================================================

    INTApiProxy upsertApiProxy(INTApiProxy p) {
        synchronized (_lock) {
            auto key = tenantKey(p.tenantId, p.proxyId);
            if (auto existing = key in _apiProxies) {
                p.createdAt = existing.createdAt;
                p.callCount = existing.callCount;
                p.errorCount = existing.errorCount;
            }
            _apiProxies[key] = p;
            return p;
        }
    }

    INTApiProxy getApiProxy(UUID tenantId, string proxyId) {
        synchronized (_lock) {
            auto key = tenantKey(tenantId, proxyId);
            if (auto v = key in _apiProxies) return *v;
        }
        return INTApiProxy.init;
    }

    INTApiProxy[] listApiProxies(UUID tenantId) {
        INTApiProxy[] list;
        synchronized (_lock) {
            foreach (key, p; _apiProxies) {
                if (belongsTo(key, tenantId)) list ~= p;
            }
        }
        return list;
    }

    bool deleteApiProxy(UUID tenantId, string proxyId) {
        synchronized (_lock) {
            auto key = tenantKey(tenantId, proxyId);
            if (key in _apiProxies) { _apiProxies.remove(key); return true; }
        }
        return false;
    }

    // =====================================================================
    //  API Management — Products
    // =====================================================================

    INTApiProduct upsertApiProduct(INTApiProduct p) {
        synchronized (_lock) {
            auto key = tenantKey(p.tenantId, p.productId);
            if (auto existing = key in _apiProducts) {
                p.createdAt = existing.createdAt;
                p.subscriberCount = existing.subscriberCount;
            }
            _apiProducts[key] = p;
            return p;
        }
    }

    INTApiProduct getApiProduct(UUID tenantId, string productId) {
        synchronized (_lock) {
            auto key = tenantKey(tenantId, productId);
            if (auto v = key in _apiProducts) return *v;
        }
        return INTApiProduct.init;
    }

    INTApiProduct[] listApiProducts(UUID tenantId) {
        INTApiProduct[] list;
        synchronized (_lock) {
            foreach (key, p; _apiProducts) {
                if (belongsTo(key, tenantId)) list ~= p;
            }
        }
        return list;
    }

    bool deleteApiProduct(UUID tenantId, string productId) {
        synchronized (_lock) {
            auto key = tenantKey(tenantId, productId);
            if (key in _apiProducts) { _apiProducts.remove(key); return true; }
        }
        return false;
    }

    // =====================================================================
    //  API Management — Policies
    // =====================================================================

    INTApiPolicy upsertApiPolicy(INTApiPolicy p) {
        synchronized (_lock) {
            auto key = tenantKey(p.tenantId, p.policyId);
            if (auto existing = key in _apiPolicies) {
                p.createdAt = existing.createdAt;
            }
            _apiPolicies[key] = p;
            return p;
        }
    }

    INTApiPolicy getApiPolicy(UUID tenantId, string policyId) {
        synchronized (_lock) {
            auto key = tenantKey(tenantId, policyId);
            if (auto v = key in _apiPolicies) return *v;
        }
        return INTApiPolicy.init;
    }

    INTApiPolicy[] listApiPolicies(UUID tenantId) {
        INTApiPolicy[] list;
        synchronized (_lock) {
            foreach (key, p; _apiPolicies) {
                if (belongsTo(key, tenantId)) list ~= p;
            }
        }
        return list;
    }

    bool deleteApiPolicy(UUID tenantId, string policyId) {
        synchronized (_lock) {
            auto key = tenantKey(tenantId, policyId);
            if (key in _apiPolicies) { _apiPolicies.remove(key); return true; }
        }
        return false;
    }

    // =====================================================================
    //  Event Management — Topics
    // =====================================================================

    INTEventTopic upsertEventTopic(INTEventTopic t) {
        synchronized (_lock) {
            auto key = tenantKey(t.tenantId, t.topicId);
            if (auto existing = key in _eventTopics) {
                t.createdAt = existing.createdAt;
                t.subscriberCount = existing.subscriberCount;
                t.messagesPublished = existing.messagesPublished;
            }
            _eventTopics[key] = t;
            return t;
        }
    }

    INTEventTopic getEventTopic(UUID tenantId, string topicId) {
        synchronized (_lock) {
            auto key = tenantKey(tenantId, topicId);
            if (auto v = key in _eventTopics) return *v;
        }
        return INTEventTopic.init;
    }

    INTEventTopic getEventTopicByName(UUID tenantId, string topicName) {
        synchronized (_lock) {
            foreach (_, t; _eventTopics) {
                if (t.tenantId == tenantId && t.topicName == topicName)
                    return t;
            }
        }
        return INTEventTopic.init;
    }

    INTEventTopic[] listEventTopics(UUID tenantId) {
        INTEventTopic[] list;
        synchronized (_lock) {
            foreach (key, t; _eventTopics) {
                if (belongsTo(key, tenantId)) list ~= t;
            }
        }
        return list;
    }

    bool deleteEventTopic(UUID tenantId, string topicId) {
        synchronized (_lock) {
            auto key = tenantKey(tenantId, topicId);
            if (key in _eventTopics) { _eventTopics.remove(key); return true; }
        }
        return false;
    }

    // =====================================================================
    //  Event Management — Subscriptions
    // =====================================================================

    INTEventSubscription upsertEventSubscription(INTEventSubscription s) {
        synchronized (_lock) {
            auto key = tenantKey(s.tenantId, s.subscriptionId);
            if (auto existing = key in _eventSubscriptions) {
                s.createdAt = existing.createdAt;
            }
            _eventSubscriptions[key] = s;
            return s;
        }
    }

    INTEventSubscription[] listEventSubscriptions(UUID tenantId) {
        INTEventSubscription[] list;
        synchronized (_lock) {
            foreach (_, s; _eventSubscriptions) {
                if (s.tenantId == tenantId) list ~= s;
            }
        }
        return list;
    }

    INTEventSubscription[] subscriptionsForTopic(UUID tenantId, string topicName) {
        INTEventSubscription[] list;
        synchronized (_lock) {
            foreach (_, s; _eventSubscriptions) {
                if (s.tenantId == tenantId && s.topicName == topicName && s.active)
                    list ~= s;
            }
        }
        return list;
    }

    bool deleteEventSubscription(UUID tenantId, string subscriptionId) {
        synchronized (_lock) {
            auto key = tenantKey(tenantId, subscriptionId);
            if (key in _eventSubscriptions) { _eventSubscriptions.remove(key); return true; }
        }
        return false;
    }

    // =====================================================================
    //  Open Connectors
    // =====================================================================

    INTConnector upsertConnector(INTConnector c) {
        synchronized (_lock) {
            auto key = tenantKey(c.tenantId, c.connectorId);
            if (auto existing = key in _connectors) {
                c.createdAt = existing.createdAt;
                c.callCount = existing.callCount;
            }
            _connectors[key] = c;
            return c;
        }
    }

    INTConnector getConnector(UUID tenantId, string connectorId) {
        synchronized (_lock) {
            auto key = tenantKey(tenantId, connectorId);
            if (auto v = key in _connectors) return *v;
        }
        return INTConnector.init;
    }

    INTConnector[] listConnectors(UUID tenantId) {
        INTConnector[] list;
        synchronized (_lock) {
            foreach (key, c; _connectors) {
                if (belongsTo(key, tenantId)) list ~= c;
            }
        }
        return list;
    }

    bool deleteConnector(UUID tenantId, string connectorId) {
        synchronized (_lock) {
            auto key = tenantKey(tenantId, connectorId);
            if (key in _connectors) { _connectors.remove(key); return true; }
        }
        return false;
    }

    // =====================================================================
    //  Integration Advisor — Mappings
    // =====================================================================

    INTMapping upsertMapping(INTMapping m) {
        synchronized (_lock) {
            auto key = tenantKey(m.tenantId, m.mappingId);
            if (auto existing = key in _mappings) {
                m.createdAt = existing.createdAt;
            }
            _mappings[key] = m;
            return m;
        }
    }

    INTMapping getMapping(UUID tenantId, string mappingId) {
        synchronized (_lock) {
            auto key = tenantKey(tenantId, mappingId);
            if (auto v = key in _mappings) return *v;
        }
        return INTMapping.init;
    }

    INTMapping[] listMappings(UUID tenantId) {
        INTMapping[] list;
        synchronized (_lock) {
            foreach (key, m; _mappings) {
                if (belongsTo(key, tenantId)) list ~= m;
            }
        }
        return list;
    }

    bool deleteMapping(UUID tenantId, string mappingId) {
        synchronized (_lock) {
            auto key = tenantKey(tenantId, mappingId);
            if (key in _mappings) { _mappings.remove(key); return true; }
        }
        return false;
    }

    // =====================================================================
    //  Trading Partner Management — Partners
    // =====================================================================

    INTTradingPartner upsertTradingPartner(INTTradingPartner tp) {
        synchronized (_lock) {
            auto key = tenantKey(tp.tenantId, tp.partnerId);
            if (auto existing = key in _tradingPartners) {
                tp.createdAt = existing.createdAt;
                tp.agreementCount = existing.agreementCount;
            }
            _tradingPartners[key] = tp;
            return tp;
        }
    }

    INTTradingPartner getTradingPartner(UUID tenantId, string partnerId) {
        synchronized (_lock) {
            auto key = tenantKey(tenantId, partnerId);
            if (auto v = key in _tradingPartners) return *v;
        }
        return INTTradingPartner.init;
    }

    INTTradingPartner[] listTradingPartners(UUID tenantId) {
        INTTradingPartner[] list;
        synchronized (_lock) {
            foreach (key, tp; _tradingPartners) {
                if (belongsTo(key, tenantId)) list ~= tp;
            }
        }
        return list;
    }

    bool deleteTradingPartner(UUID tenantId, string partnerId) {
        synchronized (_lock) {
            auto key = tenantKey(tenantId, partnerId);
            if (key in _tradingPartners) { _tradingPartners.remove(key); return true; }
        }
        return false;
    }

    // =====================================================================
    //  Trading Partner Management — Agreements
    // =====================================================================

    INTAgreement upsertAgreement(INTAgreement a) {
        synchronized (_lock) {
            auto key = tenantKey(a.tenantId, a.agreementId);
            if (auto existing = key in _agreements) {
                a.createdAt = existing.createdAt;
                a.transactionCount = existing.transactionCount;
            }
            _agreements[key] = a;
            return a;
        }
    }

    INTAgreement getAgreement(UUID tenantId, string agreementId) {
        synchronized (_lock) {
            auto key = tenantKey(tenantId, agreementId);
            if (auto v = key in _agreements) return *v;
        }
        return INTAgreement.init;
    }

    INTAgreement[] listAgreements(UUID tenantId) {
        INTAgreement[] list;
        synchronized (_lock) {
            foreach (key, a; _agreements) {
                if (belongsTo(key, tenantId)) list ~= a;
            }
        }
        return list;
    }

    INTAgreement[] listAgreementsForPartner(UUID tenantId, string partnerId) {
        INTAgreement[] list;
        synchronized (_lock) {
            foreach (_, a; _agreements) {
                if (a.tenantId == tenantId && a.partnerId == partnerId)
                    list ~= a;
            }
        }
        return list;
    }

    bool deleteAgreement(UUID tenantId, string agreementId) {
        synchronized (_lock) {
            auto key = tenantKey(tenantId, agreementId);
            if (key in _agreements) { _agreements.remove(key); return true; }
        }
        return false;
    }

    // =====================================================================
    //  OData Provisioning
    // =====================================================================

    INTODataService upsertODataService(INTODataService svc) {
        synchronized (_lock) {
            auto key = tenantKey(svc.tenantId, svc.serviceId);
            if (auto existing = key in _odataServices) {
                svc.createdAt = existing.createdAt;
                svc.queryCount = existing.queryCount;
            }
            _odataServices[key] = svc;
            return svc;
        }
    }

    INTODataService getODataService(UUID tenantId, string serviceId) {
        synchronized (_lock) {
            auto key = tenantKey(tenantId, serviceId);
            if (auto v = key in _odataServices) return *v;
        }
        return INTODataService.init;
    }

    INTODataService[] listODataServices(UUID tenantId) {
        INTODataService[] list;
        synchronized (_lock) {
            foreach (key, svc; _odataServices) {
                if (belongsTo(key, tenantId)) list ~= svc;
            }
        }
        return list;
    }

    bool deleteODataService(UUID tenantId, string serviceId) {
        synchronized (_lock) {
            auto key = tenantKey(tenantId, serviceId);
            if (key in _odataServices) { _odataServices.remove(key); return true; }
        }
        return false;
    }

    // =====================================================================
    //  Integration Assessment
    // =====================================================================

    INTAssessment upsertAssessment(INTAssessment a) {
        synchronized (_lock) {
            auto key = tenantKey(a.tenantId, a.assessmentId);
            if (auto existing = key in _assessments) {
                a.createdAt = existing.createdAt;
            }
            _assessments[key] = a;
            return a;
        }
    }

    INTAssessment getAssessment(UUID tenantId, string assessmentId) {
        synchronized (_lock) {
            auto key = tenantKey(tenantId, assessmentId);
            if (auto v = key in _assessments) return *v;
        }
        return INTAssessment.init;
    }

    INTAssessment[] listAssessments(UUID tenantId) {
        INTAssessment[] list;
        synchronized (_lock) {
            foreach (key, a; _assessments) {
                if (belongsTo(key, tenantId)) list ~= a;
            }
        }
        return list;
    }

    bool deleteAssessment(UUID tenantId, string assessmentId) {
        synchronized (_lock) {
            auto key = tenantKey(tenantId, assessmentId);
            if (key in _assessments) { _assessments.remove(key); return true; }
        }
        return false;
    }

    // =====================================================================
    //  Migration Assessment
    // =====================================================================

    INTMigration upsertMigration(INTMigration m) {
        synchronized (_lock) {
            auto key = tenantKey(m.tenantId, m.migrationId);
            if (auto existing = key in _migrations) {
                m.createdAt = existing.createdAt;
            }
            _migrations[key] = m;
            return m;
        }
    }

    INTMigration getMigration(UUID tenantId, string migrationId) {
        synchronized (_lock) {
            auto key = tenantKey(tenantId, migrationId);
            if (auto v = key in _migrations) return *v;
        }
        return INTMigration.init;
    }

    INTMigration[] listMigrations(UUID tenantId) {
        INTMigration[] list;
        synchronized (_lock) {
            foreach (key, m; _migrations) {
                if (belongsTo(key, tenantId)) list ~= m;
            }
        }
        return list;
    }

    bool deleteMigration(UUID tenantId, string migrationId) {
        synchronized (_lock) {
            auto key = tenantKey(tenantId, migrationId);
            if (key in _migrations) { _migrations.remove(key); return true; }
        }
        return false;
    }

    // =====================================================================
    //  Hybrid Integration
    // =====================================================================

    INTHybridRuntime upsertHybridRuntime(INTHybridRuntime r) {
        synchronized (_lock) {
            auto key = tenantKey(r.tenantId, r.runtimeId);
            if (auto existing = key in _hybridRuntimes) {
                r.createdAt = existing.createdAt;
            }
            _hybridRuntimes[key] = r;
            return r;
        }
    }

    INTHybridRuntime getHybridRuntime(UUID tenantId, string runtimeId) {
        synchronized (_lock) {
            auto key = tenantKey(tenantId, runtimeId);
            if (auto v = key in _hybridRuntimes) return *v;
        }
        return INTHybridRuntime.init;
    }

    INTHybridRuntime[] listHybridRuntimes(UUID tenantId) {
        INTHybridRuntime[] list;
        synchronized (_lock) {
            foreach (key, r; _hybridRuntimes) {
                if (belongsTo(key, tenantId)) list ~= r;
            }
        }
        return list;
    }

    bool deleteHybridRuntime(UUID tenantId, string runtimeId) {
        synchronized (_lock) {
            auto key = tenantKey(tenantId, runtimeId);
            if (key in _hybridRuntimes) { _hybridRuntimes.remove(key); return true; }
        }
        return false;
    }

    // =====================================================================
    //  Data Space Integration
    // =====================================================================

    INTDataAsset upsertDataAsset(INTDataAsset a) {
        synchronized (_lock) {
            auto key = tenantKey(a.tenantId, a.assetId);
            if (auto existing = key in _dataAssets) {
                a.createdAt = existing.createdAt;
                a.accessCount = existing.accessCount;
            }
            _dataAssets[key] = a;
            return a;
        }
    }

    INTDataAsset getDataAsset(UUID tenantId, string assetId) {
        synchronized (_lock) {
            auto key = tenantKey(tenantId, assetId);
            if (auto v = key in _dataAssets) return *v;
        }
        return INTDataAsset.init;
    }

    INTDataAsset[] listDataAssets(UUID tenantId) {
        INTDataAsset[] list;
        synchronized (_lock) {
            foreach (key, a; _dataAssets) {
                if (belongsTo(key, tenantId)) list ~= a;
            }
        }
        return list;
    }

    bool deleteDataAsset(UUID tenantId, string assetId) {
        synchronized (_lock) {
            auto key = tenantKey(tenantId, assetId);
            if (key in _dataAssets) { _dataAssets.remove(key); return true; }
        }
        return false;
    }

    // =====================================================================
    //  Content Packs
    // =====================================================================

    INTContentPack upsertContentPack(INTContentPack p) {
        synchronized (_lock) {
            auto key = tenantKey(p.tenantId, p.packId);
            if (auto existing = key in _contentPacks) {
                p.createdAt = existing.createdAt;
            }
            _contentPacks[key] = p;
            return p;
        }
    }

    INTContentPack getContentPack(UUID tenantId, string packId) {
        synchronized (_lock) {
            auto key = tenantKey(tenantId, packId);
            if (auto v = key in _contentPacks) return *v;
        }
        return INTContentPack.init;
    }

    INTContentPack[] listContentPacks(UUID tenantId) {
        INTContentPack[] list;
        synchronized (_lock) {
            foreach (key, p; _contentPacks) {
                if (belongsTo(key, tenantId)) list ~= p;
            }
        }
        return list;
    }

    bool deleteContentPack(UUID tenantId, string packId) {
        synchronized (_lock) {
            auto key = tenantKey(tenantId, packId);
            if (key in _contentPacks) { _contentPacks.remove(key); return true; }
        }
        return false;
    }

    // =====================================================================
    //  Helpers
    // =====================================================================

    private string tenantKey(UUID tenantId, string resourceId) {
        return tenantId ~ ":" ~ resourceId;
    }

    private bool belongsTo(string key, UUID tenantId) {
        return key.length > tenantId.length + 1
            && key[0 .. tenantId.length] == tenantId
            && key[tenantId.length] == ':';
    }
}
