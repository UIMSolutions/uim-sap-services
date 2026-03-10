module uim.sap.kym.models.microservice;

import uim.sap.kym;

mixin(ShowModule!());

@safe:

/// A containerized microservice deployed in a namespace
struct KYMMicroservice {
    string name;
    string namespace;
    string image;
    ushort port = 8080;
    KYMProtocol protocol = KYMProtocol.HTTP;
    size_t replicas = 1;
    size_t minReplicas = 1;
    size_t maxReplicas = 10;
    KYMScalePolicy scalePolicy = KYMScalePolicy.MANUAL;
    KYMResourceStatus status = KYMResourceStatus.PENDING;
    string cpuRequest = "100m";
    string memoryRequest = "128Mi";
    string cpuLimit = "500m";
    string memoryLimit = "512Mi";
    Json env;
    Json labels;
    string healthPath = "/health";
    string readyPath = "/ready";
    SysTime createdAt;
    SysTime updatedAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["name"] = name;
        payload["namespace"] = namespace;
        payload["image"] = image;
        payload["port"] = cast(long) port;
        payload["protocol"] = cast(string) protocol;
        payload["replicas"] = cast(long) replicas;
        payload["min_replicas"] = cast(long) minReplicas;
        payload["max_replicas"] = cast(long) maxReplicas;
        payload["scale_policy"] = cast(string) scalePolicy;
        payload["status"] = cast(string) status;
        payload["cpu_request"] = cpuRequest;
        payload["memory_request"] = memoryRequest;
        payload["cpu_limit"] = cpuLimit;
        payload["memory_limit"] = memoryLimit;
        payload["env"] = env;
        payload["labels"] = labels;
        payload["health_path"] = healthPath;
        payload["ready_path"] = readyPath;
        payload["created_at"] = createdAt.toISOExtString();
        payload["updated_at"] = updatedAt.toISOExtString();
        return payload;
    }
}

KYMMicroservice microserviceFromJson(string namespace, string name, Json request) {
    KYMMicroservice ms;
    ms.name = name;
    ms.namespace = namespace;
    ms.createdAt = Clock.currTime();
    ms.updatedAt = ms.createdAt;
    ms.status = KYMResourceStatus.DEPLOYING;

    if ("image" in request && request["image"].isString)
        ms.image = request["image"].get!string;
    if ("port" in request && request["port"].isInteger)
        ms.port = cast(ushort) request["port"].get!long;
    if ("protocol" in request && request["protocol"].isString) {
        auto p = request["protocol"].get!string;
        if (p == "grpc") ms.protocol = KYMProtocol.GRPC;
        else if (p == "tcp") ms.protocol = KYMProtocol.TCP;
        else ms.protocol = KYMProtocol.HTTP;
    }
    if ("replicas" in request && request["replicas"].isInteger)
        ms.replicas = cast(size_t) request["replicas"].get!long;
    if ("min_replicas" in request && request["min_replicas"].isInteger)
        ms.minReplicas = cast(size_t) request["min_replicas"].get!long;
    if ("max_replicas" in request && request["max_replicas"].isInteger)
        ms.maxReplicas = cast(size_t) request["max_replicas"].get!long;
    if ("scale_policy" in request && request["scale_policy"].isString)
        ms.scalePolicy = parseScalePolicy(request["scale_policy"].get!string);
    if ("cpu_request" in request && request["cpu_request"].isString)
        ms.cpuRequest = request["cpu_request"].get!string;
    if ("memory_request" in request && request["memory_request"].isString)
        ms.memoryRequest = request["memory_request"].get!string;
    if ("cpu_limit" in request && request["cpu_limit"].isString)
        ms.cpuLimit = request["cpu_limit"].get!string;
    if ("memory_limit" in request && request["memory_limit"].isString)
        ms.memoryLimit = request["memory_limit"].get!string;
    if ("env" in request && request["env"].isObject)
        ms.env = request["env"];
    else
        ms.env = Json.emptyObject;
    if ("labels" in request && request["labels"].isObject)
        ms.labels = request["labels"];
    else
        ms.labels = Json.emptyObject;
    if ("health_path" in request && request["health_path"].isString)
        ms.healthPath = request["health_path"].get!string;
    if ("ready_path" in request && request["ready_path"].isString)
        ms.readyPath = request["ready_path"].get!string;
    return ms;
}
