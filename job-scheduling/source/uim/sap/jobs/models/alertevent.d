module uim.sap.jobs.models.alertevent;

import std.datetime : SysTime;

import vibe.data.json : Json;

struct AlertEvent {
    string tenantId;
    string alertId;
    string eventType;
    string jobId;
    string runId;
    string status;
    string severity;
    string message;
    SysTime createdAt;

    Json toJson() const {
        Json data = Json.emptyObject;
        data["tenant_id"] = tenantId;
        data["alert_id"] = alertId;
        data["event_type"] = eventType;
        data["job_id"] = jobId;
        data["run_id"] = runId;
        data["status"] = status;
        data["severity"] = severity;
        data["message"] = message;
        data["created_at"] = createdAt.toISOExtString();
        return data;
    }
}
