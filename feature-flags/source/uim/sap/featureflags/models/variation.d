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
struct FFVariation {
    string variationId;
    string name;
    string value;
    uint weight = 0; // percentage weight (0-100) for percentage delivery

    Json toJson() const {
        Json j = Json.emptyObject;
        j["variation_id"] = variationId;
        j["name"] = name;
        j["value"] = value;
        j["weight"] = cast(long) weight;
        return j;
    }
}

FFVariation variationFromJson(Json request) {
    FFVariation v;
    v.variationId = randomUUID().toString();

    if ("name" in request && request["name"].type == Json.Type.string) {
        v.name = request["name"].get!string;
    }
    if ("value" in request && request["value"].type == Json.Type.string) {
        v.value = request["value"].get!string;
    }
    if ("weight" in request && request["weight"].type == Json.Type.int_) {
        v.weight = cast(uint) request["weight"].get!long;
    }
    if ("variation_id" in request && request["variation_id"].type == Json.Type.string) {
        v.variationId = request["variation_id"].get!string;
    }

    return v;
}
