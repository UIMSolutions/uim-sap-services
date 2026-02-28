module uim.sap.cis.models.notificationsubscription;

struct CISNotificationSubscription {
    string tenantId;
    string subscriptionId;
    string sourceSystem;
    string callbackUrl;
    SysTime updatedAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["subscription_id"] = subscriptionId;
        payload["tenant_id"] = tenantId;
        payload["source_system"] = sourceSystem;
        payload["callback_url"] = callbackUrl;
        payload["updated_at"] = updatedAt.toISOExtString();
        return payload;
    }
}