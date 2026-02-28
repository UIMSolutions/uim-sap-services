module uim.sap.mdi.models.replicationclient;

struct MDIReplicationClient {
    string tenantId;
    string clientId;
    string name;
    string systemType;
    SysTime updatedAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["tenant_id"] = tenantId;
        payload["client_id"] = clientId;
        payload["name"] = name;
        payload["system_type"] = systemType;
        payload["updated_at"] = updatedAt.toISOExtString();
        return payload;
    }
}

MDIReplicationClient clientFromJson(string tenantId, Json request) {
    MDIReplicationClient client;
    client.tenantId = tenantId;
    client.clientId = createId();
    client.updatedAt = Clock.currTime();
    client.systemType = "sap";

    if ("client_id" in request && request["client_id"].isString) client.clientId = request["client_id"].get!string;
    if ("name" in request && request["name"].isString) client.name = request["name"].get!string;
    if ("system_type" in request && request["system_type"].isString) client.systemType = request["system_type"].get!string;
    return client;
}