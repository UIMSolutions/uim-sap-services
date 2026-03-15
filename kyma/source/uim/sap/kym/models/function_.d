module uim.sap.kym.models.function_;

import uim.sap.kym;

mixin(ShowModule!());

@safe:

/// A serverless Function deployed in a namespace
struct KYMFunction {
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
    SysTime createdAt;
    SysTime updatedAt;

    override Json toJson()  {
        Json payload = Json.emptyObject;
        payload["name"] = name;
        payload["namespace"] = namespace;
        payload["runtime"] = cast(string) runtime;
        payload["handler"] = handler;
        payload["timeout_secs"] = cast(long) timeoutSecs;
        payload["min_replicas"] = cast(long) minReplicas;
        payload["max_replicas"] = cast(long) maxReplicas;
        payload["scale_policy"] = cast(string) scalePolicy;
        payload["status"] = cast(string) status;
        payload["cpu_request"] = cpuRequest;
        payload["memory_request"] = memoryRequest;
        payload["cpu_limit"] = cpuLimit;
        payload["memory_limit"] = memoryLimit;
        payload["labels"] = labels;
        payload["invocation_count"] = invocationCount;
        payload["env"] = env;
        payload["created_at"] = createdAt.toISOExtString();
        payload["updated_at"] = updatedAt.toISOExtString();
        return payload;
    }

    Json toJsonWithSource() const {
        Json payload = toJson();
        payload["source"] = source;
        payload["deps"] = deps;
        return payload;
    }
}

KYMFunction functionFromJson(string namespace, string name, Json request) {
    KYMFunction fn;
    fn.name = name;
    fn.namespace = namespace;
    fn.createdAt = Clock.currTime();
    fn.updatedAt = fn.createdAt;
    fn.status = KYMResourceStatus.DEPLOYING;

    if ("runtime" in request && request["runtime"].isString)
        fn.runtime = parseRuntime(request["runtime"].get!string);
    if ("source" in request && request["source"].isString)
        fn.source = request["source"].get!string;
    if ("handler" in request && request["handler"].isString)
        fn.handler = request["handler"].get!string;
    if ("deps" in request)
        fn.deps = request["deps"];
    else
        fn.deps = Json.emptyObject;
    if ("env" in request && request["env"].isObject)
        fn.env = request["env"];
    else
        fn.env = Json.emptyObject;
    if ("timeout_secs" in request && request["timeout_secs"].isInteger)
        fn.timeoutSecs = cast(size_t) request["timeout_secs"].get!long;
    if ("min_replicas" in request && request["min_replicas"].isInteger)
        fn.minReplicas = cast(size_t) request["min_replicas"].get!long;
    if ("max_replicas" in request && request["max_replicas"].isInteger)
        fn.maxReplicas = cast(size_t) request["max_replicas"].get!long;
    if ("scale_policy" in request && request["scale_policy"].isString)
        fn.scalePolicy = parseScalePolicy(request["scale_policy"].get!string);
    if ("cpu_request" in request && request["cpu_request"].isString)
        fn.cpuRequest = request["cpu_request"].get!string;
    if ("memory_request" in request && request["memory_request"].isString)
        fn.memoryRequest = request["memory_request"].get!string;
    if ("cpu_limit" in request && request["cpu_limit"].isString)
        fn.cpuLimit = request["cpu_limit"].get!string;
    if ("memory_limit" in request && request["memory_limit"].isString)
        fn.memoryLimit = request["memory_limit"].get!string;
    if ("labels" in request && request["labels"].isObject)
        fn.labels = request["labels"];
    else
        fn.labels = Json.emptyObject;
    return fn;
}
