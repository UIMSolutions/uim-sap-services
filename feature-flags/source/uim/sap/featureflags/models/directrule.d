module uim.sap.featureflags.models.directrule;

import uim.sap.featureflags;

mixin(ShowModule!());

@safe:

/** A direct-delivery rule that targets specific identifier values.
 *
 *  When the application sends an `identifier` query parameter during
 *  evaluation, it is matched against `identifiers[]`.  If matched the
 *  flag returns `variationId` (String flag) or `booleanValue` (Boolean
 *  flag) instead of the default.
 */
struct FFLDirectRule {
    string ruleId;
    string[] identifiers;     // targeted identifier values
    string variationId;       // for String flags — which variation to serve
    bool booleanValue = true; // for Boolean flags — override value

    Json toJson() const {
        Json j = Json.emptyObject;
        j["rule_id"] = ruleId;

        Json ids = Json.emptyArray;
        foreach (id; identifiers) {
            ids ~= Json(id);
        }
        j["identifiers"] = ids;
        j["variation_id"] = variationId;
        j["boolean_value"] = booleanValue;
        return j;
    }
}

FFLDirectRule directRuleFromJson(Json request) {
    FFLDirectRule r;
    r.ruleId = randomUUID().toString();

    if ("identifiers" in request && request["identifiers"].type == Json.Type.array) {
        () @trusted {
            foreach (item; request["identifiers"]) {
                if (item.type == Json.Type.string) {
                    r.identifiers ~= item.get!string;
                }
            }
        }();
    }
    if ("variation_id" in request && request["variation_id"].type == Json.Type.string) {
        r.variationId = request["variation_id"].get!string;
    }
    if ("boolean_value" in request && request["boolean_value"].type == Json.Type.bool_) {
        r.booleanValue = request["boolean_value"].get!bool;
    }
    if ("rule_id" in request && request["rule_id"].type == Json.Type.string) {
        r.ruleId = request["rule_id"].get!string;
    }

    return r;
}
