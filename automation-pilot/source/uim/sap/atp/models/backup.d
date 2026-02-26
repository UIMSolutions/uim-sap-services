module uim.sap.atp.models.backup;

import uim.sap.atp;

mixin(ShowModule!());

@safe:

struct ATPBackup {
    string tenantId;
    string backupId;
    string mode;
    Json content;
    SysTime createdAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["tenant_id"] = tenantId;
        payload["backup_id"] = backupId;
        payload["mode"] = mode;
        payload["content"] = content;
        payload["created_at"] = createdAt.toISOExtString();
        return payload;
    }
}
