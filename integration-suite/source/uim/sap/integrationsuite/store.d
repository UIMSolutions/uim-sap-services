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
class ISStore : SAPStore {
    // ---- Cloud Integration ----
    private ISIFlow[string] _iflows;
    private ISMessageLog[][string] _messageLogs;  // keyed by tenantId

    // ---- API Management ----
    private ISApiProxy[string] _apiProxies;
    private ISApiProduct[string] _apiProducts;
    private ISApiPolicy[string] _apiPolicies;

    // ---- Event Management ----
    private ISEventTopic[string] _eventTopics;
    private ISEventSubscription[string] _eventSubscriptions;

    // ---- Open Connectors ----
    private ISConnector[string] _connectors;

    // ---- Integration Advisor ----
    private ISMapping[string] _mappings;

    // ---- Trading Partner Management ----
    private ISTradingPartner[string] _tradingPartners;
    private ISAgreement[string] _agreements;

    // ---- OData Provisioning ----
    private ISODataService[string] _odataServices;

    // ---- Integration Assessment ----
    private ISAssessment[string] _assessments;

    // ---- Migration Assessment ----
    private ISMigration[string] _migrations;

    // ---- Hybrid Integration ----
    private ISHybridRuntime[string] _hybridRuntimes;

    // ---- Data Space Integration ----
    private ISDataAsset[string] _dataAssets;

    // ---- Content Packs ----
    private ISContentPack[string] _contentPacks;

    private Mutex _lock;

    this() {
        _lock = new Mutex;
    }

    // =====================================================================
    //  Cloud Integration — IFlows
    // =====================================================================

    ISIFlow upsertIFlow(ISIFlow f) {
        synchronized (_lock) {
            auto key = tenantKey(f.tenantId, f.iflowId);
            if (auto existing = key in _iflows) {
                f.createdAt = existing.createdAt;
            }
            _iflows[key] = f;
            return f;
        }
    }

    ISIFlow getIFlow(string tenantId, string iflowId) {
        synchronized (_lock) {
            auto key = tenantKey(tenantId, iflowId);
            if (auto v = key in _iflows) return *v;
        }
        return ISIFlow.init;
    }

    ISIFlow[] listIFlows(string tenantId) {
        ISIFlow[] list;
        synchronized (_lock) {
            foreach (key, f; _iflows) {
                if (belongsTo(key, tenantId)) list ~= f;
            }
        }
        return list;
    }

    bool deleteIFlow(string tenantId, string iflowId) {
        synchronized (_lock) {
            auto key = tenantKey(tenantId, iflowId);
            if (key in _iflows) { _iflows.remove(key); return true; }
        }
        return false;
    }

    // =====================================================================
    //  Cloud Integration — Message Logs
    // =====================================================================

    ISMessageLog appendMessageLog(ISMessageLog l) {
        synchronized (_lock) {
            _messageLogs[l.tenantId] ~= l;
            return l;
        }
    }

    ISMessageLog[] listMessageLogs(string tenantId) {
        synchronized (_lock) {
            if (auto logs = tenantId in _messageLogs)
                return (*logs).dup;
        }
        return [];
    }

    ISMessageLog[] listMessageLogsByIFlow(string tenantId, string iflowId) {
        ISMessageLog[] result;
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

    ISApiProxy upsertApiProxy(ISApiProxy p) {
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

    ISApiProxy getApiProxy(string tenantId, string proxyId) {
        synchronized (_lock) {
            auto key = tenantKey(tenantId, proxyId);
            if (auto v = key in _apiProxies) return *v;
        }
        return ISApiProxy.init;
    }

    ISApiProxy[] listApiProxies(string tenantId) {
        ISApiProxy[] list;
        synchronized (_lock) {
            foreach (key, p; _apiProxies) {
                if (belongsTo(key, tenantId)) list ~= p;
            }
        }
        return list;
    }

    bool deleteApiProxy(string tenantId, string proxyId) {
        synchronized (_lock) {
            auto key = tenantKey(tenantId, proxyId);
            if (key in _apiProxies) { _apiProxies.remove(key); return true; }
        }
        return false;
    }

    // =====================================================================
    //  API Management — Products
    // =====================================================================

    ISApiProduct upsertApiProduct(ISApiProduct p) {
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

    ISApiProduct getApiProduct(string tenantId, string productId) {
        synchronized (_lock) {
            auto key = tenantKey(tenantId, productId);
            if (auto v = key in _apiProducts) return *v;
        }
        return ISApiProduct.init;
    }

    ISApiProduct[] listApiProducts(string tenantId) {
        ISApiProduct[] list;
        synchronized (_lock) {
            foreach (key, p; _apiProducts) {
                if (belongsTo(key, tenantId)) list ~= p;
            }
        }
        return list;
    }

    bool deleteApiProduct(string tenantId, string productId) {
        synchronized (_lock) {
            auto key = tenantKey(tenantId, productId);
            if (key in _apiProducts) { _apiProducts.remove(key); return true; }
        }
        return false;
    }

    // =====================================================================
    //  API Management — Policies
    // =====================================================================

    ISApiPolicy upsertApiPolicy(ISApiPolicy p) {
        synchronized (_lock) {
            auto key = tenantKey(p.tenantId, p.policyId);
            if (auto existing = key in _apiPolicies) {
                p.createdAt = existing.createdAt;
            }
            _apiPolicies[key] = p;
            return p;
        }
    }

    ISApiPolicy getApiPolicy(string tenantId, string policyId) {
        synchronized (_lock) {
            auto key = tenantKey(tenantId, policyId);
            if (auto v = key in _apiPolicies) return *v;
        }
        return ISApiPolicy.init;
    }

    ISApiPolicy[] listApiPolicies(string tenantId) {
        ISApiPolicy[] list;
        synchronized (_lock) {
            foreach (key, p; _apiPolicies) {
                if (belongsTo(key, tenantId)) list ~= p;
            }
        }
        return list;
    }

    bool deleteApiPolicy(string tenantId, string policyId) {
        synchronized (_lock) {
            auto key = tenantKey(tenantId, policyId);
            if (key in _apiPolicies) { _apiPolicies.remove(key); return true; }
        }
        return false;
    }

    // =====================================================================
    //  Event Management — Topics
    // =====================================================================

    ISEventTopic upsertEventTopic(ISEventTopic t) {
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

    ISEventTopic getEventTopic(string tenantId, string topicId) {
        synchronized (_lock) {
            auto key = tenantKey(tenantId, topicId);
            if (auto v = key in _eventTopics) return *v;
        }
        return ISEventTopic.init;
    }

    ISEventTopic getEventTopicByName(string tenantId, string topicName) {
        synchronized (_lock) {
            foreach (_, t; _eventTopics) {
                if (t.tenantId == tenantId && t.topicName == topicName)
                    return t;
            }
        }
        return ISEventTopic.init;
    }

    ISEventTopic[] listEventTopics(string tenantId) {
        ISEventTopic[] list;
        synchronized (_lock) {
            foreach (key, t; _eventTopics) {
                if (belongsTo(key, tenantId)) list ~= t;
            }
        }
        return list;
    }

    bool deleteEventTopic(string tenantId, string topicId) {
        synchronized (_lock) {
            auto key = tenantKey(tenantId, topicId);
            if (key in _eventTopics) { _eventTopics.remove(key); return true; }
        }
        return false;
    }

    // =====================================================================
    //  Event Management — Subscriptions
    // =====================================================================

    ISEventSubscription upsertEventSubscription(ISEventSubscription s) {
        synchronized (_lock) {
            auto key = tenantKey(s.tenantId, s.subscriptionId);
            if (auto existing = key in _eventSubscriptions) {
                s.createdAt = existing.createdAt;
            }
            _eventSubscriptions[key] = s;
            return s;
        }
    }

    ISEventSubscription[] listEventSubscriptions(string tenantId) {
        ISEventSubscription[] list;
        synchronized (_lock) {
            foreach (_, s; _eventSubscriptions) {
                if (s.tenantId == tenantId) list ~= s;
            }
        }
        return list;
    }

    ISEventSubscription[] subscriptionsForTopic(string tenantId, string topicName) {
        ISEventSubscription[] list;
        synchronized (_lock) {
            foreach (_, s; _eventSubscriptions) {
                if (s.tenantId == tenantId && s.topicName == topicName && s.active)
                    list ~= s;
            }
        }
        return list;
    }

    bool deleteEventSubscription(string tenantId, string subscriptionId) {
        synchronized (_lock) {
            auto key = tenantKey(tenantId, subscriptionId);
            if (key in _eventSubscriptions) { _eventSubscriptions.remove(key); return true; }
        }
        return false;
    }

    // =====================================================================
    //  Open Connectors
    // =====================================================================

    ISConnector upsertConnector(ISConnector c) {
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

    ISConnector getConnector(string tenantId, string connectorId) {
        synchronized (_lock) {
            auto key = tenantKey(tenantId, connectorId);
            if (auto v = key in _connectors) return *v;
        }
        return ISConnector.init;
    }

    ISConnector[] listConnectors(string tenantId) {
        ISConnector[] list;
        synchronized (_lock) {
            foreach (key, c; _connectors) {
                if (belongsTo(key, tenantId)) list ~= c;
            }
        }
        return list;
    }

    bool deleteConnector(string tenantId, string connectorId) {
        synchronized (_lock) {
            auto key = tenantKey(tenantId, connectorId);
            if (key in _connectors) { _connectors.remove(key); return true; }
        }
        return false;
    }

    // =====================================================================
    //  Integration Advisor — Mappings
    // =====================================================================

    ISMapping upsertMapping(ISMapping m) {
        synchronized (_lock) {
            auto key = tenantKey(m.tenantId, m.mappingId);
            if (auto existing = key in _mappings) {
                m.createdAt = existing.createdAt;
            }
            _mappings[key] = m;
            return m;
        }
    }

    ISMapping getMapping(string tenantId, string mappingId) {
        synchronized (_lock) {
            auto key = tenantKey(tenantId, mappingId);
            if (auto v = key in _mappings) return *v;
        }
        return ISMapping.init;
    }

    ISMapping[] listMappings(string tenantId) {
        ISMapping[] list;
        synchronized (_lock) {
            foreach (key, m; _mappings) {
                if (belongsTo(key, tenantId)) list ~= m;
            }
        }
        return list;
    }

    bool deleteMapping(string tenantId, string mappingId) {
        synchronized (_lock) {
            auto key = tenantKey(tenantId, mappingId);
            if (key in _mappings) { _mappings.remove(key); return true; }
        }
        return false;
    }

    // =====================================================================
    //  Trading Partner Management — Partners
    // =====================================================================

    ISTradingPartner upsertTradingPartner(ISTradingPartner tp) {
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

    ISTradingPartner getTradingPartner(string tenantId, string partnerId) {
        synchronized (_lock) {
            auto key = tenantKey(tenantId, partnerId);
            if (auto v = key in _tradingPartners) return *v;
        }
        return ISTradingPartner.init;
    }

    ISTradingPartner[] listTradingPartners(string tenantId) {
        ISTradingPartner[] list;
        synchronized (_lock) {
            foreach (key, tp; _tradingPartners) {
                if (belongsTo(key, tenantId)) list ~= tp;
            }
        }
        return list;
    }

    bool deleteTradingPartner(string tenantId, string partnerId) {
        synchronized (_lock) {
            auto key = tenantKey(tenantId, partnerId);
            if (key in _tradingPartners) { _tradingPartners.remove(key); return true; }
        }
        return false;
    }

    // =====================================================================
    //  Trading Partner Management — Agreements
    // =====================================================================

    ISAgreement upsertAgreement(ISAgreement a) {
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

    ISAgreement getAgreement(string tenantId, string agreementId) {
        synchronized (_lock) {
            auto key = tenantKey(tenantId, agreementId);
            if (auto v = key in _agreements) return *v;
        }
        return ISAgreement.init;
    }

    ISAgreement[] listAgreements(string tenantId) {
        ISAgreement[] list;
        synchronized (_lock) {
            foreach (key, a; _agreements) {
                if (belongsTo(key, tenantId)) list ~= a;
            }
        }
        return list;
    }

    ISAgreement[] listAgreementsForPartner(string tenantId, string partnerId) {
        ISAgreement[] list;
        synchronized (_lock) {
            foreach (_, a; _agreements) {
                if (a.tenantId == tenantId && a.partnerId == partnerId)
                    list ~= a;
            }
        }
        return list;
    }

    bool deleteAgreement(string tenantId, string agreementId) {
        synchronized (_lock) {
            auto key = tenantKey(tenantId, agreementId);
            if (key in _agreements) { _agreements.remove(key); return true; }
        }
        return false;
    }

    // =====================================================================
    //  OData Provisioning
    // =====================================================================

    ISODataService upsertODataService(ISODataService svc) {
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

    ISODataService getODataService(string tenantId, string serviceId) {
        synchronized (_lock) {
            auto key = tenantKey(tenantId, serviceId);
            if (auto v = key in _odataServices) return *v;
        }
        return ISODataService.init;
    }

    ISODataService[] listODataServices(string tenantId) {
        ISODataService[] list;
        synchronized (_lock) {
            foreach (key, svc; _odataServices) {
                if (belongsTo(key, tenantId)) list ~= svc;
            }
        }
        return list;
    }

    bool deleteODataService(string tenantId, string serviceId) {
        synchronized (_lock) {
            auto key = tenantKey(tenantId, serviceId);
            if (key in _odataServices) { _odataServices.remove(key); return true; }
        }
        return false;
    }

    // =====================================================================
    //  Integration Assessment
    // =====================================================================

    ISAssessment upsertAssessment(ISAssessment a) {
        synchronized (_lock) {
            auto key = tenantKey(a.tenantId, a.assessmentId);
            if (auto existing = key in _assessments) {
                a.createdAt = existing.createdAt;
            }
            _assessments[key] = a;
            return a;
        }
    }

    ISAssessment getAssessment(string tenantId, string assessmentId) {
        synchronized (_lock) {
            auto key = tenantKey(tenantId, assessmentId);
            if (auto v = key in _assessments) return *v;
        }
        return ISAssessment.init;
    }

    ISAssessment[] listAssessments(string tenantId) {
        ISAssessment[] list;
        synchronized (_lock) {
            foreach (key, a; _assessments) {
                if (belongsTo(key, tenantId)) list ~= a;
            }
        }
        return list;
    }

    bool deleteAssessment(string tenantId, string assessmentId) {
        synchronized (_lock) {
            auto key = tenantKey(tenantId, assessmentId);
            if (key in _assessments) { _assessments.remove(key); return true; }
        }
        return false;
    }

    // =====================================================================
    //  Migration Assessment
    // =====================================================================

    ISMigration upsertMigration(ISMigration m) {
        synchronized (_lock) {
            auto key = tenantKey(m.tenantId, m.migrationId);
            if (auto existing = key in _migrations) {
                m.createdAt = existing.createdAt;
            }
            _migrations[key] = m;
            return m;
        }
    }

    ISMigration getMigration(string tenantId, string migrationId) {
        synchronized (_lock) {
            auto key = tenantKey(tenantId, migrationId);
            if (auto v = key in _migrations) return *v;
        }
        return ISMigration.init;
    }

    ISMigration[] listMigrations(string tenantId) {
        ISMigration[] list;
        synchronized (_lock) {
            foreach (key, m; _migrations) {
                if (belongsTo(key, tenantId)) list ~= m;
            }
        }
        return list;
    }

    bool deleteMigration(string tenantId, string migrationId) {
        synchronized (_lock) {
            auto key = tenantKey(tenantId, migrationId);
            if (key in _migrations) { _migrations.remove(key); return true; }
        }
        return false;
    }

    // =====================================================================
    //  Hybrid Integration
    // =====================================================================

    ISHybridRuntime upsertHybridRuntime(ISHybridRuntime r) {
        synchronized (_lock) {
            auto key = tenantKey(r.tenantId, r.runtimeId);
            if (auto existing = key in _hybridRuntimes) {
                r.createdAt = existing.createdAt;
            }
            _hybridRuntimes[key] = r;
            return r;
        }
    }

    ISHybridRuntime getHybridRuntime(string tenantId, string runtimeId) {
        synchronized (_lock) {
            auto key = tenantKey(tenantId, runtimeId);
            if (auto v = key in _hybridRuntimes) return *v;
        }
        return ISHybridRuntime.init;
    }

    ISHybridRuntime[] listHybridRuntimes(string tenantId) {
        ISHybridRuntime[] list;
        synchronized (_lock) {
            foreach (key, r; _hybridRuntimes) {
                if (belongsTo(key, tenantId)) list ~= r;
            }
        }
        return list;
    }

    bool deleteHybridRuntime(string tenantId, string runtimeId) {
        synchronized (_lock) {
            auto key = tenantKey(tenantId, runtimeId);
            if (key in _hybridRuntimes) { _hybridRuntimes.remove(key); return true; }
        }
        return false;
    }

    // =====================================================================
    //  Data Space Integration
    // =====================================================================

    ISDataAsset upsertDataAsset(ISDataAsset a) {
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

    ISDataAsset getDataAsset(string tenantId, string assetId) {
        synchronized (_lock) {
            auto key = tenantKey(tenantId, assetId);
            if (auto v = key in _dataAssets) return *v;
        }
        return ISDataAsset.init;
    }

    ISDataAsset[] listDataAssets(string tenantId) {
        ISDataAsset[] list;
        synchronized (_lock) {
            foreach (key, a; _dataAssets) {
                if (belongsTo(key, tenantId)) list ~= a;
            }
        }
        return list;
    }

    bool deleteDataAsset(string tenantId, string assetId) {
        synchronized (_lock) {
            auto key = tenantKey(tenantId, assetId);
            if (key in _dataAssets) { _dataAssets.remove(key); return true; }
        }
        return false;
    }

    // =====================================================================
    //  Content Packs
    // =====================================================================

    ISContentPack upsertContentPack(ISContentPack p) {
        synchronized (_lock) {
            auto key = tenantKey(p.tenantId, p.packId);
            if (auto existing = key in _contentPacks) {
                p.createdAt = existing.createdAt;
            }
            _contentPacks[key] = p;
            return p;
        }
    }

    ISContentPack getContentPack(string tenantId, string packId) {
        synchronized (_lock) {
            auto key = tenantKey(tenantId, packId);
            if (auto v = key in _contentPacks) return *v;
        }
        return ISContentPack.init;
    }

    ISContentPack[] listContentPacks(string tenantId) {
        ISContentPack[] list;
        synchronized (_lock) {
            foreach (key, p; _contentPacks) {
                if (belongsTo(key, tenantId)) list ~= p;
            }
        }
        return list;
    }

    bool deleteContentPack(string tenantId, string packId) {
        synchronized (_lock) {
            auto key = tenantKey(tenantId, packId);
            if (key in _contentPacks) { _contentPacks.remove(key); return true; }
        }
        return false;
    }

    // =====================================================================
    //  Helpers
    // =====================================================================

    private string tenantKey(string tenantId, string resourceId) {
        return tenantId ~ ":" ~ resourceId;
    }

    private bool belongsTo(string key, string tenantId) {
        return key.length > tenantId.length + 1
            && key[0 .. tenantId.length] == tenantId
            && key[tenantId.length] == ':';
    }
}
