module uim.sap.kym.models.servicebinding;

import uim.sap.kym;

mixin(ShowModule!());

@safe:

/// A service binding connects a microservice or function to an SAP or external service
class KYMServiceBinding : SAPObject {
  mixin(SAPObject!KYMServiceBinding);

  string name;
  string namespace;
  string serviceInstanceName;
  string consumerName;
  string consumerKind = "microservice";
  Json parameters;
  Json credentials;
  KYMResourceStatus status = KYMResourceStatus.PENDING;

  override Json toJson() {
    return super.toJson()
      .set("name", name)
      .set("namespace", namespace)
      .set("service_instance_name", serviceInstanceName)
      .set("consumer_name", consumerName)
      .set("consumer_kind", consumerKind)
      .set("parameters", parameters)
      .set("status", cast(string)status)
      .set("created_at", createdAt.toISOExtString())
      .set("updated_at", updatedAt.toISOExtString());
  }

  Json toJsonWithCredentials() {
    Json payload = toJson();
    payload["credentials"] = credentials;
    return payload;
  }

  static KYMServiceBinding serviceBindingFromJson(string namespace, string name, Json request) {
    KYMServiceBinding sb = new KYMServiceBinding();
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

}
