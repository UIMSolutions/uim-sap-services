module uim.sap.mdi.models;

import std.datetime : Clock, SysTime;
import std.string : toLower;
import std.uuid : randomUUID;

import vibe.data.json : Json;

string createId() {
    return randomUUID().toString();
}

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

struct MDIFilter {
    string tenantId;
    string filterId;
    string objectType;
    Json conditions;
    bool active;
    SysTime updatedAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["tenant_id"] = tenantId;
        payload["filter_id"] = filterId;
        payload["object_type"] = objectType;
        payload["conditions"] = conditions;
        payload["active"] = active;
        payload["updated_at"] = updatedAt.toISOExtString();
        return payload;
    }
}

struct MDIExtension {
    string tenantId;
    string extensionId;
    string objectType;
    Json fields;
    Json entities;
    SysTime updatedAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["tenant_id"] = tenantId;
        payload["extension_id"] = extensionId;
        payload["object_type"] = objectType;
        payload["fields"] = fields;
        payload["entities"] = entities;
        payload["updated_at"] = updatedAt.toISOExtString();
        return payload;
    }
}

struct MDIReplicationJob {
    string tenantId;
    string jobId;
    string sourceClientId;
    string targetClientId;
    string objectType;
    string mode;
    string status;
    Json filterIds;
    SysTime createdAt;
    SysTime updatedAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["tenant_id"] = tenantId;
        payload["job_id"] = jobId;
        payload["source_client_id"] = sourceClientId;
        payload["target_client_id"] = targetClientId;
        payload["object_type"] = objectType;
        payload["mode"] = mode;
        payload["status"] = status;
        payload["filter_ids"] = filterIds;
        payload["created_at"] = createdAt.toISOExtString();
        payload["updated_at"] = updatedAt.toISOExtString();
        return payload;
    }
}

bool isAllowedObjectType(string objectType) {
    auto v = toLower(objectType);
    return v == "business_partner" || v == "product" || v == "supplier" || v == "customer";
}

MDIReplicationClient clientFromJson(string tenantId, Json request) {
    MDIReplicationClient client;
    client.tenantId = tenantId;
    client.clientId = createId();
    client.updatedAt = Clock.currTime();
    client.systemType = "sap";

    if ("client_id" in request && request["client_id"].type == Json.Type.string) client.clientId = request["client_id"].get!string;
    if ("name" in request && request["name"].type == Json.Type.string) client.name = request["name"].get!string;
    if ("system_type" in request && request["system_type"].type == Json.Type.string) client.systemType = request["system_type"].get!string;
    return client;
}
