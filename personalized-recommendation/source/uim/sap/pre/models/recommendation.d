/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.pre.models.recommendation;

import uim.sap.pre;

mixin(ShowModule!());

@safe:

/// A single recommendation result returned to the caller.
class PRERecommendation : SAPTenantObject {
  mixin(SAPTenantObjectTemplate!PRERecommendation);

  UUID recommendationId;
  UUID userId;
  UUID itemId;
  string modelId;
  PRERecommendationType recommendationType;
  double score = 0.0;
  size_t rank;
  string[string] context;
  string explanation;
}

Json toJson() {
  Json obj = Json.emptyObject;
  foreach (k, v; r.context)
    obj[k] = v;

  return super.toJson
    .set("recommendationId", r.recommendationId)
    .set("userId", r.userId)
    .set("itemId", r.itemId)
    .set("tenantId", r.tenantId)
    .set("modelId", r.modelId)
    .set("recommendationType", r.recommendationType.to!string)
    .set("score", r.score)
    .set("rank", cast(long)r.rank)
    .set("context", obj)
    .set("explanation", r.explanation)
    .set("createdAt", r.createdAt);
}
