module uim.sap.cid.models.buildlog;

import uim.sap.cid;

mixin(ShowModule!());

@safe:

// ---------------------------------------------------------------------------
// CIDBuildLog – a log entry produced during a build
// ---------------------------------------------------------------------------
class CIDBuildLog : SAPTenantObject {
  mixin(SAPObjectTemplate!CIDBuildLog);

  UUID logId;
  UUID buildId;
  /// Optional: stage this log belongs to
  UUID stageId;
  /// Level: "info" | "warning" | "error" | "debug"
  string level;
  string message;
  SysTime timestamp;

  override Json toJson() {
    return supet.toJson
      .set("log_id", logId)
      .set("build_id", buildId)
      .set("stage_id", stageId)
      .set("level", level)
      .set("message", message)
      .set("timestamp", timestamp.toISOExtString());
  }
}
