module uim.sap.dataretention.models.archivedestructionjob;

struct ArchiveDestructionJob {
  UUID tenantId;
  string jobId;
  string operation;
  string applicationGroup;
  string entityType;
  string rangeFrom;
  string rangeTo;
  string legalGround;
  bool includeDataSubjectReference;
  string status;
  SysTime createdAt;

  override Json toJson() {
    Json payload = Json.emptyObject;
    payload["tenant_id"] = tenantId;
    payload["job_id"] = jobId;
    payload["operation"] = operation;
    payload["application_group"] = applicationGroup;
    payload["entity_type"] = entityType;
    payload["range_from"] = rangeFrom;
    payload["range_to"] = rangeTo;
    payload["legal_ground"] = legalGround;
    payload["include_data_subject_reference"] = includeDataSubjectReference;
    payload["status"] = status;
    payload["created_at"] = createdAt.toISOExtString();
    return payload;
  }
}

ArchiveDestructionJob parseArchiveDestructionJob(UUID tenantId, string operation, Json request) {
  ArchiveDestructionJob job;
  job.tenantId = tenantId;
  job.jobId = request.getString("job_id", createId());
  job.operation = operation;
  job.applicationGroup = request.getString("application_group", "");
  job.entityType = request.getString("entity_type", "transaction");
  job.rangeFrom = request.getString("range_from", "");
  job.rangeTo = request.getString("range_to", "");
  job.legalGround = request.getString("legal_ground", "");
  job.includeDataSubjectReference = request.getBoolean("include_data_subject_reference", true);
  job.status = "scheduled";
  job.createdAt = Clock.currTime();
  return job;
}
