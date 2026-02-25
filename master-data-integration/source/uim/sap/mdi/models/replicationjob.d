module uim.sap.mdi.models.replicationjob;

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