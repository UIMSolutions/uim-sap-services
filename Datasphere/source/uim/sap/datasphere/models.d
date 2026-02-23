module uim.sap.datasphere.models;

import std.datetime : SysTime;

import vibe.data.json : Json;

struct Space {
    string tenantId;
    string spaceId;
    string name;
    int diskGb;
    int memoryGb;
    int priority;
    string[] users;
    bool active;
    SysTime updatedAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        Json usersPayload = Json.emptyArray;
        foreach (user; users) usersPayload ~= user;

        payload["tenant_id"] = tenantId;
        payload["space_id"] = spaceId;
        payload["name"] = name;
        payload["disk_gb"] = diskGb;
        payload["memory_gb"] = memoryGb;
        payload["priority"] = priority;
        payload["users"] = usersPayload;
        payload["active"] = active;
        payload["updated_at"] = updatedAt.toISOExtString();
        return payload;
    }
}

struct DataModel {
    string tenantId;
    string modelId;
    string name;
    string modelType;
    string sqlDefinition;
    string dataFlowDefinition;
    string[] sources;
    string status;
    SysTime updatedAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        Json sourcePayload = Json.emptyArray;
        foreach (source; sources) sourcePayload ~= source;

        payload["tenant_id"] = tenantId;
        payload["model_id"] = modelId;
        payload["name"] = name;
        payload["model_type"] = modelType;
        payload["sql_definition"] = sqlDefinition;
        payload["data_flow_definition"] = dataFlowDefinition;
        payload["sources"] = sourcePayload;
        payload["status"] = status;
        payload["updated_at"] = updatedAt.toISOExtString();
        return payload;
    }
}

struct BusinessModel {
    string tenantId;
    string modelId;
    string name;
    string description;
    string grain;
    string[] dimensions;
    string[] measures;
    SysTime updatedAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        Json dimPayload = Json.emptyArray;
        Json measurePayload = Json.emptyArray;

        foreach (dim; dimensions) dimPayload ~= dim;
        foreach (measure; measures) measurePayload ~= measure;

        payload["tenant_id"] = tenantId;
        payload["model_id"] = modelId;
        payload["name"] = name;
        payload["description"] = description;
        payload["grain"] = grain;
        payload["dimensions"] = dimPayload;
        payload["measures"] = measurePayload;
        payload["updated_at"] = updatedAt.toISOExtString();
        return payload;
    }
}

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

struct GovernanceAsset {
    string tenantId;
    string assetId;
    string title;
    string assetType;
    string quality;
    bool published;
    SysTime updatedAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["tenant_id"] = tenantId;
        payload["asset_id"] = assetId;
        payload["title"] = title;
        payload["asset_type"] = assetType;
        payload["quality"] = quality;
        payload["published"] = published;
        payload["updated_at"] = updatedAt.toISOExtString();
        return payload;
    }
}

struct GlossaryTerm {
    string tenantId;
    string termId;
    string term;
    string definition;
    SysTime updatedAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["tenant_id"] = tenantId;
        payload["term_id"] = termId;
        payload["term"] = term;
        payload["definition"] = definition;
        payload["updated_at"] = updatedAt.toISOExtString();
        return payload;
    }
}

struct KPI {
    string tenantId;
    string kpiId;
    string name;
    string formula;
    string unit;
    SysTime updatedAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["tenant_id"] = tenantId;
        payload["kpi_id"] = kpiId;
        payload["name"] = name;
        payload["formula"] = formula;
        payload["unit"] = unit;
        payload["updated_at"] = updatedAt.toISOExtString();
        return payload;
    }
}

struct RowPolicy {
    string tenantId;
    string policyId;
    string dataset;
    string expression;
    SysTime updatedAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["tenant_id"] = tenantId;
        payload["policy_id"] = policyId;
        payload["dataset"] = dataset;
        payload["expression"] = expression;
        payload["updated_at"] = updatedAt.toISOExtString();
        return payload;
    }
}

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

struct TenantAdminState {
    string tenantName;
    bool connectivityPrepared;
    bool maintenanceMode;
    string lastMaintenance;
    string[] users;
    Json custom;

    Json toJson() const {
        Json payload = Json.emptyObject;
        Json usersPayload = Json.emptyArray;
        foreach (user; users) usersPayload ~= user;

        payload["tenant_name"] = tenantName;
        payload["connectivity_prepared"] = connectivityPrepared;
        payload["maintenance_mode"] = maintenanceMode;
        payload["last_maintenance"] = lastMaintenance;
        payload["users"] = usersPayload;
        payload["custom"] = custom;
        return payload;
    }
}
