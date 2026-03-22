module uim.sap.cid.models.buildstage;

import uim.sap.cid;

mixin(ShowModule!());

@safe:

// ---------------------------------------------------------------------------
// CIDBuildStage – one stage within a build run
// ---------------------------------------------------------------------------
struct CIDBuildStage {
  UUID buildId;
  UUID stageId;
  /// Stage name: "build" | "test" | "deploy" | custom
  string name;
  /// Order within the build (1-based)
  int ordinal;
  /// Status: "pending" | "running" | "success" | "failure" | "skipped"
  string status;
  long durationSecs;
  SysTime startedAt;
  SysTime finishedAt;

  override Json toJson() {
    return super.toJson()
      .set("build_id", buildId)
      .set("stage_id", stageId)
      .set("name", name)
      .set("ordinal", ordinal)
      .set("status", status)
      .set("duration_secs", durationSecs)
      .set("started_at", startedAt.toISOExtString())
      .set("finished_at", finishedAt.toISOExtString());
  }
}
