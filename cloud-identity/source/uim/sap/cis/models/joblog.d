module uim.sap.cis.models.joblog;

struct CISJobLog {
    string tenantId;
    string logId;
    string jobId;
    string level;
    string message;
    SysTime createdAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["log_id"] = logId;
        payload["tenant_id"] = tenantId;
        payload["job_id"] = jobId;
        payload["level"] = level;
        payload["message"] = message;
        payload["created_at"] = createdAt.toISOExtString();
        return payload;
    }
}