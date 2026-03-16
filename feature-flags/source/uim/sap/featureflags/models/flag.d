/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
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
class FFLFlag : SAPTenantObject {
  mixin(SAPObjectTemplate!FFLFlag);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(iniData)) {
      return false;
    }

if ("flag_name" in request && request["flag_name"].isString) {
      flagName = request["flag_name"].get!string;
    }
    if ("description" in request && request["description"].isString) {
      description = request["description"].get!string;
    }
    if ("flag_type" in request && request["flag_type"].isString) {
      flagType = request["flag_type"].get!string;
    }
    if ("enabled" in request && request["enabled"].type == Json.Type.bool_) {
      enabled = request["enabled"].get!bool;
    }
    if ("status" in request && request["status"].isString) {
      status = request["status"].get!string;
    }
    if ("default_variation_id" in request && request["default_variation_id"].isString) {
      defaultVariationId = request["default_variation_id"].get!string;
    }

    return true;
  }
  string flagId;
  string flagName;
  string description;
  string flagType = "boolean"; // "boolean" | "string"

  // Boolean-specific
  bool enabled = false;

  // String-specific
  FFLVariation[] variations;
  string defaultVariationId;

  // Delivery rules
  FFLDirectRule[] directRules;
  FFLPercentageRule percentageRule;

  // Metadata
  string status = "active"; // "active" | "inactive"
  long evaluationCount = 0;
  string createdAt;
  string updatedAt;

  override Json toJson() {
    Json vars = variations.map!(v => v.toJson()).array.toJson;
    Json dr = directRules.map!(rule => rule.toJson()).array.toJson;

    return super.toJson()
      .set("flag_id", flagId)
      .set("flag_name", flagName)
      .set("description", description)
      .set("flag_type", flagType)
      .set("enabled", enabled)
      .set("variations", vars)
      .set("default_variation_id", defaultVariationId)
      .set("direct_rules", dr)
      .set("percentage_rule", percentageRule.toJson())
      .set("status", status)
      .set("evaluation_count", evaluationCount);
  }

  static FFLFlag opCall(string tenantId, Json request) {
    FFLFlag f = new FFLFlag(request);
    f.tenantId = UUID(tenantId);
    f.flagId = randomUUID().toString();

    // Parse variations
    if ("variations" in request && request["variations"].isArray) {
      () @trusted {
        f.variations = request["variations"].toArray.map!(item => FFLVariation(item)).array;
      }();
    }

    // Parse direct rules
    if ("direct_rules" in request && request["direct_rules"].isArray) {
      () @trusted {
        f.directRules = request["direct_rules"].toArray.map!(item => directRuleFromJson(item)).array;
      }();
    }

    // Parse percentage rule
    if ("percentage_rule" in request && request["percentage_rule"].isObject) {
      f.percentageRule = percentageRuleFromJson(request["percentage_rule"]);
    }

    // Import support: preserve IDs when present
    if ("flag_id" in request && request["flag_id"].isString) {
      f.flagId = request["flag_id"].get!string;
    }

    if ("evaluation_count" in request && request["evaluation_count"].type == Json.Type.int_) {
      f.evaluationCount = request["evaluation_count"].get!long;
    }

    f.createdAt = Clock.currTime().toISOExtString();
    f.updatedAt = f.createdAt;
    return f;
  }
}
