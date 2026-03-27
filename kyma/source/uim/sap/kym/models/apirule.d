module uim.sap.kym.models.apirule;

import uim.sap.kym;

mixin(ShowModule!());

@safe:

/// An API rule exposes a function or microservice via an HTTP endpoint
class KYMApiRule : SAPObject {
    mixin(SAPObjectTemplate!KYMApiRule);

    string name;
    string namespace;
    string host;
    string path = "/";
    string[] methods;
    KYMAccessStrategy accessStrategy = KYMAccessStrategy.NO_AUTH;
    string serviceName;
    ushort servicePort = 80;
    bool active = true;

    override Json toJson()  {
      return super.toJson
        .set("name", name)
        .set("namespace", namespace)
        .set("host", host)
        .set("path", path)
        .set("methods", methods.map!(m => Json(m)).array.Json)
        .set("access_strategy", cast(string) accessStrategy)
        .set("service_name", serviceName)
        .set("service_port", cast(long) servicePort)
        .set("active", active)
        .set("created_at", createdAt.toISOExtString())
        .set("updated_at", updatedAt.toISOExtString());
    }
}

KYMApiRule apiRuleFromJson(string namespace, string name, Json request) {
    KYMApiRule rule;
    rule.name = name;
    rule.namespace = namespace;
    rule.createdAt = Clock.currTime();
    rule.updatedAt = rule.createdAt;

    if ("host" in request && request["host"].isString)
        rule.host = request["host"].getString;
    if ("path" in request && request["path"].isString)
        rule.path = request["path"].getString;
    if ("methods" in request && request["methods"].isArray) {
        foreach (item; request["methods"].toArray) {
            if (item.isString)
                rule.methods ~= item.getString;
        }
    } else {
        rule.methods = ["GET"];
    }
    if ("access_strategy" in request && request["access_strategy"].isString)
        rule.accessStrategy = parseAccessStrategy(request["access_strategy"].get!string);
    if ("service_name" in request && request["service_name"].isString)
        rule.serviceName = request["service_name"].getString;
    if ("service_port" in request && request["service_port"].isInteger)
        rule.servicePort = cast(ushort) request["service_port"].get!long;
    if ("active" in request && request["active"].isBool)
        rule.active = request["active"].get!bool;
    return rule;
}
