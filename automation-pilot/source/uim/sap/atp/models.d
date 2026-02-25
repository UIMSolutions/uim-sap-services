module uim.sap.atp.models;

import std.datetime : SysTime;

import vibe.data.json : Json;

struct ATPCatalog {
    string tenantId;
    string catalogId;
    string name;
    string scenario;
    bool predefined;
    string[] commandIds;
    SysTime createdAt;
    SysTime updatedAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["tenant_id"] = tenantId;
        payload["catalog_id"] = catalogId;
        payload["name"] = name;
        payload["scenario"] = scenario;
        payload["predefined"] = predefined;
        Json commands = Json.emptyArray;
        foreach (id; commandIds) commands ~= id;
        payload["command_ids"] = commands;
        payload["created_at"] = createdAt.toISOExtString();
        payload["updated_at"] = updatedAt.toISOExtString();
        return payload;
    }
}

struct ATPCommand {
    string tenantId;
    string commandId;
    string catalogId;
    string name;
    string description;
    string commandType;
    string[] steps;
    bool allowPrivateEnvironment;
    Json defaults;
    SysTime createdAt;
    SysTime updatedAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["tenant_id"] = tenantId;
        payload["command_id"] = commandId;
        payload["catalog_id"] = catalogId;
        payload["name"] = name;
        payload["description"] = description;
        payload["command_type"] = commandType;
        Json stepValues = Json.emptyArray;
        foreach (step; steps) stepValues ~= step;
        payload["steps"] = stepValues;
        payload["allow_private_environment"] = allowPrivateEnvironment;
        payload["defaults"] = defaults;
        payload["created_at"] = createdAt.toISOExtString();
        payload["updated_at"] = updatedAt.toISOExtString();
        return payload;
    }
}

struct ATPExecution {
    string tenantId;
    string executionId;
    string commandId;
    string triggerType;
    string status;
    Json input;
    Json result;
    SysTime startedAt;
    SysTime finishedAt;

    Json toJson() const {
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

struct ATPEventTrigger {
    string tenantId;
    string triggerId;
    string eventSource;
    string eventType;
    string commandId;
    bool active;
    SysTime createdAt;

    Json toJson() const {
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

struct ATPSecretInput {
    string tenantId;
    string key;
    string maskedValue;
    string purpose;
    SysTime updatedAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["tenant_id"] = tenantId;
        payload["key"] = key;
        payload["masked_value"] = maskedValue;
        payload["purpose"] = purpose;
        payload["updated_at"] = updatedAt.toISOExtString();
        return payload;
    }
}

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
