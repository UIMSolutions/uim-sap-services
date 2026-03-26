/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.featureflags.models.variation;

import uim.sap.featureflags;

mixin(ShowModule!());

@safe:

/** A named variation of a String-type feature flag.
 *
 *  Each variation carries a `value` that is returned when the flag
 *  evaluates to this variation, plus a `weight` used by the
 *  percentage-delivery strategy to distribute traffic.
 */
class FFLVariation : SAPObject {
  mixin(SAPObjectTemplate!FFLVariation);

    string variationId;
    string name;
    string value;
    uint weight = 0; // percentage weight (0-100) for percentage delivery

    override Json toJson()  {
        return super.toJson
        .set("variation_id", variationId)
        .set("name", name)
        .set("value", value)
        .set("weight", cast(long) weight);
    }

    static FFLVariation opCall(Json request) {
    FFLVariation v;
    v.variationId = randomUUID();

    if ("name" in request && request["name"].isString) {
        v.name = request["name"].get!string;
    }
    if ("value" in request && request["value"].isString) {
        v.value = request["value"].get!string;
    }
    if ("weight" in request && request["weight"].isInteger) {
        v.weight = cast(uint) request["weight"].get!long;
    }
    if ("variation_id" in request && request["variation_id"].isString) {
        v.variationId = request["variation_id"].get!string;
    }

    return v;
}

}

