module uim.sap.alertnotification.models.subscription;

struct AlertSubscription {
  UUID tenantId;
  UUID subscriptionId;
  string name;
  UUID consumerId;
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
