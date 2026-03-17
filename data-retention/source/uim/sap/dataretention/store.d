module uim.sap.dataretention.store;

import core.sync.mutex : Mutex;

import uim.sap.dataretention;

mixin(ShowModule!());

@safe:

class DRMStore : SAPStore {
  private BusinessPurposeRule[string] _purposeRules;
  private DataSubjectRecord[string] _dataSubjects;
  private ArchiveDestructionJob[string] _jobs;
  private Mutex _lock;

  this() {
    _lock = new Mutex;
  }

  BusinessPurposeRule upsertPurposeRule(BusinessPurposeRule rule) {
    synchronized (_lock) {
      auto key = scopedKey(rule.tenantId, "purpose", rule.purposeRuleId);
      if (auto existing = key in _purposeRules) {
        rule.createdAt = existing.createdAt;
      }
      _purposeRules[key] = rule;
      return rule;
    }
  }

  BusinessPurposeRule[] listPurposeRules(string tenantId) {
    BusinessPurposeRule[] rules;
    synchronized (_lock) {
      foreach (key, value; _purposeRules) {
        if (belongsTo(key, tenantId)) {
          rules ~= value;
        }
      }
    }
    return rules;
  }

  BusinessPurposeRule getPurposeRule(string tenantId, string purposeRuleId) {
    synchronized (_lock) {
      auto key = scopedKey(tenantId, "purpose", purposeRuleId);
      if (auto value = key in _purposeRules) {
        return *value;
      }
    }
    return BusinessPurposeRule.init;
  }

  DataSubjectRecord upsertDataSubject(DataSubjectRecord record) {
    synchronized (_lock) {
      auto key = scopedKey(record.tenantId, "subject", record.dataSubjectId);
      _dataSubjects[key] = record;
      return record;
    }
  }

  DataSubjectRecord getDataSubject(string tenantId, string dataSubjectId) {
    synchronized (_lock) {
      auto key = scopedKey(tenantId, "subject", dataSubjectId);
      if (auto value = key in _dataSubjects) {
        return *value;
      }
    }
    return DataSubjectRecord.init;
  }

  DataSubjectRecord[] listDataSubjects(string tenantId) {
    DataSubjectRecord[] subjects;
    synchronized (_lock) {
      foreach (key, value; _dataSubjects) {
        if (belongsTo(key, tenantId)) {
          subjects ~= value;
        }
      }
    }
    return subjects;
  }

  ArchiveDestructionJob appendJob(ArchiveDestructionJob job) {
    synchronized (_lock) {
      _jobs[scopedKey(job.tenantId, "job", job.jobId)] = job;
      return job;
    }
  }

  ArchiveDestructionJob[] listJobs(string tenantId) {
    ArchiveDestructionJob[] jobs;
    synchronized (_lock) {
      foreach (key, value; _jobs) {
        if (belongsTo(key, tenantId)) {
          jobs ~= value;
        }
      }
    }
    return jobs;
  }

  private string scopedKey(string tenantId, string scopePart, string id) {
    return tenantId ~ ":" ~ scopePart ~ ":" ~ id;
  }

  private bool belongsTo(string key, string tenantId) {
    return key.length > tenantId.length + 1 && key[0 .. tenantId.length] == tenantId && key[tenantId.length] == ':';
  }
}
