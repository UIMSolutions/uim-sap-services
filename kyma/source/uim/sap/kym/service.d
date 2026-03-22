module uim.sap.kym.service;

import std.datetime : Clock;

import vibe.data.json : Json;

import uim.sap.kym.config;
import uim.sap.kym.enumerations;
import uim.sap.kym.exceptions;
import uim.sap.kym.helpers;
import uim.sap.kym.models;
import uim.sap.kym.store;

/**
 * Main service class for the Kyma Runtime.
 *
 * Manages namespaces, serverless functions, containerized microservices,
 * event subscriptions, API rules, service bindings, and provides
 * consumption-based metrics.
 */
class KYMService : SAPService {
    mixin(SAPServiceTemplate!KYMService);

    private KYMStore _store;
    private KYMConfig _config;

    this(KYMConfig config) {
        super(config);
        _config = config;
        _store = new KYMStore;
    }

    @property KYMConfig config() { return _config; }

    override Json health() {
        Json info = super.health();
        auto m = _store.metrics();
        info["namespaces"] = m.totalNamespaces;
        info["functions"] = m.totalFunctions;
        info["microservices"] = m.totalMicroservices;
        return info;
    }

    override Json ready() {
        Json info = super.ready();
        info["namespaces"] = cast(long) _store.namespaceCount();
        return info;
    }

    Json getMetrics() {
        return _store.metrics().toJson();
    }

    // ══════════════════════════════════════
    //  Namespaces
    // ══════════════════════════════════════

    Json createNamespace(string name, Json request) {
        validateResourceName(name);
        if (_store.hasNamespace(name))
            throw new KYMConflictException("Namespace", name);
        if (_store.namespaceCount() >= _config.maxNamespaces)
            throw new KYMQuotaExceededException("namespaces", _config.maxNamespaces);

        auto ns = namespaceFromJson(name, request);
        auto saved = _store.upsertNamespace(ns);

        Json payload = Json.emptyObject;
        payload["success"] = true;
        payload["namespace"] = saved.toJson();
        return payload;
    }

    Json updateNamespace(string name, Json request) {
        requireNamespace(name);
        auto ns = namespaceFromJson(name, request);
        ns.updatedAt = Clock.currTime();
        auto saved = _store.upsertNamespace(ns);

        Json payload = Json.emptyObject;
        payload["success"] = true;
        payload["namespace"] = saved.toJson();
        return payload;
    }

    Json getNamespace(string name) {
        auto ns = _store.getNamespace(name);
        if (ns.name.length == 0)
            throw new KYMNotFoundException("Namespace", name);

        Json payload = Json.emptyObject;
        payload["namespace"] = ns.toJson();
        payload["function_count"] = cast(long) _store.functionCount(name);
        payload["microservice_count"] = cast(long) _store.microserviceCount(name);
        payload["subscription_count"] = cast(long) _store.subscriptionCount(name);
        return payload;
    }

    Json listNamespaces() {
        auto nss = _store.listNamespaces();
        Json resources = Json.emptyArray;
        foreach (ref ns; nss)
            resources.appendArrayElement(ns.toJson());

        return Json.emptyObject
            .set("resources", resources)
            .set("total_results", cast(long) nss.length);
    }

    Json deleteNamespace(string name) {
        if (!_store.deleteNamespace(name))
            throw new KYMNotFoundException("Namespace", name);

        Json payload = Json.emptyObject;
        payload["success"] = true;
        payload["message"] = "Namespace and all contained resources deleted";
        payload["name"] = name;
        return payload;
    }

    // ══════════════════════════════════════
    //  Serverless Functions
    // ══════════════════════════════════════

    Json createFunction(string namespace, string name, Json request) {
        requireNamespace(namespace);
        validateResourceName(name);

        if (_store.getFunction(namespace, name).name.length > 0)
            throw new KYMConflictException("Function", name);
        if (_store.functionCount(namespace) >= _config.maxFunctionsPerNamespace)
            throw new KYMQuotaExceededException("functions in namespace " ~ namespace, _config.maxFunctionsPerNamespace);

        if (!("source" in request) || !request["source"].isString)
            throw new KYMValidationException("source (string) is required");

        auto fn = functionFromJson(namespace, name, request);
        if (fn.timeoutSecs == 0)
            fn.timeoutSecs = _config.defaultFunctionTimeoutSecs;
        fn.status = KYMResourceStatus.RUNNING;
        _store.upsertFunction(fn);

        Json payload = Json.emptyObject;
        payload["success"] = true;
        payload["function"] = fn.toJson();
        return payload;
    }

    Json updateFunction(string namespace, string name, Json request) {
        requireNamespace(namespace);
        auto existing = _store.getFunction(namespace, name);
        if (existing.name.length == 0)
            throw new KYMNotFoundException("Function", name);

        auto fn = functionFromJson(namespace, name, request);
        fn.createdAt = existing.createdAt;
        fn.invocationCount = existing.invocationCount;
        fn.status = KYMResourceStatus.RUNNING;
        fn.updatedAt = Clock.currTime();
        _store.upsertFunction(fn);

        Json payload = Json.emptyObject;
        payload["success"] = true;
        payload["function"] = fn.toJson();
        return payload;
    }

    Json getFunction(string namespace, string name) {
        requireNamespace(namespace);
        auto fn = _store.getFunction(namespace, name);
        if (fn.name.length == 0)
            throw new KYMNotFoundException("Function", name);

        Json payload = Json.emptyObject;
        payload["function"] = fn.toJsonWithSource();
        return payload;
    }

    Json listFunctions(string namespace) {
        requireNamespace(namespace);
        auto fns = _store.listFunctions(namespace);
        Json resources = Json.emptyArray;
        foreach (ref fn; fns)
            resources.appendArrayElement(fn.toJson());

        Json payload = Json.emptyObject;
        payload["resources"] = resources;
        payload["total_results"] = cast(long) fns.length;
        return payload;
    }

    Json deleteFunction(string namespace, string name) {
        requireNamespace(namespace);
        if (!_store.deleteFunction(namespace, name))
            throw new KYMNotFoundException("Function", name);

        Json payload = Json.emptyObject;
        payload["success"] = true;
        payload["message"] = "Function deleted";
        payload["namespace"] = namespace;
        payload["name"] = name;
        return payload;
    }

    Json invokeFunction(string namespace, string name, Json request) {
        requireNamespace(namespace);
        auto fn = _store.getFunction(namespace, name);
        if (fn.name.length == 0)
            throw new KYMNotFoundException("Function", name);
        if (fn.status != KYMResourceStatus.RUNNING)
            throw new KYMValidationException("Function is not in running state: " ~ cast(string) fn.status);

        _store.incrementFunctionInvocations(namespace, name);

        Json payload = Json.emptyObject;
        payload["function"] = name;
        payload["namespace"] = namespace;
        payload["status"] = "invoked";
        payload["runtime"] = cast(string) fn.runtime;
        payload["input"] = request;
        payload["result"] = Json.emptyObject;
        return payload;
    }

    // ══════════════════════════════════════
    //  Microservices
    // ══════════════════════════════════════

    Json createMicroservice(string namespace, string name, Json request) {
        requireNamespace(namespace);
        validateResourceName(name);

        if (_store.getMicroservice(namespace, name).name.length > 0)
            throw new KYMConflictException("Microservice", name);
        if (_store.microserviceCount(namespace) >= _config.maxMicroservicesPerNamespace)
            throw new KYMQuotaExceededException("microservices in namespace " ~ namespace, _config.maxMicroservicesPerNamespace);

        if (!("image" in request) || !request["image"].isString)
            throw new KYMValidationException("image (string) is required");

        auto ms = microserviceFromJson(namespace, name, request);
        if (ms.replicas == 0)
            ms.replicas = _config.defaultReplicas;
        ms.status = KYMResourceStatus.RUNNING;
        _store.upsertMicroservice(ms);

        Json payload = Json.emptyObject;
        payload["success"] = true;
        payload["microservice"] = ms.toJson();
        return payload;
    }

    Json updateMicroservice(string namespace, string name, Json request) {
        requireNamespace(namespace);
        auto existing = _store.getMicroservice(namespace, name);
        if (existing.name.length == 0)
            throw new KYMNotFoundException("Microservice", name);

        auto ms = microserviceFromJson(namespace, name, request);
        ms.createdAt = existing.createdAt;
        ms.status = KYMResourceStatus.RUNNING;
        ms.updatedAt = Clock.currTime();
        _store.upsertMicroservice(ms);

        Json payload = Json.emptyObject;
        payload["success"] = true;
        payload["microservice"] = ms.toJson();
        return payload;
    }

    Json getMicroservice(string namespace, string name) {
        requireNamespace(namespace);
        auto ms = _store.getMicroservice(namespace, name);
        if (ms.name.length == 0)
            throw new KYMNotFoundException("Microservice", name);

        Json payload = Json.emptyObject;
        payload["microservice"] = ms.toJson();
        return payload;
    }

    Json listMicroservices(string namespace) {
        requireNamespace(namespace);
        auto mss = _store.listMicroservices(namespace);
        Json resources = Json.emptyArray;
        foreach (ref ms; mss)
            resources.appendArrayElement(ms.toJson());

        Json payload = Json.emptyObject;
        payload["resources"] = resources;
        payload["total_results"] = cast(long) mss.length;
        return payload;
    }

    Json deleteMicroservice(string namespace, string name) {
        requireNamespace(namespace);
        if (!_store.deleteMicroservice(namespace, name))
            throw new KYMNotFoundException("Microservice", name);

        Json payload = Json.emptyObject;
        payload["success"] = true;
        payload["message"] = "Microservice deleted";
        payload["namespace"] = namespace;
        payload["name"] = name;
        return payload;
    }

    Json scaleMicroservice(string namespace, string name, Json request) {
        requireNamespace(namespace);
        auto ms = _store.getMicroservice(namespace, name);
        if (ms.name.length == 0)
            throw new KYMNotFoundException("Microservice", name);

        if ("replicas" in request && request["replicas"].isInteger)
            ms.replicas = cast(size_t) request["replicas"].get!long;
        if ("scale_policy" in request && request["scale_policy"].isString)
            ms.scalePolicy = parseScalePolicy(request["scale_policy"].get!string);
        if ("min_replicas" in request && request["min_replicas"].isInteger)
            ms.minReplicas = cast(size_t) request["min_replicas"].get!long;
        if ("max_replicas" in request && request["max_replicas"].isInteger)
            ms.maxReplicas = cast(size_t) request["max_replicas"].get!long;

        ms.updatedAt = Clock.currTime();
        _store.upsertMicroservice(ms);

        Json payload = Json.emptyObject;
        payload["success"] = true;
        payload["microservice"] = ms.toJson();
        return payload;
    }

    // ══════════════════════════════════════
    //  Events (Event-driven architecture)
    // ══════════════════════════════════════

    Json publishEvent(string namespace, Json request) {
        requireNamespace(namespace);
        if (!("event_type" in request) || !request["event_type"].isString)
            throw new KYMValidationException("event_type (string) is required");

        auto ev = eventFromJson(namespace, request);
        _store.recordEvent(ev);

        // Deliver to matching subscriptions
        auto subs = _store.matchSubscriptions(namespace, ev.eventType);
        long delivered = 0;
        foreach (ref sub; subs) {
            _store.incrementDelivered(namespace, sub.id);
            delivered++;
        }

        Json payload = Json.emptyObject;
        payload["success"] = true;
        payload["event"] = ev.toJson();
        payload["subscriptions_matched"] = delivered;
        return payload;
    }

    // ══════════════════════════════════════
    //  Subscriptions
    // ══════════════════════════════════════

    Json createSubscription(string namespace, Json request) {
        requireNamespace(namespace);
        if (!("event_type" in request) || !request["event_type"].isString)
            throw new KYMValidationException("event_type (string) is required");
        if (!("consumer_name" in request) || !request["consumer_name"].isString)
            throw new KYMValidationException("consumer_name (string) is required");

        if (_store.subscriptionCount(namespace) >= _config.maxSubscriptionsPerNamespace)
            throw new KYMQuotaExceededException("subscriptions in namespace " ~ namespace, _config.maxSubscriptionsPerNamespace);

        auto sub = subscriptionFromJson(namespace, request);
        _store.upsertSubscription(sub);

        Json payload = Json.emptyObject;
        payload["success"] = true;
        payload["subscription"] = sub.toJson();
        return payload;
    }

    Json getSubscription(string namespace, string id) {
        requireNamespace(namespace);
        auto sub = _store.getSubscription(namespace, id);
        if (sub.id.length == 0)
            throw new KYMNotFoundException("Subscription", id);

        Json payload = Json.emptyObject;
        payload["subscription"] = sub.toJson();
        return payload;
    }

    Json listSubscriptions(string namespace) {
        requireNamespace(namespace);
        auto subs = _store.listSubscriptions(namespace);
        Json resources = Json.emptyArray;
        foreach (ref sub; subs)
            resources.appendArrayElement(sub.toJson());

        Json payload = Json.emptyObject;
        payload["resources"] = resources;
        payload["total_results"] = cast(long) subs.length;
        return payload;
    }

    Json deleteSubscription(string namespace, string id) {
        requireNamespace(namespace);
        if (!_store.deleteSubscription(namespace, id))
            throw new KYMNotFoundException("Subscription", id);

        Json payload = Json.emptyObject;
        payload["success"] = true;
        payload["message"] = "Subscription deleted";
        payload["namespace"] = namespace;
        payload["id"] = id;
        return payload;
    }

    // ══════════════════════════════════════
    //  API Rules
    // ══════════════════════════════════════

    Json createApiRule(string namespace, string name, Json request) {
        requireNamespace(namespace);
        validateResourceName(name);

        if (_store.getApiRule(namespace, name).name.length > 0)
            throw new KYMConflictException("API Rule", name);
        if (!("service_name" in request) || !request["service_name"].isString)
            throw new KYMValidationException("service_name (string) is required");

        auto rule = apiRuleFromJson(namespace, name, request);
        _store.upsertApiRule(rule);

        Json payload = Json.emptyObject;
        payload["success"] = true;
        payload["api_rule"] = rule.toJson();
        return payload;
    }

    Json updateApiRule(string namespace, string name, Json request) {
        requireNamespace(namespace);
        auto existing = _store.getApiRule(namespace, name);
        if (existing.name.length == 0)
            throw new KYMNotFoundException("API Rule", name);

        auto rule = apiRuleFromJson(namespace, name, request);
        rule.createdAt = existing.createdAt;
        rule.updatedAt = Clock.currTime();
        _store.upsertApiRule(rule);

        Json payload = Json.emptyObject;
        payload["success"] = true;
        payload["api_rule"] = rule.toJson();
        return payload;
    }

    Json getApiRule(string namespace, string name) {
        requireNamespace(namespace);
        auto rule = _store.getApiRule(namespace, name);
        if (rule.name.length == 0)
            throw new KYMNotFoundException("API Rule", name);

        Json payload = Json.emptyObject;
        payload["api_rule"] = rule.toJson();
        return payload;
    }

    Json listApiRules(string namespace) {
        requireNamespace(namespace);
        auto rules = _store.listApiRules(namespace);
        Json resources = Json.emptyArray;
        foreach (ref rule; rules)
            resources.appendArrayElement(rule.toJson());

        Json payload = Json.emptyObject;
        payload["resources"] = resources;
        payload["total_results"] = cast(long) rules.length;
        return payload;
    }

    Json deleteApiRule(string namespace, string name) {
        requireNamespace(namespace);
        if (!_store.deleteApiRule(namespace, name))
            throw new KYMNotFoundException("API Rule", name);

        Json payload = Json.emptyObject;
        payload["success"] = true;
        payload["message"] = "API Rule deleted";
        payload["namespace"] = namespace;
        payload["name"] = name;
        return payload;
    }

    // ══════════════════════════════════════
    //  Service Bindings
    // ══════════════════════════════════════

    Json createServiceBinding(string namespace, string name, Json request) {
        requireNamespace(namespace);
        validateResourceName(name);

        if (_store.getServiceBinding(namespace, name).name.length > 0)
            throw new KYMConflictException("Service Binding", name);
        if (!("service_instance_name" in request) || !request["service_instance_name"].isString)
            throw new KYMValidationException("service_instance_name (string) is required");
        if (!("consumer_name" in request) || !request["consumer_name"].isString)
            throw new KYMValidationException("consumer_name (string) is required");

        auto sb = serviceBindingFromJson(namespace, name, request);
        _store.upsertServiceBinding(sb);

        Json payload = Json.emptyObject;
        payload["success"] = true;
        payload["service_binding"] = sb.toJson();
        return payload;
    }

    Json getServiceBinding(string namespace, string name) {
        requireNamespace(namespace);
        auto sb = _store.getServiceBinding(namespace, name);
        if (sb.name.length == 0)
            throw new KYMNotFoundException("Service Binding", name);

        Json payload = Json.emptyObject;
        payload["service_binding"] = sb.toJsonWithCredentials();
        return payload;
    }

    Json listServiceBindings(string namespace) {
        requireNamespace(namespace);
        auto sbs = _store.listServiceBindings(namespace);
        Json resources = Json.emptyArray;
        foreach (ref sb; sbs)
            resources.appendArrayElement(sb.toJson());

        Json payload = Json.emptyObject;
        payload["resources"] = resources;
        payload["total_results"] = cast(long) sbs.length;
        return payload;
    }

    Json deleteServiceBinding(string namespace, string name) {
        requireNamespace(namespace);
        if (!_store.deleteServiceBinding(namespace, name))
            throw new KYMNotFoundException("Service Binding", name);

        Json payload = Json.emptyObject;
        payload["success"] = true;
        payload["message"] = "Service Binding deleted";
        payload["namespace"] = namespace;
        payload["name"] = name;
        return payload;
    }

    // ── Private helpers ──

    private void requireNamespace(string name) {
        if (!_store.hasNamespace(name))
            throw new KYMNotFoundException("Namespace", name);
    }

    private void validateResourceName(string name) {
        if (!isValidResourceName(name))
            throw new KYMValidationException(
                "Invalid resource name '" ~ name ~ "': must be lowercase alphanumeric with hyphens, 1-253 chars"
            );
    }
}
