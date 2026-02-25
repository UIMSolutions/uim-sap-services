module uim.sap.bas.models;

import std.datetime : SysTime;

import vibe.data.json : Json;

struct BASScenario {
    string scenarioId;
    string name;
    string description;
    string[] supportedSolutions;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["scenario_id"] = scenarioId;
        payload["name"] = name;
        payload["description"] = description;

        Json solutions = Json.emptyArray;
        foreach (solution; supportedSolutions) solutions ~= solution;
        payload["supported_solutions"] = solutions;
        return payload;
    }
}

struct BASTemplate {
    string templateId;
    string scenarioId;
    string name;
    string language;
    bool graphicalEditor;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["template_id"] = templateId;
        payload["scenario_id"] = scenarioId;
        payload["name"] = name;
        payload["language"] = language;
        payload["graphical_editor"] = graphicalEditor;
        return payload;
    }
}

struct BASWorkspace {
    string tenantId;
    string workspaceId;
    string name;
    string scenarioId;
    string region;
    string status;
    string accessUrl;
    bool terminalEnabled;
    bool debugEnabled;
    SysTime createdAt;
    SysTime updatedAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["tenant_id"] = tenantId;
        payload["workspace_id"] = workspaceId;
        payload["name"] = name;
        payload["scenario_id"] = scenarioId;
        payload["region"] = region;
        payload["status"] = status;
        payload["access_url"] = accessUrl;
        payload["terminal_enabled"] = terminalEnabled;
        payload["debug_enabled"] = debugEnabled;
        payload["created_at"] = createdAt.toISOExtString();
        payload["updated_at"] = updatedAt.toISOExtString();
        return payload;
    }
}

struct BASWizardRun {
    string tenantId;
    string runId;
    string workspaceId;
    string templateId;
    string status;
    Json input;
    Json output;
    SysTime startedAt;
    SysTime finishedAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["tenant_id"] = tenantId;
        payload["run_id"] = runId;
        payload["workspace_id"] = workspaceId;
        payload["template_id"] = templateId;
        payload["status"] = status;
        payload["input"] = input;
        payload["output"] = output;
        payload["started_at"] = startedAt.toISOExtString();
        payload["finished_at"] = finishedAt.toISOExtString();
        return payload;
    }
}

struct BASTerminalSession {
    string tenantId;
    string workspaceId;
    string sessionId;
    string shell;
    string status;
    SysTime createdAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["tenant_id"] = tenantId;
        payload["workspace_id"] = workspaceId;
        payload["session_id"] = sessionId;
        payload["shell"] = shell;
        payload["status"] = status;
        payload["created_at"] = createdAt.toISOExtString();
        return payload;
    }
}

struct BASDeployment {
    string tenantId;
    string workspaceId;
    string deploymentId;
    string target;
    string mode;
    string status;
    SysTime createdAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["tenant_id"] = tenantId;
        payload["workspace_id"] = workspaceId;
        payload["deployment_id"] = deploymentId;
        payload["target"] = target;
        payload["mode"] = mode;
        payload["status"] = status;
        payload["created_at"] = createdAt.toISOExtString();
        return payload;
    }
}
