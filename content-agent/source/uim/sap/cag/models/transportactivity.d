module uim.sap.cag.models.transportactivity;

import uim.sap.cag;

mixin(ShowModule!());

@safe:

class CAGTransportActivity : SAPTenantEntity {
  mixin(SAPTenantEntityTemplate!CAGTransportActivity);

  UUID activityId;
  string assemblyId;
  string queueId;
  string status;
  string message;
  string initiatedBy;
  Json exportPayload;

  override Json toJson() {
    return super.toJson
      .set("activity_id", activityId)
      .set("assembly_id", assemblyId)
      .set("queue_id", queueId)
      .set("status", status)
      .set("message", message)
      .set("initiated_by", initiatedBy)
      .set("export_payload", exportPayload);
  }
}
