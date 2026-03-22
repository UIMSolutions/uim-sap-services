/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.featureflags.service;

import uim.sap.featureflags;

mixin(ShowModule!());

@safe:

/** Business-logic layer for the Feature Flags service.
 *
 *  Capabilities:
 *  - Create / read / update / delete Boolean and String feature flags
 *  - Evaluate flags at runtime (Boolean → true/false, String → variation)
 *  - Direct delivery: target specific identifier values
 *  - Percentage delivery: distribute across variations by weight
 *  - Export all flags from a tenant
 *  - Import flags into a tenant (replaces existing flags)
 *  - Full multitenancy: every operation is scoped to a tenantId
 */
class FFLService : SAPService {
  private FFLStore _store;

  this(FFLConfig config) {
    super(config);

    _store = new FFLStore;
  }

  // ─── Flag CRUD ────────────────────────────────────────────

  Json createFlag(UUID tenantId, Json request) {
    validateId(tenantId, "Tenant ID");

    auto flag = flagFromJson(tenantId, request);
    if (flag.flagName.length == 0) {
      throw new FFLValidationException("flag_name is required");
    }
    if (flag.flagType != "boolean" && flag.flagType != "string") {
      throw new FFLValidationException("flag_type must be 'boolean' or 'string'");
    }

    auto existing = _store.getFlag(tenantId, flag.flagName);
    if (existing.flagName.length > 0) {
      throw new FFLValidationException("Flag already exists: " ~ flag.flagName);
    }

    // String flags must have at least two variations
    if (flag.flagType == "string" && flag.variations.length < 2) {
      throw new FFLValidationException("String flags require at least two variations");
    }

    auto saved = _store.upsertFlag(flag);

    Json result = Json.emptyObject;
    result["success"] = true;
    result["flag"] = saved.toJson();
    return result;
  }

  Json listFlags(UUID tenantId) {
    validateId(tenantId, "Tenant ID");

    Json resources = Json.emptyArray;
    foreach (flag; _store.listFlags(tenantId)) {
      resources ~= flag.toJson();
    }

    Json result = Json.emptyObject;
    result["tenant_id"] = tenantId;
    result["resources"] = resources;
    result["total_results"] = cast(long)resources.length;
    return result;
  }

  Json getFlag(UUID tenantId, string flagName) {
    validateId(tenantId, "Tenant ID");
    validateId(flagName, "Flag name");

    auto flag = _store.getFlag(tenantId, flagName);
    if (flag.flagName.length == 0) {
      throw new FFLNotFoundException("Flag", tenantId ~ "/" ~ flagName);
    }

    Json result = Json.emptyObject;
    result["flag"] = flag.toJson();
    return result;
  }

  Json updateFlag(UUID tenantId, string flagName, Json request) {
    validateId(tenantId, "Tenant ID");
    validateId(flagName, "Flag name");

    auto existing = _store.getFlag(tenantId, flagName);
    if (existing.flagName.length == 0) {
      throw new FFLNotFoundException("Flag", tenantId ~ "/" ~ flagName);
    }

    // Apply partial updates
    if ("description" in request && request["description"].isString) {
      existing.description = request["description"].get!string;
    }
    if ("enabled" in request && request["enabled"].type == Json.Type.bool_) {
      existing.enabled = request["enabled"].get!bool;
    }
    if ("status" in request && request["status"].isString) {
      existing.status = request["status"].get!string;
    }
    if ("default_variation_id" in request && request["default_variation_id"].type == Json
      .Type.string) {
      existing.defaultVariationId = request["default_variation_id"].get!string;
    }

    // Replace variations if supplied
    if ("variations" in request && request["variations"].isArray) {
      FFLVariation[] newVars;
      () @trusted {
        foreach (item; request["variations"]) {
          newVars ~= variationFromJson(item);
        }
      }();
      existing.variations = newVars;
    }

    // Replace direct rules if supplied
    if ("direct_rules" in request && request["direct_rules"].isArray) {
      FFLDirectRule[] newRules;
      () @trusted {
        foreach (item; request["direct_rules"]) {
          newRules ~= directRuleFromJson(item);
        }
      }();
      existing.directRules = newRules;
    }

    // Replace percentage rule if supplied
    if ("percentage_rule" in request && request["percentage_rule"].isObject) {
      existing.percentageRule = percentageRuleFromJson(request["percentage_rule"]);
    }

    existing.updatedAt = Clock.currTime().toISOExtString();
    auto saved = _store.upsertFlag(existing);

    Json result = Json.emptyObject;
    result["success"] = true;
    result["flag"] = saved.toJson();
    return result;
  }

  Json deleteFlag(UUID tenantId, string flagName) {
    validateId(tenantId, "Tenant ID");
    validateId(flagName, "Flag name");

    if (!_store.deleteFlag(tenantId, flagName)) {
      throw new FFLNotFoundException("Flag", tenantId ~ "/" ~ flagName);
    }

    Json result = Json.emptyObject;
    result["success"] = true;
    result["message"] = "Flag deleted: " ~ flagName;
    return result;
  }

  // ─── Toggle (quick enable/disable) ───────────────────────

  Json toggleFlag(UUID tenantId, string flagName) {
    validateId(tenantId, "Tenant ID");
    validateId(flagName, "Flag name");

    auto flag = _store.getFlag(tenantId, flagName);
    if (flag.flagName.length == 0) {
      throw new FFLNotFoundException("Flag", tenantId ~ "/" ~ flagName);
    }

    flag.enabled = !flag.enabled;
    flag.updatedAt = Clock.currTime().toISOExtString();
    auto saved = _store.upsertFlag(flag);

    return Json.emptyObject
    .set("success", true)
    .set("flag_name", saved.flagName)
    .set("enabled", saved.enabled);
  }

  // ─── Evaluation engine ────────────────────────────────────

  /** Evaluate a feature flag.
     *
     *  For Boolean flags the result is true/false.
     *  For String flags the result is the variation value selected by:
     *    1. Direct delivery — if the identifier matches a direct rule
     *    2. Percentage delivery — if a percentage rule is configured
     *    3. Default — the default variation
     *
     *  If the flag is inactive (`status != "active"`), Boolean flags
     *  return false and String flags return the default variation.
     */
  Json evaluateFlag(UUID tenantId, string flagName, string identifier) {
    validateId(tenantId, "Tenant ID");
    validateId(flagName, "Flag name");

    auto flag = _store.getFlag(tenantId, flagName);
    if (flag.flagName.length == 0) {
      throw new FFLNotFoundException("Flag", tenantId ~ "/" ~ flagName);
    }

    // Track evaluation
    _store.incrementEvaluationCount(tenantId, flagName);

    FFLEvaluation eval;
    eval.flagId = flag.flagId;
    eval.flagName = flag.flagName;
    eval.flagType = flag.flagType;
    eval.evaluatedAt = Clock.currTime().toISOExtString();

    if (flag.flagType == "boolean") {
      eval = evaluateBoolean(flag, identifier, eval);
    } else {
      eval = evaluateString(flag, identifier, eval);
    }

    Json result = Json.emptyObject;
    result["success"] = true;
    result["evaluation"] = eval.toJson();
    return result;
  }

  // ─── Export / Import ──────────────────────────────────────

  Json exportFlags(UUID tenantId) {
    validateId(tenantId, "Tenant ID");

    FFLExportData data;
    data.tenantId = UUID(tenantId);
    data.exportedAt = Clock.currTime().toISOExtString();
    data.serviceVersion = _config.serviceVersion;
    data.flags = _store.listFlags(tenantId);

    Json result = Json.emptyObject;
    result["success"] = true;
    result["export"] = data.toJson();
    return result;
  }

  Json importFlags(UUID tenantId, Json request) {
    validateId(tenantId, "Tenant ID");

    if (!("flags" in request) || !request["flags"].isArray) {
      throw new FFLValidationException("Request must contain a 'flags' array");
    }

    FFLFlag[] flags;
    () @trusted {
      foreach (item; request["flags"]) {
        auto flag = flagFromJson(tenantId, item);
        if (flag.flagName.length == 0) {
          throw new FFLValidationException("Each flag must have a flag_name");
        }
        // Ensure tenant ownership
        flag.tenantId = UUID(tenantId);
        flag.updatedAt = Clock.currTime().toISOExtString();
        flags ~= flag;
      }
    }();

    auto imported = _store.importFlags(tenantId, flags);

    Json result = Json.emptyObject;
    result["success"] = true;
    result["tenant_id"] = tenantId;
    result["imported_count"] = imported;
    result["message"] = "Flags imported successfully";
    return result;
  }

  // ─── Dashboard ────────────────────────────────────────────

  Json dashboard(UUID tenantId) {
    validateId(tenantId, "Tenant ID");

    auto flags = _store.listFlags(tenantId);

    long totalBoolean = 0;
    long totalString = 0;
    long totalEnabled = 0;
    long totalActive = 0;
    long totalEvaluations = 0;

    foreach (flag; flags) {
      if (flag.flagType == "boolean")
        ++totalBoolean;
      else
        ++totalString;

      if (flag.enabled)
        ++totalEnabled;
      if (flag.status == "active")
        ++totalActive;
      totalEvaluations += flag.evaluationCount;
    }

    return Json.emptyObject
    .set("tenant_id", tenantId)
    .set("total_flags", cast(long)flags.length)
    .set("boolean_flags", totalBoolean)
    .set("string_flags", totalString)
    .set("enabled_flags", totalEnabled)
    .set("active_flags", totalActive)
    .set("total_evaluations", totalEvaluations);
  }

  // ─── Private evaluation helpers ───────────────────────────

  private FFLEvaluation evaluateBoolean(FFLFlag flag, string identifier, FFLEvaluation eval) {
    // Inactive flag → always false
    if (flag.status != "active") {
      eval.booleanValue = false;
      eval.strategy = "default";
      return eval;
    }

    // Direct delivery: check if the identifier is targeted
    if (identifier.length > 0) {
      foreach (rule; flag.directRules) {
        foreach (targetId; rule.identifiers) {
          if (targetId == identifier) {
            eval.booleanValue = rule.booleanValue;
            eval.strategy = "direct";
            return eval;
          }
        }
      }
    }

    // Default: return the flag's enabled state
    eval.booleanValue = flag.enabled;
    eval.strategy = "default";
    return eval;
  }

  private FFLEvaluation evaluateString(FFLFlag flag, string identifier, FFLEvaluation eval) {
    if (flag.variations.length == 0) {
      eval.strategy = "default";
      return eval;
    }

    // Inactive flag → default variation
    if (flag.status != "active") {
      return resolveDefaultVariation(flag, eval);
    }

    // Direct delivery
    if (identifier.length > 0) {
      foreach (rule; flag.directRules) {
        foreach (targetId; rule.identifiers) {
          if (targetId == identifier) {
            // Find the targeted variation
            foreach (v; flag.variations) {
              if (v.variationId == rule.variationId) {
                eval.variationId = v.variationId;
                eval.variationValue = v.value;
                eval.strategy = "direct";
                return eval;
              }
            }
          }
        }
      }
    }

    // Percentage delivery
    if (flag.percentageRule.entries.length > 0 && identifier.length > 0) {
      auto bucket = percentageBucket(identifier);
      uint cumulative = 0;
      foreach (entry; flag.percentageRule.entries) {
        cumulative += entry.weight;
        if (bucket < cumulative) {
          foreach (v; flag.variations) {
            if (v.variationId == entry.variationId) {
              eval.variationId = v.variationId;
              eval.variationValue = v.value;
              eval.strategy = "percentage";
              return eval;
            }
          }
        }
      }
    }

    // Default variation
    return resolveDefaultVariation(flag, eval);
  }

  private FFLEvaluation resolveDefaultVariation(FFLFlag flag, FFLEvaluation eval) {
    // Try explicit default
    if (flag.defaultVariationId.length > 0) {
      foreach (v; flag.variations) {
        if (v.variationId == flag.defaultVariationId) {
          eval.variationId = v.variationId;
          eval.variationValue = v.value;
          eval.strategy = "default";
          return eval;
        }
      }
    }

    // Fall back to first variation
    if (flag.variations.length > 0) {
      eval.variationId = flag.variations[0].variationId;
      eval.variationValue = flag.variations[0].value;
    }
    eval.strategy = "default";
    return eval;
  }


}
