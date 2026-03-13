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
struct FFLEvaluation {
    string flagId;
    string flagName;
    string flagType;

    // Boolean result
    bool booleanValue = false;

    // String result
    string variationId;
    string variationValue;

    // Metadata
    string strategy;    // "default" | "direct" | "percentage"
    string evaluatedAt;

    Json toJson() const {
        Json j = Json.emptyObject;
        j["flag_id"] = flagId;
        j["flag_name"] = flagName;
        j["flag_type"] = flagType;
        j["boolean_value"] = booleanValue;
        j["variation_id"] = variationId;
        j["variation_value"] = variationValue;
        j["strategy"] = strategy;
        j["evaluated_at"] = evaluatedAt;
        return j;
    }
}
