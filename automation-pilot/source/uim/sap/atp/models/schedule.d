module uim.sap.atp.models.schedule;

import uim.sap.atp;

mixin(ShowModule!());

@safe:

class ATPSchedule : SAPTenantObject {
  mixin(SAPObjectTemplate!ATPSchedule);

  UUID scheduleId;
  string targetType;
  UUID targetId;
  string mode;
  string expression;
  bool active;

  override Json toJson() {
    Json payload = super.toJson;

    payload["schedule_id"] = scheduleId;
    payload["target_type"] = targetType;
    payload["target_id"] = targetId;
    payload["mode"] = mode;
    payload["expression"] = expression;
    payload["active"] = active;

    return payload;
  }
}
