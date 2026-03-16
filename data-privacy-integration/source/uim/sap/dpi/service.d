/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.dpi.service;

import uim.sap.dpi;

mixin(ShowModule!());

@safe:

class DPIService : SAPService {
  mixin(SAPServiceTemplate!DPIService);

  private DPIStore _store;

  this(DPIConfig config) {
    super(config);

    _store = new DPIStore;
  }

  override Json health() {
    Json healthInfo = super.health();
    healthInfo["multitenancy"] = true;
    return healthInfo;
  }

  Json ingestRecord(string tenantId, Json request) {
    validateTenant(tenantId);
    auto record = recordFromJson(tenantId, request);
    if (record.subjectId.length == 0)
      throw new DPIValidationException("subject_id is required");
    if (record.category.length == 0)
      throw new DPIValidationException("category is required");
    if (record.source.length == 0)
      throw new DPIValidationException("source is required");

    record.updatedAt = Clock.currTime();
    auto saved = _store.upsertRecord(record);

    Json payload = Json.emptyObject;
    payload["success"] = true;
    payload["record"] = saved.toJson();
    return payload;
  }

  Json upsertRetentionRule(string tenantId, string ruleId, Json request) {
    validateTenant(tenantId);
    validateId(ruleId, "Rule ID");

    DPIRetentionRule rule;
    rule.tenantId = UUID(tenantId);
    rule.ruleId = ruleId;
    rule.dataCategory = "default";
    rule.retentionDays = _config.defaultRetentionDays;
    rule.active = true;
    rule.updatedAt = Clock.currTime();

    if ("data_category" in request && request["data_category"].isString)
      rule.dataCategory = request["data_category"].get!string;
    if ("retention_days" in request && request["retention_days"].isInteger)
      rule.retentionDays = cast(int)request["retention_days"].get!long;
    if ("active" in request && request["active"].isBoolean)
      rule.active = request["active"].get!bool;

    if (rule.dataCategory.length == 0)
      throw new DPIValidationException("data_category is required");
    if (rule.retentionDays <= 0)
      throw new DPIValidationException("retention_days must be > 0");

    auto saved = _store.upsertRule(rule);

    Json payload = Json.emptyObject;
    payload["success"] = true;
    payload["rule"] = saved.toJson();
    return payload;
  }

  Json listRetentionRules(string tenantId) {
    validateTenant(tenantId);
    Json resources = Json.emptyArray;
    foreach (rule; _store.listRules(tenantId))
      resources ~= rule.toJson();

    Json payload = Json.emptyObject;
    payload["resources"] = resources;
    payload["total_results"] = cast(long)resources.length;
    return payload;
  }

  Json triggerRetentionDeletion(string tenantId, Json request) {
    validateTenant(tenantId);
    if (!("data_category" in request) || !request["data_category"].isString) {
      throw new DPIValidationException("data_category is required");
    }

    auto category = request["data_category"].get!string;
    auto deleted = _store.retentionDelete(tenantId, category);

    Json payload = Json.emptyObject;
    payload["success"] = true;
    payload["tenant_id"] = tenantId;
    payload["data_category"] = category;
    payload["deleted_records"] = deleted;
    payload["reason"] = "end-of-purpose";
    return payload;
  }

  Json generateReport(string tenantId, Json request) {
    validateTenant(tenantId);

    string subjectId;
    if ("subject_id" in request && request["subject_id"].isString) {
      subjectId = request["subject_id"].get!string;
    }

    DPIPersonalDataRecord[] records = subjectId.length > 0
      ? _store.listSubjectRecords(tenantId, subjectId) : _store.listRecords(tenantId);

    Json entries = Json.emptyArray;
    foreach (record; records)
      entries ~= record.toJson();

    Json payload = Json.emptyObject;
    payload["tenant_id"] = tenantId;
    payload["subject_id"] = subjectId;
    payload["records"] = entries;
    payload["total_results"] = cast(long)entries.length;
    payload["can_export"] = true;
    payload["can_trigger_correction"] = true;
    payload["can_trigger_deletion"] = true;
    return payload;
  }

  Json exportReport(string tenantId, Json request) {
    validateTenant(tenantId);
    if (!("subject_id" in request) || !request["subject_id"].isString) {
      throw new DPIValidationException("subject_id is required");
    }

    auto subjectId = request["subject_id"].get!string;
    auto records = _store.listSubjectRecords(tenantId, subjectId);
    Json entries = Json.emptyArray;
    foreach (record; records)
      entries ~= record.toJson();

    DPIExport exportItem;
    exportItem.tenantId = UUID(tenantId);
    exportItem.exportId = createId();
    exportItem.subjectId = subjectId;
    exportItem.records = entries;
    exportItem.createdAt = Clock.currTime();

    auto saved = _store.saveExport(exportItem);

    Json payload = Json.emptyObject;
    payload["success"] = true;
    payload["export"] = saved.toJson();
    payload["format"] = "json";
    return payload;
  }

  Json triggerCorrection(string tenantId, Json request) {
    validateTenant(tenantId);
    if (!("record_id" in request) || request["record_id"].type != Json.Type.string) {
      throw new DPIValidationException("record_id is required");
    }
    if (!("payload" in request) || !request["payload"].isObject) {
      throw new DPIValidationException("payload object is required");
    }

    auto recordId = request["record_id"].get!string;
    auto records = _store.listRecords(tenantId);
    bool corrected;
    foreach (record; records) {
      if (record.recordId == recordId) {
        auto updated = record;
        updated.payload = request["payload"];
        updated.updatedAt = Clock.currTime();
        _store.upsertRecord(updated);
        corrected = true;
        break;
      }
    }

    if (!corrected)
      throw new DPINotFoundException("Record", recordId);

    Json payload = Json.emptyObject;
    payload["success"] = true;
    payload["record_id"] = recordId;
    payload["operation"] = "correction_triggered";
    return payload;
  }

  Json triggerDeletion(string tenantId, Json request) {
    validateTenant(tenantId);
    if (!("subject_id" in request) || request["subject_id"].type != Json.Type.string) {
      throw new DPIValidationException("subject_id is required");
    }

    auto subjectId = request["subject_id"].get!string;
    auto deleted = _store.deleteSubjectRecords(tenantId, subjectId);

    Json payload = Json.emptyObject;
    payload["success"] = true;
    payload["subject_id"] = subjectId;
    payload["deleted_records"] = deleted;
    payload["operation"] = "deletion_triggered";
    return payload;
  }

  Json anonymize(Json request) {
    if (!("mode" in request) || request["mode"].type != Json.Type.string) {
      throw new DPIValidationException("mode is required: anonymize|pseudonymize");
    }

    auto mode = toLower(request["mode"].get!string);
    if (mode != "anonymize" && mode != "pseudonymize") {
      throw new DPIValidationException("mode must be anonymize or pseudonymize");
    }

    if (!("type" in request) || request["type"].type != Json.Type.string) {
      throw new DPIValidationException("type is required: free_text|text_file|image");
    }

    auto inputType = toLower(request["type"].get!string);
    if (inputType != "free_text" && inputType != "text_file" && inputType != "image") {
      throw new DPIValidationException("Unsupported type");
    }

    string text;
    if ("content" in request && request["content"].isString) {
      text = request["content"].get!string;
    }

    if (inputType == "image") {
      text = "image-metadata:" ~ text;
    }

    string output;
    if (mode == "anonymize") {
      output = anonymizeText(text);
    } else {
      string tenantId = "default";
      if ("tenant_id" in request && request["tenant_id"].isString) {
        tenantId = request["tenant_id"].get!string;
      }
      output = pseudonymizeText(tenantId, text);
    }

    Json payload = Json.emptyObject;
    payload["success"] = true;
    payload["mode"] = mode;
    payload["type"] = inputType;
    payload["result"] = output;
    return payload;
  }

  private string anonymizeText(string text) {
    auto emailRx = regex(`[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}`);
    auto phoneRx = regex(`\+?[0-9][0-9\-\s]{6,}`);
    auto result = replaceAll(text, emailRx, "[EMAIL]");
    result = replaceAll(result, phoneRx, "[PHONE]");
    return result;
  }

  private string pseudonymizeText(string tenantId, string text) {
    auto emailRx = regex(`[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}`);
    string result = text;

    foreach (capture; matchAll(result, emailRx)) {
      auto original = capture.hit;
      auto pseudo = _store.pseudonymFor(tenantId, original);
      result = result.replace(original, pseudo);
    }

    if (result == text) {
      return "PSEUDO::" ~ _store.pseudonymFor(tenantId, text);
    }
    return result;
  }

  private void validateTenant(string tenantId) {
    validateId(tenantId, "Tenant ID");
  }

  private void validateId(string value, string fieldName) {
    if (value.length == 0)
      throw new DPIValidationException(fieldName ~ " cannot be empty");
  }
}
