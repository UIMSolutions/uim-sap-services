module uim.sap.alertnotification.models.delivery;

import uim.sap.alertnotification;

mixin(ShowModule!());

@safe:

class AlertDelivery : SAPTenantObject {
  mixin(SAPObjectTemplate!AlertDelivery);

  UUID deliveryId;
  UUID alertId;
  UUID subscriptionId;
  string actionType;
  string target;
  string status;
  string reason;

  override Json toJson()  {
    Json result = super.toJson();

    result["delivery_id"] = deliveryId.toJson();
    result["alert_id"] = alertId.toJson();
    result["subscription_id"] = subscriptionId.toJson();
    result["action_type"] = actionType.toJson();
    result["target"] = target.toJson();
    result["status"] = status.toJson();
    result["reason"] = reason.toJson();

    return result;
  }
}
