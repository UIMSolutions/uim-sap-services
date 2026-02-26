module uim.sap.atp.models.schedule;

import uim.sap.atp;

mixin(ShowModule!());

@safe:

struct ATPSchedule {
    string tenantId;
    string scheduleId;
    string targetType;
    string targetId;
    string mode;
    string expression;
    bool active;
    SysTime createdAt;
    SysTime updatedAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["tenant_id"] = tenantId;
        payload["schedule_id"] = scheduleId;
        payload["target_type"] = targetType;
        payload["target_id"] = targetId;
        payload["mode"] = mode;
        payload["expression"] = expression;
        payload["active"] = active;
        payload["created_at"] = createdAt.toISOExtString();
        payload["updated_at"] = updatedAt.toISOExtString();
        return payload;
    }
}