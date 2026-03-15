module uim.sap.atp.models.eventtrigger;

import uim.sap.atp;

mixin(ShowModule!());

@safe:

struct ATPEventTrigger {
    string tenantId;
    string triggerId;
    string eventSource;
    string eventType;
    string commandId;
    bool active;
    SysTime createdAt;

    override Json toJson()  {
        Json payload = Json.emptyObject;
        payload["tenant_id"] = tenantId;
        payload["trigger_id"] = triggerId;
        payload["event_source"] = eventSource;
        payload["event_type"] = eventType;
        payload["command_id"] = commandId;
        payload["active"] = active;
        payload["created_at"] = createdAt.toISOExtString();
        return payload;
    }
}
