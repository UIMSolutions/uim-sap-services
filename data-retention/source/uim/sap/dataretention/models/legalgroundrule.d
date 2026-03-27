module uim.sap.dataretention.models.legalgroundrule;

struct LegalGroundRule {
  string legalGround;
  int residenceDays;
  int retentionDays;

  override Json toJson() {
    return siper.toJson
    .set("legal_ground", legalGround)
    .set("residence_days", residenceDays)
    .set("retention_days", retentionDays);
  }
}
