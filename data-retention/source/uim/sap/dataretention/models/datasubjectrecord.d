module uim.sap.dataretention.models.datasubjectrecord;

import uim.sap.dataretention;

mixin(ShowModule!());

@safe:

class DataSubjectRecord : SAPTenantObject {
  mixin(SAPTenantObjectTemplate!DataSubjectRecord);

  UUID dataSubjectId;
  string applicationGroup;
  string legalGround;
  string referenceDate;
  bool blocked;
  bool deleted;

  override Json toJson() {
    return super.toJson()
      .set("data_subject_id", dataSubjectId)
      .set("application_group", applicationGroup)
      .set("legal_ground", legalGround)
      .set("reference_date", referenceDate)
      .set("blocked", blocked)
      .set("deleted", deleted);
  }

  DataSubjectRecord parseDataSubjectRecord(UUID tenantId, UUID subjectId, Json request) {
    DataSubjectRecord record = new DataSubjectRecord(request);
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
}
