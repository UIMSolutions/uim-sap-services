module uim.sap.dataretention.models.datasubjectrecord;

import uim.sap.dataretention;

mixin(ShowModule!());

@safe:

struct DataSubjectRecord {
  UUID tenantId;
  string dataSubjectId;
  string applicationGroup;
  string legalGround;
  string referenceDate;
  bool blocked;
  bool deleted;
  SysTime updatedAt;

  override Json toJson() {
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

DataSubjectRecord parseDataSubjectRecord(UUID tenantId, string subjectId, Json request) {
  DataSubjectRecord record;
  record.tenantId = tenantId;
  record.dataSubjectId = subjectId;
  record.applicationGroup = request.getString("application_group", "");
  record.legalGround = request.getString("legal_ground", "");
  record.referenceDate = request.getString("reference_date", "");
  record.blocked = optionalBoolean("blocked", false);
  record.deleted = optionalBoolean("deleted", false);
  record.updatedAt = Clock.currTime();
  return record;
}
