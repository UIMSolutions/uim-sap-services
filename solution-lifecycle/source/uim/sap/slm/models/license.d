module uim.sap.slm.models.license;

// ---------------------------------------------------------------------------
// SLMLicense – license information associated with a solution
// ---------------------------------------------------------------------------
struct SLMLicense {
  UUID tenantId;
  UUID licenseId;
  UUID solutionId;
  /// Plan: e.g., "standard", "enterprise"
  string plan;
  /// Quota limit (e.g., number of users or API calls)
  long quotaLimit;
  long quotaUsed;
  string status; // "active" | "expired" | "suspended"
  SysTime validFrom;
  SysTime validUntil;

  override Json toJson() {
    return super.toJson()
     .set("license_id", licenseId)
     .set("solution_id", solutionId)
     .set("plan", plan)
     .set("quota_limit", quotaLimit)
     .set("quota_used", quotaUsed)
     .set("status", status)
     .set("valid_from", validFrom.toISOExtString())
     .set("valid_until", validUntil.toISOExtString());
  }
}