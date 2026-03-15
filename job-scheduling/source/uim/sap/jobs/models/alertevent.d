/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
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

    override Json toJson()  {
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
