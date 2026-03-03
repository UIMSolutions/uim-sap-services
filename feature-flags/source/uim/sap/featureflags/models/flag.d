module uim.sap.featureflags.models.flag;

import uim.sap.featureflags;

mixin(ShowModule!());

@safe:

/** The core feature-flag entity.
 *
 *  `flagType` is either `"boolean"` or `"string"`.
 *
 *  Boolean flags carry a single `enabled` field that is returned on
 *  evaluation (true / false).
 *
 *  String flags carry one or more `variations` and optionally a
 *  `defaultVariationId` that is served when no rule matches.
 *
 *  Both flag types support `directRules` (targeting specific identifiers)
 *  and, for String flags, `percentageRule` (distributing traffic across
 *  variations by weight).
 */
struct FFFlag {
    string tenantId;
    string flagId;
    string flagName;
    string description;
    string flagType = "boolean"; // "boolean" | "string"

    // Boolean-specific
    bool enabled = false;

    // String-specific
    FFVariation[] variations;
    string defaultVariationId;

    // Delivery rules
    FFDirectRule[] directRules;
    FFPercentageRule percentageRule;

    // Metadata
    string status = "active";         // "active" | "inactive"
    long evaluationCount = 0;
    string createdAt;
    string updatedAt;

    Json toJson() const {
        Json j = Json.emptyObject;
        j["tenant_id"] = tenantId;
        j["flag_id"] = flagId;
        j["flag_name"] = flagName;
        j["description"] = description;
        j["flag_type"] = flagType;
        j["enabled"] = enabled;

        Json vars = Json.emptyArray;
        foreach (v; variations) {
            vars ~= v.toJson();
        }
        j["variations"] = vars;
        j["default_variation_id"] = defaultVariationId;

        Json dr = Json.emptyArray;
        foreach (rule; directRules) {
            dr ~= rule.toJson();
        }
        j["direct_rules"] = dr;
        j["percentage_rule"] = percentageRule.toJson();

        j["status"] = status;
        j["evaluation_count"] = evaluationCount;
        j["created_at"] = createdAt;
        j["updated_at"] = updatedAt;
        return j;
    }
}

FFFlag flagFromJson(string tenantId, Json request) {
    FFFlag f;
    f.tenantId = tenantId;
    f.flagId = randomUUID().toString();

    if ("flag_name" in request && request["flag_name"].type == Json.Type.string) {
        f.flagName = request["flag_name"].get!string;
    }
    if ("description" in request && request["description"].type == Json.Type.string) {
        f.description = request["description"].get!string;
    }
    if ("flag_type" in request && request["flag_type"].type == Json.Type.string) {
        f.flagType = request["flag_type"].get!string;
    }
    if ("enabled" in request && request["enabled"].type == Json.Type.bool_) {
        f.enabled = request["enabled"].get!bool;
    }
    if ("status" in request && request["status"].type == Json.Type.string) {
        f.status = request["status"].get!string;
    }
    if ("default_variation_id" in request && request["default_variation_id"].type == Json.Type.string) {
        f.defaultVariationId = request["default_variation_id"].get!string;
    }

    // Parse variations
    if ("variations" in request && request["variations"].type == Json.Type.array) {
        foreach (item; request["variations"]) {
            f.variations ~= variationFromJson(item);
        }
    }

    // Parse direct rules
    if ("direct_rules" in request && request["direct_rules"].type == Json.Type.array) {
        foreach (item; request["direct_rules"]) {
            f.directRules ~= directRuleFromJson(item);
        }
    }

    // Parse percentage rule
    if ("percentage_rule" in request && request["percentage_rule"].type == Json.Type.object) {
        f.percentageRule = percentageRuleFromJson(request["percentage_rule"]);
    }

    // Import support: preserve IDs when present
    if ("flag_id" in request && request["flag_id"].type == Json.Type.string) {
        f.flagId = request["flag_id"].get!string;
    }
    if ("evaluation_count" in request && request["evaluation_count"].type == Json.Type.int_) {
        f.evaluationCount = request["evaluation_count"].get!long;
    }

    f.createdAt = Clock.currTime().toISOExtString();
    f.updatedAt = f.createdAt;
    return f;
}
