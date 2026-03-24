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

  @property KYMConfig config() {
    return _config;
  }

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
    info["namespaces"] = cast(long)_store.namespaceCount();
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

    return Json.emptyObject
      .set("success", true)
      .set("namespace", saved.toJson());
  }

  Json updateNamespace(string name, Json request) {
    requireNamespace(name);
    auto ns = namespaceFromJson(name, request);
    ns.updatedAt = Clock.currTime();
    auto saved = _store.upsertNamespace(ns);

    return Json.emptyObject
      .set("success", true)
      .set("namespace", saved.toJson());
  }

  Json getNamespace(string name) {
    auto ns = _store.getNamespace(name);
    if (ns.name.length == 0)
      throw new KYMNotFoundException("Namespace", name);

    return Json.emptyObject
      .set("namespace", ns.toJson())
      .set("function_count", cast(long)_store.functionCount(name))
      .set("microservice_count", cast(long)_store.microserviceCount(name))
      .set("subscription_count", cast(long)_store.subscriptionCount(name));

  }

  Json listNamespaces() {
    auto nss = _store.listNamespaces();
    Json resources = Json.emptyArray;
    foreach (ref ns; nss)
      resources.appendArrayElement(ns.toJson());

    return Json.emptyObject
      .set("resources", resources)
      .set("total_results", cast(long)nss.length);
  }

  Json deleteNamespace(string name) {
    if (!_store.deleteNamespace(name))
      throw new KYMNotFoundException("Namespace", name);

    return Json.emptyObject
      .set("success", true)
      .set("message", "Namespace and all contained resources deleted")
      .set("name", name);
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
      throw new KYMQuotaExceededException("functions in namespace " ~ namespace, _config
          .maxFunctionsPerNamespace);

    if (!("source" in request) || !request["source"].isString)
      throw new KYMValidationException("source (string) is required");

    auto fn = functionFromJson(namespace, name, request);
    if (fn.timeoutSecs == 0)
      fn.timeoutSecs = _config.defaultFunctionTimeoutSecs;
    fn.status = KYMResourceStatus.RUNNING;
    _store.upsertFunction(fn);

    return Json.emptyObject
      .set("success", true)
      .set("function", fn.toJson());
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

    return Json.emptyObject
      .set("success", true)
      .set("function", fn.toJson());
  }

  Json getFunction(string namespace, string name) {
    requireNamespace(namespace);
    auto fn = _store.getFunction(namespace, name);
    if (fn.name.length == 0)
      throw new KYMNotFoundException("Function", name);

    return Json.emptyObject
      .set("function", fn.toJsonWithSource());
  }

  Json listFunctions(string namespace) {
    requireNamespace(namespace);
    auto fns = _store.listFunctions(namespace);
    Json resources = Json.emptyArray;
    foreach (ref fn; fns)
      resources.appendArrayElement(fn.toJson());

    return Json.emptyObject
      .set("resources", resources)
      .set("total_results", cast(long)fns.length);
  }

  Json deleteFunction(string namespace, string name) {
    requireNamespace(namespace);
    if (!_store.deleteFunction(namespace, name))
      throw new KYMNotFoundException("Function", name);

    return Json.emptyObject
      .set("success", true)
      .set("message", "Function deleted")
      .set("namespace", namespace)
      .set("name", name);
  }

  Json invokeFunction(string namespace, string name, Json request) {
    requireNamespace(namespace);
    auto fn = _store.getFunction(namespace, name);
    if (fn.name.length == 0)
      throw new KYMNotFoundException("Function", name);
    if (fn.status != KYMResourceStatus.RUNNING)
      throw new KYMValidationException("Function is not in running state: " ~ cast(string)fn.status);

    _store.incrementFunctionInvocations(namespace, name);

    return Json.emptyObject
      .set("function", name)
      .set("namespace", namespace)
      .set("status", "invoked")
      .set("runtime", cast(string)fn.runtime)
      .set("input", request)
      .set("result", Json.emptyObject);
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
      throw new KYMQuotaExceededException("microservices in namespace " ~ namespace, _config
          .maxMicroservicesPerNamespace);

    if (!("image" in request) || !request["image"].isString)
      throw new KYMValidationException("image (string) is required");

    auto ms = microserviceFromJson(namespace, name, request);
    if (ms.replicas == 0)
      ms.replicas = _config.defaultReplicas;
    ms.status = KYMResourceStatus.RUNNING;
    _store.upsertMicroservice(ms);

    return Json.emptyObject
      .set("success", true)
      .set("microservice", ms.toJson());
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

    return Json.emptyObject
      .set("success", true)
      .set("microservice", ms.toJson());
  }

  Json getMicroservice(string namespace, string name) {
    requireNamespace(namespace);
    auto ms = _store.getMicroservice(namespace, name);
    if (ms.name.length == 0)
      throw new KYMNotFoundException("Microservice", name);

    return Json.emptyObject
      .set("microservice", ms.toJson());
  }

  Json listMicroservices(string namespace) {
    requireNamespace(namespace);
    auto mss = _store.listMicroservices(namespace);
    Json resources = Json.emptyArray;
    foreach (ref ms; mss)
      resources.appendArrayElement(ms.toJson());

    return Json.emptyObject
      .set("resources", resources)
      .set("total_results", cast(long)mss.length);
  }

  Json deleteMicroservice(string namespace, string name) {
    requireNamespace(namespace);
    if (!_store.deleteMicroservice(namespace, name))
      throw new KYMNotFoundException("Microservice", name);

    return Json.emptyObject
      .set("success", true)
      .set("message", "Microservice deleted")
      .set("namespace", namespace)
      .set("name", name);

  }

  Json scaleMicroservice(string namespace, string name, Json request) {
    requireNamespace(namespace);
    auto ms = _store.getMicroservice(namespace, name);
    if (ms.name.length == 0)
      throw new KYMNotFoundException("Microservice", name);

    if ("replicas" in request && request["replicas"].isInteger)
      ms.replicas = cast(size_t)request["replicas"].get!long;
    if ("scale_policy" in request && request["scale_policy"].isString)
      ms.scalePolicy = parseScalePolicy(request["scale_policy"].get!string);
    if ("min_replicas" in request && request["min_replicas"].isInteger)
      ms.minReplicas = cast(size_t)request["min_replicas"].get!long;
    if ("max_replicas" in request && request["max_replicas"].isInteger)
      ms.maxReplicas = cast(size_t)request["max_replicas"].get!long;

    ms.updatedAt = Clock.currTime();
    _store.upsertMicroservice(ms);

    return Json.emptyObject
      .set("success", true)
      .set("microservice", ms.toJson());
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

    return Json.emptyObject
      .set("success", true)
      .set("event", ev.toJson())
      .set("subscriptions_matched", delivered);
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
      throw new KYMQuotaExceededException("subscriptions in namespace " ~ namespace, _config
          .maxSubscriptionsPerNamespace);

    auto sub = subscriptionFromJson(namespace, request);
    _store.upsertSubscription(sub);

    return Json.emptyObject
      .set("success", true)
      .set("subscription", sub.toJson());
  }

  Json getSubscription(string namespace, string id) {
    requireNamespace(namespace);
    auto sub = _store.getSubscription(namespace, id);
    if (sub.id.length == 0)
      throw new KYMNotFoundException("Subscription", id);

    return Json.emptyObject
      .set("subscription", sub.toJson());
  }

  Json listSubscriptions(string namespace) {
    requireNamespace(namespace);
    auto resources = _store.listSubscriptions(namespace).map!(sub => resources.appendArrayElement(sub.toJson())).array;

    return Json.emptyObject
      .set("resources", resources)
      .set("total_results", cast(long)resources.length);
  }

  Json deleteSubscription(string namespace, string id) {
    requireNamespace(namespace);
    if (!_store.deleteSubscription(namespace, id))
      throw new KYMNotFoundException("Subscription", id);

    return Json.emptyObject
      .set("success", true)
      .set("message", "Subscription deleted")
      .set("namespace", namespace)
      .set("id", id);
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

    return Json.emptyObject
      .set("success", true)
      .set("api_rule", rule.toJson());
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

    return Json.emptyObject
      .set("success", true)
      .set("api_rule", rule.toJson());
  }

  Json getApiRule(string namespace, string name) {
    requireNamespace(namespace);
    auto rule = _store.getApiRule(namespace, name);
    if (rule.name.length == 0)
      throw new KYMNotFoundException("API Rule", name);

    return Json.emptyObject
      .set("api_rule", rule.toJson());
  }

  Json listApiRules(string namespace) {
    requireNamespace(namespace);
    auto rules = _store.listApiRules(namespace);
    Json resources = Json.emptyArray;
    foreach (ref rule; rules)
      resources.appendArrayElement(rule.toJson());

    return Json.emptyObject
      .set("resources", resources)
      .set("total_results", cast(long)rules.length);
  }

  Json deleteApiRule(string namespace, string name) {
    requireNamespace(namespace);
    if (!_store.deleteApiRule(namespace, name))
      throw new KYMNotFoundException("API Rule", name);

    return Json.emptyObject
      .set("success", true)
      .set("message", "API Rule deleted")
      .set("namespace", namespace)
      .set("name", name);
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

    return Json.emptyObject
      .set("success", true)
      .set("service_binding", sb.toJson());
  }

  Json getServiceBinding(string namespace, string name) {
    requireNamespace(namespace);
    auto sb = _store.getServiceBinding(namespace, name);
    if (sb.name.length == 0)
      throw new KYMNotFoundException("Service Binding", name);

    return Json.emptyObject
      .set("service_binding", sb.toJsonWithCredentials());
  }

  Json listServiceBindings(string namespace) {
    requireNamespace(namespace);
    auto sbs = _store.listServiceBindings(namespace);
    Json resources = Json.emptyArray;
    foreach (ref sb; sbs)
      resources.appendArrayElement(sb.toJson());

    return Json.emptyObject
      .set("resources", resources)
      .set("total_results", cast(long)sbs.length);
  }

  Json deleteServiceBinding(string namespace, string name) {
    requireNamespace(namespace);
    if (!_store.deleteServiceBinding(namespace, name))
      throw new KYMNotFoundException("Service Binding", name);

    return Json.emptyObject
      .set("success", true)
      .set("message", "Service Binding deleted")
      .set("namespace", namespace)
      .set("name", name);
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
