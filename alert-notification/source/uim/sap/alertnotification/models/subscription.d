module uim.sap.alertnotification.models.subscription;

import uim.sap.alertnotification;

mixin(ShowModule!());

@safe:
class AlertSubscription : SAPTenantObject {
  mixin(SAPObjectTemplate!AlertSubscription);

  UUID subscriptionId;
  string name;
  UUID consumerId;
  bool enabled;
  Json condition;
  Json actions;

  override Json toJson()  {
    Json result = super.toJson();
    
    result["subscription_id"] = subscriptionId.toJson();
    result["name"] = name.toJson();
    result["consumer_id"] = consumerId.toJson();
    result["enabled"] = enabled.toJson();
    result["condition"] = condition.toJson();
    result["actions"] = actions.toJson();

    return result;
  }
}
