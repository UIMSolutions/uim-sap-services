module uim.sap.alertnotification.models.models;

import uim.sap.alertnotification;

mixin(ShowModule!());

@safe:

struct AlertEvent {
  string tenantId;
  string alertId;
  string eventType;
  string category;
  string severity;
  string source;
  string subject;
  string message;
  Json tags;
  Json payload;
  SysTime createdAt;

  Json toJson() const {
    Json result = Json.emptyObject;
    result["tenant_id"] = tenantId;
    result["alert_id"] = alertId;
    result["event_type"] = eventType;
    result["category"] = category;
    result["severity"] = severity;
    result["source"] = source;
    result["subject"] = subject;
    result["message"] = message;
    result["tags"] = tags;
    result["payload"] = payload;
    result["created_at"] = createdAt.toISOExtString();
    return result;
  }
}

struct AlertSubscription {
  string tenantId;
  string subscriptionId;
  string name;
  string consumerId;
  bool enabled;
  Json condition;
  Json actions;
  SysTime createdAt;
  SysTime updatedAt;

  Json toJson() const {
    Json result = Json.emptyObject;
    result["tenant_id"] = tenantId;
    result["subscription_id"] = subscriptionId;
    result["name"] = name;
    result["consumer_id"] = consumerId;
    result["enabled"] = enabled;
    result["condition"] = condition;
    result["actions"] = actions;
    result["created_at"] = createdAt.toISOExtString();
    result["updated_at"] = updatedAt.toISOExtString();
    return result;
  }
}

struct AlertDelivery {
  string tenantId;
  string deliveryId;
  string alertId;
  string subscriptionId;
  string actionType;
  string target;
  string status;
  string reason;
  SysTime createdAt;

  Json toJson() const {
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
