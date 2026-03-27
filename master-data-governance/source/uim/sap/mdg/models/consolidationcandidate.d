module uim.sap.mdg.models.consolidationcandidate;

import uim.sap.mdg;

mixin(ShowModule!());

@safe:

class MDGConsolidationCandidate : SAPTenantObject {
  mixin(SAPTenantObject!MDGConsolidationCandidate);

  UUID primaryBpId;
  UUID duplicateBpId;
  long score;

  override Json toJson() {
    return super.toJson()
      .set("primary_bp_id", primaryBpId)
      .set("duplicate_bp_id", duplicateBpId)
      .set("score", score);
  }
}

MDGConsolidationCandidate[] detectDuplicateCandidates(UUID tenantId, MDGBusinessPartner[] businessPartners) {
  auto builder = appender!(MDGConsolidationCandidate[])();

  for (size_t i = 0; i < businessPartners.length; ++i) {
    for (size_t j = i + 1; j < businessPartners.length; ++j) {
      auto a = businessPartners[i];
      auto b = businessPartners[j];

      long score = 0;
      if (a.name.length > 0 && b.name.length > 0 && toLower(a.name) == toLower(b.name)) {
        score += 60;
      }
      if (a.email.length > 0 && b.email.length > 0 && toLower(a.email) == toLower(b.email)) {
        score += 25;
      }
      if (a.phone.length > 0 && b.phone.length > 0 && a.phone == b.phone) {
        score += 15;
      }

      if (score >= 60) {
        MDGConsolidationCandidate candidate = new MDGConsolidationCandidate;
        candidate.tenantId = tenantId;
        candidate.primaryBpId = a.bpId;
        candidate.duplicateBpId = b.bpId;
        candidate.score = score;
        builder.put(candidate);
      }
    }
  }

  return builder.data;
}
