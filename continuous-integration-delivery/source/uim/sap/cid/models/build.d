module uim.sap.cid.models.build;

import uim.sap.cid;

mixin(ShowModule!());

@safe:

// ---------------------------------------------------------------------------
// CIDBuild – a single pipeline run / execution
// ---------------------------------------------------------------------------
class CIDBuild : SAPTenantObject {
  mixin(SAPObjectTemplate!CIDBuild);

  string buildId;
  string pipelineId;
  /// Build number (sequential per pipeline)
  int buildNumber;
  /// Git commit hash that triggered this build
  string commitHash;
  /// Branch being built
  string branch;
  /// Status: "pending" | "running" | "success" | "failure" | "aborted"
  string status;
  /// Who/what triggered the build
  string triggeredBy;
  /// Duration in seconds (filled after completion)
  long durationSecs;
  SysTime startedAt;
  SysTime finishedAt;

  override Json toJson() {
    return super.toJson()
      .set("build_id", buildId)
      .set("pipeline_id", pipelineId)
      .set("build_number", buildNumber)
      .set("commit_hash", commitHash)
      .set("branch", branch)
      .set("status", status)
      .set("triggered_by", triggeredBy)
      .set("duration_secs", durationSecs)
      .set("started_at", startedAt.toISOExtString())
      .set("finished_at", finishedAt.toISOExtString());
  }
}
