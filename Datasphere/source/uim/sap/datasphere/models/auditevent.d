struct AuditEvent {
    string tenantId;
    string eventId;
    string operation;
    string layer;
    string actor;
    string details;
    SysTime createdAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["tenant_id"] = tenantId;
        payload["event_id"] = eventId;
        payload["operation"] = operation;
        payload["layer"] = layer;
        payload["actor"] = actor;
        payload["details"] = details;
        payload["created_at"] = createdAt.toISOExtString();
        return payload;
    }
}