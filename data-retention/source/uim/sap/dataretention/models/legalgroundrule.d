module uim.sap.dataretention.models.legalgroundrule;

struct LegalGroundRule {
  string legalGround;
  int residenceDays;
  int retentionDays;

  override Json toJson() {
    Json payload = Json.emptyObject;
    payload["legal_ground"] = legalGround;
    payload["residence_days"] = residenceDays;
    payload["retention_days"] = retentionDays;
    return payload;
  }
}
