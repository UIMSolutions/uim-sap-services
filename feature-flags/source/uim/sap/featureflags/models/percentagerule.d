/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.featureflags.models.percentagerule;

import uim.sap.featureflags;

mixin(ShowModule!());

@safe:

/** A percentage-delivery rule that distributes traffic across variations.
 *
 *  Each entry maps a `variationId` to a `weight` (0-100).  The weights
 *  across all entries should normally sum to 100.  During evaluation,
 *  the identifier is hashed to a consistent bucket (0-99) and the
 *  bucket is matched against the cumulative weight ranges.
 */
struct FFLPercentageEntry {
    string variationId;
    uint weight = 0;

    override Json toJson()  {
        Json j = Json.emptyObject;
        j["variation_id"] = variationId;
        j["weight"] = cast(long) weight;
        return j;
    }
}

struct FFLPercentageRule {
    string ruleId;
    FFLPercentageEntry[] entries;

    override Json toJson()  {
        Json j = Json.emptyObject;
        j["rule_id"] = ruleId;

        Json arr = Json.emptyArray;
        foreach (entry; entries) {
            arr ~= entry.toJson();
        }
        j["entries"] = arr;
        return j;
    }
}

FFLPercentageRule percentageRuleFromJson(Json request) {
    FFLPercentageRule r;
    r.ruleId = randomUUID().toString();

    if ("entries" in request && request["entries"].isArray) {
        () @trusted {
            foreach (item; request["entries"]) {
                FFLPercentageEntry entry;
                if ("variation_id" in item && item["variation_id"].isString) {
                    entry.variationId = item["variation_id"].get!string;
                }
                if ("weight" in item && item["weight"].type == Json.Type.int_) {
                    entry.weight = cast(uint) item["weight"].get!long;
                }
                r.entries ~= entry;
            }
        }();
    }
    if ("rule_id" in request && request["rule_id"].isString) {
        r.ruleId = request["rule_id"].get!string;
    }

    return r;
}
