/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.featureflags.models.evaluation;

import uim.sap.featureflags;

mixin(ShowModule!());

@safe:

/** Result returned by the flag-evaluation endpoint. */
class FFLEvaluation : SAPObject {
  mixin(SAPObjectTemplate!FFLEvalution);

  UUID flagId;
  string flagName;
  string flagType;

  // Boolean result
  bool booleanValue = false;

  // String result
  UUID variationId;
  string variationValue;

  // Metadata
  string strategy; // "default" | "direct" | "percentage"
  string evaluatedAt;

  override Json toJson() {
    return super.toJson()
      .set("flag_id", flagId)
      .set("flag_name", flagName)
      .set("flag_type", flagType)
      .set("boolean_value", booleanValue)
      .set("variation_id", variationId)
      .set("variation_value", variationValue)
      .set("strategy", strategy)
      .set("evaluated_at", evaluatedAt);
  }
}
