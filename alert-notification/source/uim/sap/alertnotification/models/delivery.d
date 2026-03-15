module uim.sap.alertnotification.models.delivery;

import uim.sap.alertnotification;

mixin(ShowModule!());

@safe:

struct AlertDelivery {
  UUID tenantId;
  UUID deliveryId;
  UUID alertId;
  UUID subscriptionId;
  string actionType;
  string target;
  string status;
  string reason;
  SysTime createdAt;

  override Json toJson()  {
    Json result = Json.emptyObject;
    result["tenant_id"] = tenantId;
    result["delivery_id"] = deliveryId;
    result["alert_id"] = alertId;
    result["subscription_id"] = subscriptionId;
    result["action_type"] = actionType;
    result["target"] = target;
    result["status"] = status;
    result["reason"] = reason;
    result["created_at"] = createdAt.toISOExtString();
    return result;
  }
}
