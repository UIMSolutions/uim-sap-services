module uim.sap.dataretention.models.archivedestructionjob;

class ArchiveDestructionJob : SAPTenantEntity {
  mixin(SAPTenantEntityTemplate!ArchiveDestructionJob);

  UUID jobId;
  string operation;
  string applicationGroup;
  string entityType;
  string rangeFrom;
  string rangeTo;
  string legalGround;
  bool includeDataSubjectReference;
  string status;

  override Json toJson() {
    return super.toJson
    .set("job_id", jobId)
    .set("operation", operation)
    .set("application_group", applicationGroup)
    .set("entity_type", entityType)
    .set("range_from", rangeFrom)
    .set("range_to", rangeTo)
    .set("legal_ground", legalGround)
    .set("include_data_subject_reference", includeDataSubjectReference)
    .set("status", status);
  }
}

ArchiveDestructionJob parseArchiveDestructionJob(UUID tenantId, string operation, Json request) {
  ArchiveDestructionJob job = new ArchiveDestructionJob;
  job.tenantId = tenantId;
  job.jobId = request.getString("job_id", createId());
  job.operation = operation;
  job.applicationGroup = request.getString("application_group", "");
  job.entityType = request.getString("entity_type", "transaction");
  job.rangeFrom = request.getString("range_from", "");
  job.rangeTo = request.getString("range_to", "");
  job.legalGround = request.getString("legal_ground", "");
  job.includeDataSubjectReference = optionalBoolean("include_data_subject_reference", true);
  job.status = "scheduled";
  job.createdAt = Clock.currTime();
  return job;
}
