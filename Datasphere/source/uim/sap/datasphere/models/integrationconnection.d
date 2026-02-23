module uim.sap.datasphere.models.integrationconnection;

import uim.sap.datasphere;

@safe:

struct IntegrationConnection {
    string tenantId;
    string connectionId;
    string name;
    string sourceType;
    string mode;
    bool secure;
    string status;
    SysTime updatedAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["tenant_id"] = tenantId;
        payload["connection_id"] = connectionId;
        payload["name"] = name;
        payload["source_type"] = sourceType;
        payload["mode"] = mode;
        payload["secure"] = secure;
        payload["status"] = status;
        payload["updated_at"] = updatedAt.toISOExtString();
        return payload;
    }
}
