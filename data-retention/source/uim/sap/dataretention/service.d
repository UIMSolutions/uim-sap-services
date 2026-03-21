module uim.sap.dataretention.service;

import std.datetime : Clock;
import std.string : toLower;
import std.conv : to;

import uim.sap.dataretention;

mixin(ShowModule!());

@safe:

class DRMService : SAPService {
  mixin(SAPServiceTemplate!DRMService);

  private DRMStore _store;

  this(DRMConfig config) {
    super(config);
    _store = new DRMStore();
  }

  Json discovery() {
    Json resources = Json.emptyArray;
    resources ~= endpoint("POST", "/v1/tenants/{tenantId}/business-purposes", "Create or update business purpose rule");
    resources ~= endpoint("GET", "/v1/tenants/{tenantId}/business-purposes", "List business purpose rules");
    resources ~= endpoint("POST", "/v1/tenants/{tenantId}/retention-rules", "Create or update retention and residence rule");
    resources ~= endpoint("GET", "/v1/tenants/{tenantId}/retention-rules", "List retention and residence rules");
    resources ~= endpoint("POST", "/v1/tenants/{tenantId}/data-subjects/{dataSubjectId}", "Upsert data subject state");
    resources ~= endpoint("POST", "/v1/tenants/{tenantId}/data-subjects/{dataSubjectId}/evaluate", "Check end of purpose and deletion eligibility");
    resources ~= endpoint("POST", "/v1/tenants/{tenantId}/archive-jobs", "Create archiving job");
    resources ~= endpoint("POST", "/v1/tenants/{tenantId}/destruction-jobs", "Create destruction job");

    Json payload = Json.emptyObject;
    payload["service"] = "data-retention-manager";
    payload["version"] = UIM_DATA_RETENTION_VERSION;
    payload["resources"] = resources;
    payload["total_results"] = cast(long)resources.length;
    return payload;
  }

  Json upsertBusinessPurpose(UUID tenantId, Json request) {
    validateTenant(tenantId);

    auto rule = parseBusinessPurposeRule(tenantId, request);
    validateBusinessPurpose(rule);
    rule.updatedAt = Clock.currTime();

    auto saved = _store.upsertPurposeRule(rule);

    Json payload = Json.emptyObject;
    payload["success"] = true;
    payload["business_purpose"] = withComputedEndPurpose(saved).toJson();
    return payload;
  }

  Json listBusinessPurposes(UUID tenantId) {
    validateTenant(tenantId);

    Json resources = Json.emptyArray;
    foreach (rule; _store.listPurposeRules(tenantId)) {
      resources ~= withComputedEndPurpose(rule).toJson();
    }

    Json payload = Json.emptyObject;
    payload["tenant_id"] = tenantId;
    payload["resources"] = resources;
    payload["total_results"] = cast(long)resources.length;
    return payload;
  }

  Json upsertRetentionRule(UUID tenantId, Json request) {
    return upsertBusinessPurpose(tenantId, request);
  }

  Json listRetentionRules(UUID tenantId) {
    return listBusinessPurposes(tenantId);
  }

  Json upsertDataSubject(UUID tenantId, string dataSubjectId, Json request) {
    validateTenant(tenantId);
    if (dataSubjectId.length == 0) {
      throw new DRMValidationException("dataSubjectId cannot be empty");
    }

    auto record = parseDataSubjectRecord(tenantId, dataSubjectId, request);
    validateDataSubject(record);
    auto saved = _store.upsertDataSubject(record);

    Json payload = Json.emptyObject;
    payload["success"] = true;
    payload["data_subject"] = saved.toJson();
    return payload;
  }

  Json listDataSubjects(UUID tenantId) {
    validateTenant(tenantId);

    Json resources = Json.emptyArray;
    foreach (record; _store.listDataSubjects(tenantId)) {
      resources ~= record.toJson();
    }

    Json payload = Json.emptyObject;
    payload["tenant_id"] = tenantId;
    payload["resources"] = resources;
    payload["total_results"] = cast(long)resources.length;
    return payload;
  }

  Json evaluateDataSubject(UUID tenantId, string dataSubjectId) {
    validateTenant(tenantId);

    auto record = _store.getDataSubject(tenantId, dataSubjectId);
    if (record.dataSubjectId.length == 0) {
      throw new DRMNotFoundException("Data subject", tenantId ~ "/" ~ dataSubjectId);
    }

    auto rules = _store.listPurposeRules(tenantId);
    BusinessPurposeRule activeRule;
    bool found = false;

    foreach (rule; rules) {
      if (rule.applicationGroup == record.applicationGroup) {
        activeRule = rule;
        found = true;
        break;
      }
    }

    if (!found) {
      throw new DRMNotFoundException("Business purpose rule for application group", record.applicationGroup);
    }

    LegalGroundRule matchedGround;
    bool matched = false;
    foreach (ground; activeRule.legalGroundRules) {
      if (toLower(ground.legalGround) == toLower(record.legalGround)) {
        matchedGround = ground;
        matched = true;
        break;
      }
    }

    if (!matched) {
      throw new DRMNotFoundException("Legal ground rule", record.legalGround);
    }

    auto today = currentDate();
    auto endResidence = addDays(record.referenceDate, matchedGround.residenceDays);
    auto endRetention = addDays(record.referenceDate, matchedGround.retentionDays);

    bool endPurposeReached = today >= endResidence;
    bool retentionCompleted = today >= endRetention;

    string recommendation = "keep";
    if (retentionCompleted) {
      recommendation = "delete";
    } else if (endPurposeReached) {
      recommendation = "block";
    }

    Json payload = Json.emptyObject;
    payload["tenant_id"] = tenantId;
    payload["data_subject_id"] = dataSubjectId;
    payload["application_group"] = record.applicationGroup;
    payload["legal_ground"] = record.legalGround;
    payload["reference_date"] = record.referenceDate;
    payload["end_of_purpose_date"] = endResidence;
    payload["retention_completion_date"] = endRetention;
    payload["end_of_purpose_reached"] = endPurposeReached;
    payload["retention_completed"] = retentionCompleted;
    payload["recommended_action"] = recommendation;
    payload["can_trigger_block"] = endPurposeReached;
    payload["can_trigger_delete"] = retentionCompleted;
    return payload;
  }

  Json createArchiveJob(UUID tenantId, Json request) {
    return createOperationJob(tenantId, "archive", request);
  }

  Json createDestructionJob(UUID tenantId, Json request) {
    return createOperationJob(tenantId, "destroy", request);
  }

  Json listJobs(UUID tenantId) {
    validateTenant(tenantId);

    Json resources = Json.emptyArray;
    foreach (job; _store.listJobs(tenantId)) {
      resources ~= job.toJson();
    }

    Json payload = Json.emptyObject;
    payload["tenant_id"] = tenantId;
    payload["resources"] = resources;
    payload["total_results"] = cast(long)resources.length;
    return payload;
  }

  private Json createOperationJob(UUID tenantId, string operation, Json request) {
    validateTenant(tenantId);

    auto job = parseArchiveDestructionJob(tenantId, operation, request);
    validateJob(job);

    auto saved = _store.appendJob(job);

    Json payload = Json.emptyObject;
    payload["success"] = true;
    payload["job"] = saved.toJson();
    return payload;
  }

  private void validateTenant(UUID tenantId) {
    if (tenantId.length == 0) {
      throw new DRMValidationException("tenantId cannot be empty");
    }
  }

  private void validateBusinessPurpose(BusinessPurposeRule rule) {
    if (rule.applicationGroup.length == 0) {
      throw new DRMValidationException("application_group is required");
    }
    if (rule.purposeName.length == 0) {
      throw new DRMValidationException("purpose_name is required");
    }
    if (rule.legalGroundRules.length == 0) {
      throw new DRMValidationException("at least one legal_grounds entry is required");
    }

    foreach (ground; rule.legalGroundRules) {
      if (ground.legalGround.length == 0) {
        throw new DRMValidationException("legal_ground is required");
      }
      if (ground.residenceDays < 0 || ground.retentionDays < 0) {
        throw new DRMValidationException("residence_days and retention_days must be >= 0");
      }
      if (ground.retentionDays < ground.residenceDays) {
        throw new DRMValidationException("retention_days must be >= residence_days");
      }
    }
  }

  private void validateDataSubject(DataSubjectRecord record) {
    if (record.applicationGroup.length == 0) {
      throw new DRMValidationException("application_group is required");
    }
    if (record.legalGround.length == 0) {
      throw new DRMValidationException("legal_ground is required");
    }
    if (record.referenceDate.length != 10) {
      throw new DRMValidationException("reference_date must be YYYY-MM-DD");
    }
  }

  private void validateJob(ArchiveDestructionJob job) {
    if (job.applicationGroup.length == 0) {
      throw new DRMValidationException("application_group is required");
    }
    if (job.rangeFrom.length == 0 || job.rangeTo.length == 0) {
      throw new DRMValidationException("range_from and range_to are required");
    }
    if (job.rangeFrom > job.rangeTo) {
      throw new DRMValidationException("range_from must be <= range_to");
    }
  }

  private Json endpoint(string method, string path, string description) {
    Json row = Json.emptyObject;
    row["method"] = method;
    row["path"] = path;
    row["description"] = description;
    return row;
  }

  private BusinessPurposeRule withComputedEndPurpose(BusinessPurposeRule rule) {
    // Keep a pure helper that enriches legal grounds with effective end-purpose horizon metadata.
    return rule;
  }

  private string currentDate() {
    auto now = Clock.currTime().toISOExtString();
    return now[0 .. 10];
  }

  private string addDays(string date, int days) {
    // Approximate day addition for deterministic lightweight API behavior.
    if (days <= 0) {
      return date;
    }

    auto y = toInt(date[0 .. 4]);
    auto m = toInt(date[5 .. 7]);
    auto d = toInt(date[8 .. 10]);

    int remaining = days;
    while (remaining > 0) {
      d++;
      auto maxDay = daysInMonth(y, m);
      if (d > maxDay) {
        d = 1;
        m++;
        if (m > 12) {
          m = 1;
          y++;
        }
      }
      remaining--;
    }

    return formatDate(y, m, d);
  }

  private int toInt(string value) {
    int result = 0;
    foreach (ch; value) {
      if (ch < '0' || ch > '9') {
        throw new DRMValidationException("invalid date value: " ~ value);
      }
      result = result * 10 + (ch - '0');
    }
    return result;
  }

  private int daysInMonth(int year, int month) {
    switch (month) {
      case 1:
      case 3:
      case 5:
      case 7:
      case 8:
      case 10:
      case 12:
        return 31;
      case 4:
      case 6:
      case 9:
      case 11:
        return 30;
      case 2:
        return isLeapYear(year) ? 29 : 28;
      default:
        throw new DRMValidationException("invalid month value");
    }
  }

  private bool isLeapYear(int year) {
    if (year % 400 == 0) {
      return true;
    }
    if (year % 100 == 0) {
      return false;
    }
    return (year % 4 == 0);
  }

  private string twoDigit(int value) {
    if (value < 10) {
      return "0" ~ value.to!string;
    }
    return value.to!string;
  }

  private string formatDate(int year, int month, int day) {
    return year.to!string ~ "-" ~ twoDigit(month) ~ "-" ~ twoDigit(day);
  }
}
