module uim.sap.kym.models.apirule;

import uim.sap.kym;

mixin(ShowModule!());

@safe:

/// An API rule exposes a function or microservice via an HTTP endpoint
struct KYMApiRule {
    string name;
    string namespace;
    string host;
    string path = "/";
    string[] methods;
    KYMAccessStrategy accessStrategy = KYMAccessStrategy.NO_AUTH;
    string serviceName;
    ushort servicePort = 80;
    bool active = true;
    SysTime createdAt;
    SysTime updatedAt;

    override Json toJson()  {
        Json payload = Json.emptyObject;
        payload["name"] = name;
        payload["namespace"] = namespace;
        payload["host"] = host;
        payload["path"] = path;
        payload["methods"] = methods.map!(m => Json(m)).array.Json;
        payload["access_strategy"] = cast(string) accessStrategy;
        payload["service_name"] = serviceName;
        payload["service_port"] = cast(long) servicePort;
        payload["active"] = active;
        payload["created_at"] = createdAt.toISOExtString();
        payload["updated_at"] = updatedAt.toISOExtString();
        return payload;
    }
}

KYMApiRule apiRuleFromJson(string namespace, string name, Json request) {
    KYMApiRule rule;
    rule.name = name;
    rule.namespace = namespace;
    rule.createdAt = Clock.currTime();
    rule.updatedAt = rule.createdAt;

    if ("host" in request && request["host"].isString)
        rule.host = request["host"].get!string;
    if ("path" in request && request["path"].isString)
        rule.path = request["path"].get!string;
    if ("methods" in request && request["methods"].isArray) {
        foreach (item; request["methods"].toArray) {
            if (item.isString)
                rule.methods ~= item.get!string;
        }
    } else {
        rule.methods = ["GET"];
    }
    if ("access_strategy" in request && request["access_strategy"].isString)
        rule.accessStrategy = parseAccessStrategy(request["access_strategy"].get!string);
    if ("service_name" in request && request["service_name"].isString)
        rule.serviceName = request["service_name"].get!string;
    if ("service_port" in request && request["service_port"].isInteger)
        rule.servicePort = cast(ushort) request["service_port"].get!long;
    if ("active" in request && request["active"].isBool)
        rule.active = request["active"].get!bool;
    return rule;
}
