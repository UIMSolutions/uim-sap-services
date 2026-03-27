module uim.sap.mdg.service;

import uim.sap.mdg;

mixin(ShowModule!());

@safe:

class MDGService : SAPService {
  private MDGStore _store;

  this(MDGConfig config) {
    super(config);

    _store = new MDGStore;
  }

  Json upsertBusinessPartner(UUID tenantId, Json request) {
    validateId(tenantId, "Tenant ID");
    auto bp = businessPartnerFromJson(tenantId, request, _config.defaultApprover);
    validateBusinessPartner(bp);
    bp.updatedAt = Clock.currTime();

    auto saved = _store.upsertBusinessPartner(bp);

    return Json.emptyObject
      .set("success", true)
      .set("governance_mode", "workflow-driven")
      .set("business_partner", saved.toJson());
  }

  Json upsertBusinessPartnersBatch(UUID tenantId, Json request) {
    validateId(tenantId, "Tenant ID");
    if (!("business_partners" in request) || !request["business_partners"].isArray) {
      throw new MDGValidationException("business_partners array is required");
    }

    Json resources = Json.emptyArray;
    long processed = 0;

    foreach (item; request["business_partners"].toArray) {
      auto bp = businessPartnerFromJson(tenantId, item, _config.defaultApprover);
      validateBusinessPartner(bp);
      bp.updatedAt = Clock.currTime();
      auto saved = _store.upsertBusinessPartner(bp);
      resources ~= saved.toJson();
      ++processed;
    }

    return Json.emptyObject
      .set("success", true)
      .set("processed", processed)
      .set("resources", resources)
      .set("message", "Multiple business partners processed");
  }

  Json listBusinessPartners(UUID tenantId) {
    validateId(tenantId, "Tenant ID");

    Json resources = Json.emptyArray;
    foreach (bp; _store.listBusinessPartners(tenantId)) {
      resources ~= bp.toJson();
    }

    return Json.emptyObject
      .set("tenant_id", tenantId)
      .set("resources", resources)
      .set("total_results", cast(long)resources.length);
  }

  Json updateWorkflowState(UUID tenantId, string bpId, Json request) {
    validateId(tenantId, "Tenant ID");
    validateId(bpId, "Business partner ID");
    if (!("workflow_state" in request) || request["workflow_state"].type != Json.Type.string) {
      throw new MDGValidationException("workflow_state is required");
    }

    auto bp = _store.getBusinessPartner(tenantId, bpId);
    if (bp.bpId.length == 0) {
      throw new MDGNotFoundException("Business partner", tenantId ~ "/" ~ bpId);
    }

    auto nextState = normalizeWorkflowState(request["workflow_state"].get!string);
    if (!isValidWorkflowState(nextState)) {
      throw new MDGValidationException("Unsupported workflow state: " ~ nextState);
    }

    bp.workflowState = nextState;
    if ("approver" in request && request["approver"].isString) {
      bp.approver = request["approver"].get!string;
    }
    bp.updatedAt = Clock.currTime();

    auto saved = _store.upsertBusinessPartner(bp);

    return Json.emptyObject
      .set("success", true)
      .set("business_partner", saved.toJson());
  }

  Json ingestBusinessPartners(UUID tenantId, Json request) {
    validateId(tenantId, "Tenant ID");

    if (!("source" in request) || request["source"].type != Json.Type.string) {
      throw new MDGValidationException("source must be provided as 'file' or 'api'");
    }
    auto source = toLower(request["source"].get!string);
    if (source != "file" && source != "api") {
      throw new MDGValidationException("source must be 'file' or 'api'");
    }

    Json items = Json.emptyArray;
    if ("business_partners" in request && request["business_partners"].isArray) {
      items = request["business_partners"];
    }

    long ingested = 0;
    foreach (item; items.toArray) {
      auto bp = businessPartnerFromJson(tenantId, item, _config.defaultApprover);
      bp.sourceSystem = source;
      validateBusinessPartner(bp);
      _store.upsertBusinessPartner(bp);
      ++ingested;
    }

    return Json.emptyObject
      .set("success", true)
      .set("tenant_id", tenantId)
      .set("source", source)
      .set("ingested", ingested);
  }

  Json detectDuplicates(UUID tenantId) {
    validateId(tenantId, "Tenant ID");

    auto bps = _store.listBusinessPartners(tenantId);

    auto candidates = detectDuplicateCandidates(tenantId, bps).map!(c => c.toJson).array;
    
    return Json.emptyObject
      .set("tenant_id", tenantId)
      .set("resources", candidates)
      .set("total_results", cast(long)candidates.length);
  }

  Json mergeDuplicates(UUID tenantId, Json request) {
    validateId(tenantId, "Tenant ID");
    if (!("primary_bp_id" in request) || request["primary_bp_id"].type != Json.Type.string) {
      throw new MDGValidationException("primary_bp_id is required");
    }
    if (!("duplicate_bp_id" in request) || request["duplicate_bp_id"].type != Json.Type.string) {
      throw new MDGValidationException("duplicate_bp_id is required");
    }

    auto primaryId = request["primary_bp_id"].get!string;
    auto duplicateId = request["duplicate_bp_id"].get!string;

    auto primary = _store.getBusinessPartner(tenantId, primaryId);
    auto duplicate = _store.getBusinessPartner(tenantId, duplicateId);
    if (primary.bpId.length == 0) {
      throw new MDGNotFoundException("Primary business partner", tenantId ~ "/" ~ primaryId);
    }
    if (duplicate.bpId.length == 0) {
      throw new MDGNotFoundException("Duplicate business partner", tenantId ~ "/" ~ duplicateId);
    }

    if (primary.email.length == 0)
      primary.email = duplicate.email;
    if (primary.phone.length == 0)
      primary.phone = duplicate.phone;
    if (primary.country.length == 0)
      primary.country = duplicate.country;
    if (primary.externalId.length == 0)
      primary.externalId = duplicate.externalId;
    primary.updatedAt = Clock.currTime();

    auto saved = _store.upsertBusinessPartner(primary);
    _store.deleteBusinessPartner(tenantId, duplicateId);

    return Json.emptyObject
      .set("success", true)
      .set("best_record", saved.toJson())
      .set("merged_duplicate_bp_id", duplicateId);
  }

  Json upsertRule(UUID tenantId, string ruleId, Json request) {
    validateId(tenantId, "Tenant ID");
    validateId(ruleId, "Rule ID");

    auto rule = qualityRuleFromJson(tenantId, ruleId, request);
    validateRule(rule);
    auto saved = _store.upsertRule(rule);

    return Json.emptyObject
      .set("success", true)
      .set("rule", saved.toJson())
      .set("collaborative_management", true);
  }

  Json listRules(UUID tenantId) {
    validateId(tenantId, "Tenant ID");
    Json resources = Json.emptyArray;
    foreach (rule; _store.listRules(tenantId)) {
      resources ~= rule.toJson();
    }

    return Json.emptyObject
      .set("tenant_id", tenantId)
      .set("resources", resources)
      .set("total_results", cast(long)resources.length);
  }

  Json evaluateDataQuality(UUID tenantId) {
    validateId(tenantId, "Tenant ID");
    auto rules = _store.listRules(tenantId);
    auto bps = _store.listBusinessPartners(tenantId);

    Json violations = Json.emptyArray;
    long evaluated = 0;
    long failed = 0;

    foreach (bp; bps) {
      foreach (rule; rules) {
        if (!rule.enabled) {
          continue;
        }
        ++evaluated;
        if (!passesRule(bp, rule)) {
          ++failed;
          Json item = Json.emptyObject;
          item["bp_id"] = bp.bpId;
          item["rule_id"] = rule.ruleId;
          item["rule_name"] = rule.name;
          item["field"] = rule.field;
          violations ~= item;
        }
      }
    }

    long passed = evaluated - failed;
    double score = evaluated > 0 ? (cast(double)passed / cast(double)evaluated) * 100.0 : 100.0;

    return Json.emptyObject
      .set("tenant_id", tenantId)
      .set("evaluated_checks", evaluated)
      .set("passed_checks", passed)
      .set("failed_checks", failed)
      .set("quality_score", score)
      .set("violations", violations);
  }

  private bool passesRule(MDGBusinessPartner bp, MDGQualityRule rule) {
    auto field = toLower(rule.field);
    auto ruleType = toLower(rule.ruleType);

    string value;
    switch (field) {
    case "name":
      value = bp.name;
      break;
    case "email":
      value = bp.email;
      break;
    case "phone":
      value = bp.phone;
      break;
    case "country":
      value = bp.country;
      break;
    default:
      value = "";
      break;
    }

    switch (ruleType) {
    case "required":
      return value.length > 0;
    case "min_length":
      long minValue = 1;
      if ("min" in rule.options && rule.options["min"].isInteger) {
        minValue = rule.options["min"].get!long;
      }
      return value.length >= minValue;
    case "contains":
      if (!("needle" in rule.options) || rule.options["needle"].type != Json.Type.string) {
        return true;
      }
      return value.canFind(rule.options["needle"].get!string);
    default:
      return true;
    }
  }

  private void validateBusinessPartner(MDGBusinessPartner bp) {
    if (bp.name.length == 0) {
      throw new MDGValidationException("Business partner name is required");
    }
    if (!isValidWorkflowState(bp.workflowState)) {
      throw new MDGValidationException("Invalid workflow_state: " ~ bp.workflowState);
    }
  }

  private void validateRule(MDGQualityRule rule) {
    if (rule.name.length == 0) {
      throw new MDGValidationException("Rule name is required");
    }
    if (rule.field.length == 0) {
      throw new MDGValidationException("Rule field is required");
    }
    if (rule.ruleType.length == 0) {
      throw new MDGValidationException("Rule rule_type is required");
    }
  }
}
