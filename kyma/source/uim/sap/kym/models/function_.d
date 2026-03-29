module uim.sap.kym.models.function_;

import uim.sap.kym;

mixin(ShowModule!());

@safe:

/// A serverless Function deployed in a namespace
class KYMFunction : SAPEntity {
  mixin(SAPEntityTemplate!KYMFunction);

  string name;
  string namespace;
  KYMFunctionRuntime runtime = KYMFunctionRuntime.NODEJS20;
  string source;
  string handler = "main";
  Json deps;
  Json env;
  size_t timeoutSecs = 30;
  size_t minReplicas = 0;
  size_t maxReplicas = 5;
  KYMScalePolicy scalePolicy = KYMScalePolicy.AUTO_REQUESTS;
  KYMResourceStatus status = KYMResourceStatus.PENDING;
  string cpuRequest = "50m";
  string memoryRequest = "64Mi";
  string cpuLimit = "200m";
  string memoryLimit = "256Mi";
  Json labels;
  long invocationCount = 0;

  override Json toJson() {
    return super.toJson()
      .set("name", name)
      .set("namespace", namespace)
      .set("runtime", cast(string)runtime)
      .set("handler", handler)
      .set("timeout_secs", cast(long)timeoutSecs)
      .set("min_replicas", cast(long)minReplicas)
      .set("max_replicas", cast(long)maxReplicas)
      .set("scale_policy", cast(string)scalePolicy)
      .set("status", cast(string)status)
      .set("cpu_request", cpuRequest)
      .set("memory_request", memoryRequest)
      .set("cpu_limit", cpuLimit)
      .set("memory_limit", memoryLimit)
      .set("labels", labels)
      .set("invocation_count", invocationCount)
      .set("env", env);
  }

  Json toJsonWithSource() const {
    return toJson()
      .set("source", source)
      .set("deps", deps);
  }
}

KYMFunction functionFromJson(string namespace, string name, Json request) {
  KYMFunction fn = new KYMFunction(request);
  fn.name = name;
  fn.namespace = namespace;
  fn.createdAt = Clock.currTime();
  fn.updatedAt = fn.createdAt;
  fn.status = KYMResourceStatus.DEPLOYING;

  if ("runtime" in request && request["runtime"].isString)
    fn.runtime = parseRuntime(request["runtime"].get!string);
  if ("source" in request && request["source"].isString)
    fn.source = request["source"].getString;
  if ("handler" in request && request["handler"].isString)
    fn.handler = request["handler"].getString;
  if ("deps" in request)
    fn.deps = request["deps"];
  else
    fn.deps = Json.emptyObject;
  if ("env" in request && request["env"].isObject)
    fn.env = request["env"];
  else
    fn.env = Json.emptyObject;
  if ("timeout_secs" in request && request["timeout_secs"].isInteger)
    fn.timeoutSecs = cast(size_t)request["timeout_secs"].get!long;
  if ("min_replicas" in request && request["min_replicas"].isInteger)
    fn.minReplicas = cast(size_t)request["min_replicas"].get!long;
  if ("max_replicas" in request && request["max_replicas"].isInteger)
    fn.maxReplicas = cast(size_t)request["max_replicas"].get!long;
  if ("scale_policy" in request && request["scale_policy"].isString)
    fn.scalePolicy = parseScalePolicy(request["scale_policy"].get!string);
  if ("cpu_request" in request && request["cpu_request"].isString)
    fn.cpuRequest = request["cpu_request"].getString;
  if ("memory_request" in request && request["memory_request"].isString)
    fn.memoryRequest = request["memory_request"].getString;
  if ("cpu_limit" in request && request["cpu_limit"].isString)
    fn.cpuLimit = request["cpu_limit"].getString;
  if ("memory_limit" in request && request["memory_limit"].isString)
    fn.memoryLimit = request["memory_limit"].getString;
  if ("labels" in request && request["labels"].isObject)
    fn.labels = request["labels"];
  else
    fn.labels = Json.emptyObject;
  return fn;
}
