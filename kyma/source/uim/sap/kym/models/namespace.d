module uim.sap.kym.models.namespace;

import uim.sap.kym;

mixin(ShowModule!());

@safe:

/// A Kyma namespace isolates workloads like a Kubernetes namespace
struct KYMNamespace {
    string name;
    string description;
    Json labels;
    KYMResourceStatus status = KYMResourceStatus.RUNNING;
    SysTime createdAt;
    SysTime updatedAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["name"] = name;
        payload["description"] = description;
        payload["labels"] = labels;
        payload["status"] = cast(string) status;
        payload["created_at"] = createdAt.toISOExtString();
        payload["updated_at"] = updatedAt.toISOExtString();
        return payload;
    }
}

KYMNamespace namespaceFromJson(string name, Json request) {
    KYMNamespace ns;
    ns.name = name;
    ns.createdAt = Clock.currTime();
    ns.updatedAt = ns.createdAt;
    ns.status = KYMResourceStatus.RUNNING;

    if ("description" in request && request["description"].isString)
        ns.description = request["description"].get!string;
    if ("labels" in request && request["labels"].isObject)
        ns.labels = request["labels"];
    else
        ns.labels = Json.emptyObject;
    return ns;
}
