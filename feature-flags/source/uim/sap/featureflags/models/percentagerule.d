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
class FFLPercentageEntry : SAPObject {
  mixin(SAPObjectTemplate!FFLPercentageEntry);

  UUID variationId;
  uint weight = 0;

  override Json toJson() {
    return super.toJson()
      .set("variation_id", variationId)
      .set("weight", cast(long)weight);
  }
}

class FFLPercentageRule : SAPObject {
  mixin(SAPObjectTemplate!FFLPercentageRule);

  string ruleId;
  FFLPercentageEntry[] entries;

  override Json toJson() {
    Json arr = entries.map!(e => e.toJson)().array;

    return super.toJson()
      .set("rule_id", ruleId)
      .set("entries", arr);
  }

  static FFLPercentageRule opCall(Json request) {
    FFLPercentageRule r;
    r.ruleId = randomUUID();

    if ("entries" in request && request["entries"].isArray) {
      () @trusted {
        foreach (item; request["entries"]) {
          FFLPercentageEntry entry;
          if ("variation_id" in item && item["variation_id"].isString) {
            entry.variationId = item["variation_id"].get!string;
          }
          if ("weight" in item && item["weight"].isInteger) {
            entry.weight = cast(uint)item["weight"].get!long;
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
}
