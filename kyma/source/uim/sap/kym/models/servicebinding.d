module uim.sap.kym.models.servicebinding;

import uim.sap.kym;

mixin(ShowModule!());

@safe:

/// A service binding connects a microservice or function to an SAP or external service
struct KYMServiceBinding {
    string name;
    string namespace;
    string serviceInstanceName;
    string consumerName;
    string consumerKind = "microservice";
    Json parameters;
    Json credentials;
    KYMResourceStatus status = KYMResourceStatus.PENDING;
    SysTime createdAt;
    SysTime updatedAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["name"] = name;
        payload["namespace"] = namespace;
        payload["service_instance_name"] = serviceInstanceName;
        payload["consumer_name"] = consumerName;
        payload["consumer_kind"] = consumerKind;
        payload["parameters"] = parameters;
        payload["status"] = cast(string) status;
        payload["created_at"] = createdAt.toISOExtString();
        payload["updated_at"] = updatedAt.toISOExtString();
        return payload;
    }

    Json toJsonWithCredentials() const {
        Json payload = toJson();
        payload["credentials"] = credentials;
        return payload;
    }
}

KYMServiceBinding serviceBindingFromJson(string namespace, string name, Json request) {
    KYMServiceBinding sb;
    sb.name = name;
    sb.namespace = namespace;
    sb.createdAt = Clock.currTime();
    sb.updatedAt = sb.createdAt;
    sb.status = KYMResourceStatus.RUNNING;

    if ("service_instance_name" in request && request["service_instance_name"].isString)
        sb.serviceInstanceName = request["service_instance_name"].get!string;
    if ("consumer_name" in request && request["consumer_name"].isString)
        sb.consumerName = request["consumer_name"].get!string;
    if ("consumer_kind" in request && request["consumer_kind"].isString)
        sb.consumerKind = request["consumer_kind"].get!string;
    if ("parameters" in request && request["parameters"].isObject)
        sb.parameters = request["parameters"];
    else
        sb.parameters = Json.emptyObject;
    if ("credentials" in request && request["credentials"].isObject)
        sb.credentials = request["credentials"];
    else
        sb.credentials = Json.emptyObject;
    return sb;
}
