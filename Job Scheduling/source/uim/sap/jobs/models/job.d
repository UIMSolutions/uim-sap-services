module uim.sap.jobs.models.job;

import std.datetime : SysTime;

import vibe.data.json : Json;

struct Job {
    string tenantId;
    string jobId;
    string name;
    string description;
    string actionEndpoint;
    string httpMethod;
    Json payload;
    string runtime;
    string executionMode;
    bool longRunningTask;
    string oauthToken;
    bool active;
    SysTime createdAt;
    SysTime updatedAt;

    Json toJson() const {
        Json data = Json.emptyObject;
        data["tenant_id"] = tenantId;
        data["job_id"] = jobId;
        data["name"] = name;
        data["description"] = description;
        data["action_endpoint"] = actionEndpoint;
        data["http_method"] = httpMethod;
        data["payload"] = payload;
        data["runtime"] = runtime;
        data["execution_mode"] = executionMode;
        data["long_running_task"] = longRunningTask;
        data["active"] = active;
        data["created_at"] = createdAt.toISOExtString();
        data["updated_at"] = updatedAt.toISOExtString();
        return data;
    }
}
