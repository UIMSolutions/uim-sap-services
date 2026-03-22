module uim.sap.cid.models.buildlog;

import uim.sap.cid;

mixin(ShowModule!());

@safe:

// ---------------------------------------------------------------------------
// CIDBuildLog – a log entry produced during a build
// ---------------------------------------------------------------------------
struct CIDBuildLog {
  UUID tenantId;
  string logId;
  string buildId;
  /// Optional: stage this log belongs to
  string stageId;
  /// Level: "info" | "warning" | "error" | "debug"
  string level;
  string message;
  SysTime timestamp;

  override Json toJson() {
    return Json.emptyObject
      .set("tenant_id", tenantId)
      .set("log_id", logId)
      .set("build_id", buildId)
      .set("stage_id", stageId)
      .set("level", level)
      .set("message", message)
      .set("timestamp", timestamp.toISOExtString());
  }
}
