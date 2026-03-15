module uim.sap.atp.models.excecution;

import uim.sap.atp;

mixin(ShowModule!());

@safe:

struct ATPExecution {
    UUID tenantId;
    UUID executionId;
    UUID commandId;
    string triggerType;
    string status;
    Json input;
    Json result;
    SysTime startedAt;
    SysTime finishedAt;

    override Json toJson()  {
        Json payload = Json.emptyObject;
        payload["tenant_id"] = tenantId;
        payload["execution_id"] = executionId;
        payload["command_id"] = commandId;
        payload["trigger_type"] = triggerType;
        payload["status"] = status;
        payload["input"] = input;
        payload["result"] = result;
        payload["started_at"] = startedAt.toISOExtString();
        payload["finished_at"] = finishedAt.toISOExtString();
        return payload;
    }
}