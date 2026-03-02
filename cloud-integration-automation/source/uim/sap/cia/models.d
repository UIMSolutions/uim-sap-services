module uim.sap.cia.models;

import std.datetime : SysTime;

import vibe.data.json : Json;

// ---------------------------------------------------------------------------
// Role – a named permission group that tasks can be assigned to
// ---------------------------------------------------------------------------
struct CIARole {
    string id;
    string name;         // e.g. "Basis Administrator", "Cloud Admin"
    string description;

    Json toJson() const {
        Json j = Json.emptyObject;
        j["id"]          = id;
        j["name"]        = name;
        j["description"] = description;
        return j;
    }
}

// ---------------------------------------------------------------------------
// User – a person who can be assigned tasks
// ---------------------------------------------------------------------------
struct CIAUser {
    string tenantId;
    string id;
    string name;
    string email;
    string roleId;

    Json toJson() const {
        Json j = Json.emptyObject;
        j["tenant_id"] = tenantId;
        j["id"]        = id;
        j["name"]      = name;
        j["email"]     = email;
        j["role_id"]   = roleId;
        return j;
    }
}

// ---------------------------------------------------------------------------
// System – an entry in the system landscape (SAP Cloud, On-Premises, …)
// ---------------------------------------------------------------------------
struct CIASystem {
    string tenantId;
    string id;
    string name;
    /// System type: "sap-cloud", "s4hana-on-prem", "s4hana-cloud", "successfactors", "ariba", "other"
    string systemType;
    string host;
    string description;
    bool   active;
    SysTime createdAt;
    SysTime updatedAt;

    Json toJson() const {
        Json j = Json.emptyObject;
        j["tenant_id"]   = tenantId;
        j["id"]          = id;
        j["name"]        = name;
        j["system_type"] = systemType;
        j["host"]        = host;
        j["description"] = description;
        j["active"]      = active;
        j["created_at"]  = createdAt.toISOExtString();
        j["updated_at"]  = updatedAt.toISOExtString();
        return j;
    }
}

// ---------------------------------------------------------------------------
// ScenarioTaskTemplate – a task template embedded in a scenario definition
// ---------------------------------------------------------------------------
struct CIAScenarioTaskTemplate {
    int    order;
    string name;
    string description;
    /// Step-by-step instructions shown to the assignee
    string instructions;
    /// Role that should execute this step
    string defaultRoleId;
    /// Whether this step can be automated
    bool automated;
    /// Tags such as "pre-requisite", "config", "validation", "post-config"
    string[] tags;

    Json toJson() const {
        Json j = Json.emptyObject;
        j["order"]           = order;
        j["name"]            = name;
        j["description"]     = description;
        j["instructions"]    = instructions;
        j["default_role_id"] = defaultRoleId;
        j["automated"]       = automated;
        Json t = Json.emptyArray;
        foreach (tag; tags) t ~= tag;
        j["tags"] = t;
        return j;
    }
}

// ---------------------------------------------------------------------------
// Scenario – an integration scenario template (e.g. S/4HANA → SuccessFactors)
// ---------------------------------------------------------------------------
struct CIAScenario {
    string id;
    string name;
    string description;
    /// Tags such as "cloud-to-cloud", "on-prem-to-cloud"
    string[] tags;
    /// System types required by this scenario
    string[] requiredSystemTypes;
    /// Ordered task templates generated when a workflow is planned
    CIAScenarioTaskTemplate[] taskTemplates;
    SysTime createdAt;
    SysTime updatedAt;

    Json toJson() const {
        Json j = Json.emptyObject;
        j["id"]          = id;
        j["name"]        = name;
        j["description"] = description;

        Json t = Json.emptyArray;
        foreach (tag; tags) t ~= tag;
        j["tags"] = t;

        Json r = Json.emptyArray;
        foreach (st; requiredSystemTypes) r ~= st;
        j["required_system_types"] = r;

        Json tmpl = Json.emptyArray;
        foreach (tt; taskTemplates) tmpl ~= tt.toJson();
        j["task_templates"] = tmpl;

        j["created_at"] = createdAt.toISOExtString();
        j["updated_at"] = updatedAt.toISOExtString();
        return j;
    }
}

// ---------------------------------------------------------------------------
// Parameter – a key/value pair scoped to a workflow (reused across tasks)
// ---------------------------------------------------------------------------
struct CIAParameter {
    string workflowId;
    string key;
    string value;
    string description;
    bool   sensitive;   // mask in logs/UI if true

    Json toJson() const {
        Json j = Json.emptyObject;
        j["workflow_id"]  = workflowId;
        j["key"]          = key;
        j["value"]        = sensitive ? "***" : value;
        j["description"]  = description;
        j["sensitive"]    = sensitive;
        return j;
    }
}

// ---------------------------------------------------------------------------
// Workflow – a running instance of a scenario for a tenant
// ---------------------------------------------------------------------------
struct CIAWorkflow {
    string tenantId;
    string id;
    string scenarioId;
    string scenarioName;
    string name;
    /// Status: "planned" | "running" | "completed" | "failed"
    string status;
    /// IDs of systems selected for this workflow
    string[] systemIds;
    SysTime createdAt;
    SysTime updatedAt;
    SysTime startedAt;
    SysTime finishedAt;

    Json toJson() const {
        Json j = Json.emptyObject;
        j["tenant_id"]     = tenantId;
        j["id"]            = id;
        j["scenario_id"]   = scenarioId;
        j["scenario_name"] = scenarioName;
        j["name"]          = name;
        j["status"]        = status;

        Json s = Json.emptyArray;
        foreach (sysId; systemIds) s ~= sysId;
        j["system_ids"] = s;

        j["created_at"]  = createdAt.toISOExtString();
        j["updated_at"]  = updatedAt.toISOExtString();
        j["started_at"]  = startedAt.toISOExtString();
        j["finished_at"] = finishedAt.toISOExtString();
        return j;
    }
}

// ---------------------------------------------------------------------------
// Task – a single guided step in a workflow
// ---------------------------------------------------------------------------
struct CIATask {
    string tenantId;
    string workflowId;
    string id;
    int    order;
    string name;
    string description;
    /// Full instructions rendered for the assignee (may include parameter values)
    string instructions;
    string assignedRoleId;
    string assignedUserId;
    bool   automated;
    /// Status: "pending" | "in-progress" | "done" | "skipped" | "failed"
    string status;
    /// Additional runtime context (e.g. target system id, config payload)
    Json   context;
    SysTime createdAt;
    SysTime updatedAt;

    Json toJson() const {
        Json j = Json.emptyObject;
        j["tenant_id"]        = tenantId;
        j["workflow_id"]      = workflowId;
        j["id"]               = id;
        j["order"]            = order;
        j["name"]             = name;
        j["description"]      = description;
        j["instructions"]     = instructions;
        j["assigned_role_id"] = assignedRoleId;
        j["assigned_user_id"] = assignedUserId;
        j["automated"]        = automated;
        j["status"]           = status;
        j["context"]          = context;
        j["created_at"]       = createdAt.toISOExtString();
        j["updated_at"]       = updatedAt.toISOExtString();
        return j;
    }
}

// ---------------------------------------------------------------------------
// TaskLog – a monitoring log entry for a workflow or task
// ---------------------------------------------------------------------------
struct CIATaskLog {
    string tenantId;
    string workflowId;
    string taskId;    // empty string if workflow-level log
    string id;
    string message;
    /// Level: "info" | "warning" | "error"
    string level;
    SysTime timestamp;

    Json toJson() const {
        Json j = Json.emptyObject;
        j["tenant_id"]   = tenantId;
        j["workflow_id"] = workflowId;
        j["task_id"]     = taskId;
        j["id"]          = id;
        j["message"]     = message;
        j["level"]       = level;
        j["timestamp"]   = timestamp.toISOExtString();
        return j;
    }
}

// ---------------------------------------------------------------------------
// AutomationResult – outcome of an automated technical configuration step
// ---------------------------------------------------------------------------
struct CIAAutomationResult {
    string tenantId;
    string workflowId;
    string taskId;
    string id;
    string targetSystemId;
    /// Status: "running" | "success" | "failure"
    string status;
    string output;
    SysTime startedAt;
    SysTime finishedAt;

    Json toJson() const {
        Json j = Json.emptyObject;
        j["tenant_id"]       = tenantId;
        j["workflow_id"]     = workflowId;
        j["task_id"]         = taskId;
        j["id"]              = id;
        j["target_system_id"] = targetSystemId;
        j["status"]          = status;
        j["output"]          = output;
        j["started_at"]      = startedAt.toISOExtString();
        j["finished_at"]     = finishedAt.toISOExtString();
        return j;
    }
}
