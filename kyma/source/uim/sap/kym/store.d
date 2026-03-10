module uim.sap.kym.store;

import core.sync.mutex : Mutex;

import uim.sap.kym.helpers;
import uim.sap.kym.models;

/**
 * In-memory store for the Kyma runtime.
 *
 * Stores namespaces, functions, microservices, event subscriptions,
 * API rules, service bindings, and published events.
 * Thread-safe via mutex synchronization.
 */
class KYMStore : SAPStore {
    private KYMNamespace[string] _namespaces;
    private KYMFunction[string] _functions;
    private KYMMicroservice[string] _microservices;
    private KYMSubscription[string] _subscriptions;
    private KYMApiRule[string] _apiRules;
    private KYMServiceBinding[string] _bindings;
    private KYMEvent[][] _eventLog;
    private long _eventsPublished;
    private long _eventsDelivered;
    private long _functionInvocations;
    private Mutex _lock;

    this() {
        _lock = new Mutex;
    }

    // ── Namespace CRUD ──

    KYMNamespace upsertNamespace(KYMNamespace ns) {
        synchronized (_lock) {
            if (auto existing = ns.name in _namespaces)
                ns.createdAt = existing.createdAt;
            _namespaces[ns.name] = ns;
            return ns;
        }
    }

    bool deleteNamespace(string name) {
        synchronized (_lock) {
            if ((name in _namespaces) is null)
                return false;
            _namespaces.remove(name);
            // Cascade delete all resources in the namespace
            removeByPrefix(_functions, name ~ "/");
            removeByPrefix(_microservices, name ~ "/");
            removeByPrefix(_subscriptions, name ~ "/");
            removeByPrefix(_apiRules, name ~ "/");
            removeByPrefix(_bindings, name ~ "/");
            return true;
        }
    }

    bool hasNamespace(string name) {
        synchronized (_lock) {
            return (name in _namespaces) !is null;
        }
    }

    KYMNamespace getNamespace(string name) {
        synchronized (_lock) {
            if (auto ns = name in _namespaces)
                return *ns;
        }
        return KYMNamespace.init;
    }

    KYMNamespace[] listNamespaces() {
        KYMNamespace[] values;
        synchronized (_lock) {
            foreach (item; _namespaces.byValue)
                values ~= item;
        }
        return values;
    }

    size_t namespaceCount() {
        synchronized (_lock) { return _namespaces.length; }
    }

    // ── Function CRUD ──

    void upsertFunction(KYMFunction fn) {
        synchronized (_lock) {
            auto key = nsKey(fn.namespace, fn.name);
            if (auto existing = key in _functions)
                fn.createdAt = existing.createdAt;
            _functions[key] = fn;
        }
    }

    bool deleteFunction(string namespace, string name) {
        synchronized (_lock) {
            auto key = nsKey(namespace, name);
            if ((key in _functions) is null) return false;
            _functions.remove(key);
            return true;
        }
    }

    KYMFunction getFunction(string namespace, string name) {
        synchronized (_lock) {
            if (auto fn = nsKey(namespace, name) in _functions)
                return *fn;
        }
        return KYMFunction.init;
    }

    KYMFunction[] listFunctions(string namespace) {
        KYMFunction[] values;
        synchronized (_lock) {
            foreach (ref fn; _functions.byValue)
                if (fn.namespace == namespace)
                    values ~= fn;
        }
        return values;
    }

    size_t functionCount(string namespace) {
        size_t count;
        synchronized (_lock) {
            foreach (ref fn; _functions.byValue)
                if (fn.namespace == namespace)
                    count++;
        }
        return count;
    }

    size_t totalFunctions() {
        synchronized (_lock) { return _functions.length; }
    }

    void incrementFunctionInvocations(string namespace, string name) {
        synchronized (_lock) {
            auto key = nsKey(namespace, name);
            if (auto fn = key in _functions) {
                fn.invocationCount++;
                _functionInvocations++;
            }
        }
    }

    // ── Microservice CRUD ──

    void upsertMicroservice(KYMMicroservice ms) {
        synchronized (_lock) {
            auto key = nsKey(ms.namespace, ms.name);
            if (auto existing = key in _microservices)
                ms.createdAt = existing.createdAt;
            _microservices[key] = ms;
        }
    }

    bool deleteMicroservice(string namespace, string name) {
        synchronized (_lock) {
            auto key = nsKey(namespace, name);
            if ((key in _microservices) is null) return false;
            _microservices.remove(key);
            return true;
        }
    }

    KYMMicroservice getMicroservice(string namespace, string name) {
        synchronized (_lock) {
            if (auto ms = nsKey(namespace, name) in _microservices)
                return *ms;
        }
        return KYMMicroservice.init;
    }

    KYMMicroservice[] listMicroservices(string namespace) {
        KYMMicroservice[] values;
        synchronized (_lock) {
            foreach (ref ms; _microservices.byValue)
                if (ms.namespace == namespace)
                    values ~= ms;
        }
        return values;
    }

    size_t microserviceCount(string namespace) {
        size_t count;
        synchronized (_lock) {
            foreach (ref ms; _microservices.byValue)
                if (ms.namespace == namespace)
                    count++;
        }
        return count;
    }

    size_t totalMicroservices() {
        synchronized (_lock) { return _microservices.length; }
    }

    // ── Subscription CRUD ──

    void upsertSubscription(KYMSubscription sub) {
        synchronized (_lock) {
            auto key = nsKey(sub.namespace, sub.id);
            _subscriptions[key] = sub;
        }
    }

    bool deleteSubscription(string namespace, string id) {
        synchronized (_lock) {
            auto key = nsKey(namespace, id);
            if ((key in _subscriptions) is null) return false;
            _subscriptions.remove(key);
            return true;
        }
    }

    KYMSubscription getSubscription(string namespace, string id) {
        synchronized (_lock) {
            if (auto sub = nsKey(namespace, id) in _subscriptions)
                return *sub;
        }
        return KYMSubscription.init;
    }

    KYMSubscription[] listSubscriptions(string namespace) {
        KYMSubscription[] values;
        synchronized (_lock) {
            foreach (ref sub; _subscriptions.byValue)
                if (sub.namespace == namespace)
                    values ~= sub;
        }
        return values;
    }

    /// Find subscriptions matching an event type (within a namespace)
    KYMSubscription[] matchSubscriptions(string namespace, string eventType) {
        KYMSubscription[] values;
        synchronized (_lock) {
            foreach (ref sub; _subscriptions.byValue) {
                if (sub.namespace == namespace && sub.active && sub.eventType == eventType)
                    values ~= sub;
            }
        }
        return values;
    }

    size_t subscriptionCount(string namespace) {
        size_t count;
        synchronized (_lock) {
            foreach (ref sub; _subscriptions.byValue)
                if (sub.namespace == namespace)
                    count++;
        }
        return count;
    }

    size_t totalSubscriptions() {
        synchronized (_lock) { return _subscriptions.length; }
    }

    void incrementDelivered(string namespace, string subId) {
        synchronized (_lock) {
            auto key = nsKey(namespace, subId);
            if (auto sub = key in _subscriptions) {
                sub.deliveredCount++;
                _eventsDelivered++;
            }
        }
    }

    // ── API Rule CRUD ──

    void upsertApiRule(KYMApiRule rule) {
        synchronized (_lock) {
            auto key = nsKey(rule.namespace, rule.name);
            if (auto existing = key in _apiRules)
                rule.createdAt = existing.createdAt;
            _apiRules[key] = rule;
        }
    }

    bool deleteApiRule(string namespace, string name) {
        synchronized (_lock) {
            auto key = nsKey(namespace, name);
            if ((key in _apiRules) is null) return false;
            _apiRules.remove(key);
            return true;
        }
    }

    KYMApiRule getApiRule(string namespace, string name) {
        synchronized (_lock) {
            if (auto rule = nsKey(namespace, name) in _apiRules)
                return *rule;
        }
        return KYMApiRule.init;
    }

    KYMApiRule[] listApiRules(string namespace) {
        KYMApiRule[] values;
        synchronized (_lock) {
            foreach (ref rule; _apiRules.byValue)
                if (rule.namespace == namespace)
                    values ~= rule;
        }
        return values;
    }

    size_t totalApiRules() {
        synchronized (_lock) { return _apiRules.length; }
    }

    // ── Service Binding CRUD ──

    void upsertServiceBinding(KYMServiceBinding sb) {
        synchronized (_lock) {
            auto key = nsKey(sb.namespace, sb.name);
            if (auto existing = key in _bindings)
                sb.createdAt = existing.createdAt;
            _bindings[key] = sb;
        }
    }

    bool deleteServiceBinding(string namespace, string name) {
        synchronized (_lock) {
            auto key = nsKey(namespace, name);
            if ((key in _bindings) is null) return false;
            _bindings.remove(key);
            return true;
        }
    }

    KYMServiceBinding getServiceBinding(string namespace, string name) {
        synchronized (_lock) {
            if (auto sb = nsKey(namespace, name) in _bindings)
                return *sb;
        }
        return KYMServiceBinding.init;
    }

    KYMServiceBinding[] listServiceBindings(string namespace) {
        KYMServiceBinding[] values;
        synchronized (_lock) {
            foreach (ref sb; _bindings.byValue)
                if (sb.namespace == namespace)
                    values ~= sb;
        }
        return values;
    }

    size_t totalServiceBindings() {
        synchronized (_lock) { return _bindings.length; }
    }

    // ── Events ──

    void recordEvent(KYMEvent ev) {
        synchronized (_lock) {
            _eventsPublished++;
        }
    }

    long eventsPublished() {
        synchronized (_lock) { return _eventsPublished; }
    }

    long eventsDelivered() {
        synchronized (_lock) { return _eventsDelivered; }
    }

    long functionInvocations() {
        synchronized (_lock) { return _functionInvocations; }
    }

    // ── Metrics ──

    KYMMetrics metrics() {
        KYMMetrics m;
        synchronized (_lock) {
            m.totalNamespaces = cast(long) _namespaces.length;
            m.totalFunctions = cast(long) _functions.length;
            m.totalMicroservices = cast(long) _microservices.length;
            m.totalSubscriptions = cast(long) _subscriptions.length;
            m.totalApiRules = cast(long) _apiRules.length;
            m.totalServiceBindings = cast(long) _bindings.length;
            m.totalEventsPublished = _eventsPublished;
            m.totalEventsDelivered = _eventsDelivered;
            m.totalFunctionInvocations = _functionInvocations;
        }
        return m;
    }

    // ── Private helpers ──

    private void removeByPrefix(T)(ref T[string] map, string prefix) {
        string[] keysToRemove;
        foreach (key; map.keys) {
            if (key.length >= prefix.length && key[0 .. prefix.length] == prefix)
                keysToRemove ~= key;
        }
        foreach (key; keysToRemove)
            map.remove(key);
    }
}
