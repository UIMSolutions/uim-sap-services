module uim.sap.buh.models.subscription;
import uim.sap.buh;

mixin(ShowModule!());

@safe:
struct BUHSubscription {
  UUID id;
  UUID apiId;
  string applicationName;
  string plan;
  string status = "active";
  SysTime createdAt;

  override Json toJson()  {
    Json info = super.toJson;
    payload["id"] = id;
    payload["api_id"] = apiId;
    payload["application_name"] = applicationName;
    payload["plan"] = plan;
    payload["status"] = status;
    payload["created_at"] = createdAt.toISOExtString();
    return payload;
  }
}

BUHSubscription subscriptionFromJson(Json payload) {
  BUHSubscription subscription;
  subscription.id = randomUUID().toString();
  subscription.createdAt = Clock.currTime();

  if ("api_id" in payload && payload["api_id"].isString) {
    subscription.apiId = payload["api_id"].get!string;
  }
  if ("application_name" in payload && payload["application_name"].isString) {
    subscription.applicationName = payload["application_name"].get!string;
  }
  if ("plan" in payload && payload["plan"].isString) {
    subscription.plan = payload["plan"].get!string;
  }

  return subscription;
}
