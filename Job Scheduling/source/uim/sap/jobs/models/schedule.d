module uim.sap.jobs.models.schedule;

import std.datetime : SysTime;

import vibe.data.json : Json;

struct Schedule {
    string tenantId;
    string scheduleId;
    string jobId;
    string format;
    string humanExpression;
    string repeatAt;
    int repeatIntervalSeconds;
    string cron;
    string timezone;
    bool active;
    SysTime nextRunAt;
    SysTime updatedAt;

    Json toJson() const {
        Json data = Json.emptyObject;
        data["tenant_id"] = tenantId;
        data["schedule_id"] = scheduleId;
        data["job_id"] = jobId;
        data["format"] = format;
        data["human_expression"] = humanExpression;
        data["repeat_at"] = repeatAt;
        data["repeat_interval_seconds"] = repeatIntervalSeconds;
        data["cron"] = cron;
        data["timezone"] = timezone;
        data["active"] = active;
        data["next_run_at"] = nextRunAt.toISOExtString();
        data["updated_at"] = updatedAt.toISOExtString();
        return data;
    }
}
