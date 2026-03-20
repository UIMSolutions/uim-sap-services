module uim.sap.dataretention.models.businesspurpose;

import std.datetime : Clock, SysTime;

import uim.sap.dataretention;

mixin(ShowModule!());

@safe:

struct LegalGroundRule {
  string legalGround;
  int residenceDays;
  int retentionDays;

  Json toJson() const {
    Json payload = Json.emptyObject;
    payload["legal_ground"] = legalGround;
    payload["residence_days"] = residenceDays;
    payload["retention_days"] = retentionDays;
    return payload;
  }
}

struct BusinessPurposeRule {
  UUID tenantId;
  string purposeRuleId;
  string applicationGroup;
  string purposeName;
  string referenceDateField;
  LegalGroundRule[] legalGroundRules;
  SysTime createdAt;
  SysTime updatedAt;

  Json toJson() const {
    Json grounds = Json.emptyArray;
    foreach (ground; legalGroundRules) {
      grounds ~= ground.toJson();
    }

    Json payload = Json.emptyObject;
    payload["tenant_id"] = tenantId;
    payload["purpose_rule_id"] = purposeRuleId;
    payload["application_group"] = applicationGroup;
    payload["purpose_name"] = purposeName;
    payload["reference_date_field"] = referenceDateField;
    payload["legal_grounds"] = grounds;
    payload["created_at"] = createdAt.toISOExtString();
    payload["updated_at"] = updatedAt.toISOExtString();
    return payload;
  }
}

struct DataSubjectRecord {
  UUID tenantId;
  string dataSubjectId;
  string applicationGroup;
  string legalGround;
  string referenceDate;
  bool blocked;
  bool deleted;
  SysTime updatedAt;

  Json toJson() const {
    Json payload = Json.emptyObject;
    payload["tenant_id"] = tenantId;
    payload["data_subject_id"] = dataSubjectId;
    payload["application_group"] = applicationGroup;
    payload["legal_ground"] = legalGround;
    payload["reference_date"] = referenceDate;
    payload["blocked"] = blocked;
    payload["deleted"] = deleted;
    payload["updated_at"] = updatedAt.toISOExtString();
    return payload;
  }
}

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

  Json toJson() const {
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

BusinessPurposeRule parseBusinessPurposeRule(string tenantId, Json request) {
  BusinessPurposeRule rule;
  rule.tenantId = tenantId;
  rule.purposeRuleId = request.getString("purpose_rule_id", createId());
  rule.applicationGroup = request.getString("application_group", "");
  rule.purposeName = request.getString("purpose_name", "");
  rule.referenceDateField = request.getString("reference_date_field", "transaction_date");
  rule.createdAt = Clock.currTime();
  rule.updatedAt = rule.createdAt;

  if ("legal_grounds" in request && request["legal_grounds"].isArray) {
    foreach (item; request["legal_grounds"].toArray) {
      if (!item.isObject) {
        continue;
      }
      LegalGroundRule ground;
      ground.legalGround = item.getString("legal_ground", "");
      ground.residenceDays = cast(int)item.getInteger("residence_days", 0);
      ground.retentionDays = cast(int)item.getInteger("retention_days", 0);
      rule.legalGroundRules ~= ground;
    }
  }

  return rule;
}

DataSubjectRecord parseDataSubjectRecord(string tenantId, string subjectId, Json request) {
  DataSubjectRecord record;
  record.tenantId = tenantId;
  record.dataSubjectId = subjectId;
  record.applicationGroup = request.getString("application_group", "");
  record.legalGround = request.getString("legal_ground", "");
  record.referenceDate = request.getString("reference_date", "");
  record.blocked = request.getBoolean("blocked", false);
  record.deleted = request.getBoolean("deleted", false);
  record.updatedAt = Clock.currTime();
  return record;
}

ArchiveDestructionJob parseArchiveDestructionJob(string tenantId, string operation, Json request) {
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
