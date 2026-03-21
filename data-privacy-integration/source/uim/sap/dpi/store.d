/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.dpi.store;

import core.sync.mutex : Mutex;
import uim.sap.dpi;

mixin(ShowModule!());

@safe:

class DPIStore : SAPStore {
  private DPIRetentionRule[string] _rules;
  private DPIPersonalDataRecord[string] _records;
  private DPIExport[string] _exports;
  private string[string] _pseudonymMap;
  private Mutex _lock;

  this() {
    _lock = new Mutex;
  }

  DPIRetentionRule upsertRule(DPIRetentionRule rule) {
    synchronized (_lock) {
      _rules[scopedKey(rule.tenantId, "rule", rule.ruleId)] = rule;
      return rule;
    }
  }

  DPIRetentionRule[] listRules(string tenantId) {
    DPIRetentionRule[] values;
    synchronized (_lock) {
      foreach (key, value; _rules)
        if (belongsTo(key, tenantId))
          values ~= value;
    }
    return values;
  }

  DPIPersonalDataRecord upsertRecord(DPIPersonalDataRecord record) {
    synchronized (_lock) {
      auto key = scopedKey(record.tenantId, "record", record.recordId);
      if (auto existing = key in _records)
        record.createdAt = existing.createdAt;
      _records[key] = record;
      return record;
    }
  }

  DPIPersonalDataRecord[] listRecords(string tenantId) {
    DPIPersonalDataRecord[] values;
    synchronized (_lock) {
      foreach (key, value; _records) {
        if (belongsTo(key, tenantId) && !value.deleted)
          values ~= value;
      }
    }
    return values;
  }

  DPIPersonalDataRecord[] listSubjectRecords(string tenantId, string subjectId) {
    DPIPersonalDataRecord[] values;
    synchronized (_lock) {
      foreach (key, value; _records) {
        if (belongsTo(key, tenantId) && !value.deleted && value.subjectId == subjectId)
          values ~= value;
      }
    }
    return values;
  }

  long deleteSubjectRecords(string tenantId, string subjectId) {
    long deleted;
    synchronized (_lock) {
      foreach (key, ref value; _records) {
        if (belongsTo(key, tenantId) && !value.deleted && value.subjectId == subjectId) {
          value.deleted = true;
          ++deleted;
        }
      }
    }
    return deleted;
  }

  long retentionDelete(string tenantId, string category) {
    long deleted;
    auto normalizedCategory = toLower(category);
    synchronized (_lock) {
      foreach (key, ref value; _records) {
        if (belongsTo(key, tenantId) && !value.deleted && toLower(value.category) == normalizedCategory) {
          value.deleted = true;
          ++deleted;
        }
      }
    }
    return deleted;
  }

  DPIExport saveExport(DPIExport item) {
    synchronized (_lock) {
      _exports[scopedKey(item.tenantId, "export", item.exportId)] = item;
      return item;
    }
  }

  string pseudonymFor(string tenantId, string value) {
    auto key = tenantId ~ "::" ~ value;
    synchronized (_lock) {
      if (auto existing = key in _pseudonymMap) {
        return *existing;
      }
      auto pseudonym = "PSEUDO-" ~ tenantId ~ "-" ~ to!string(_pseudonymMap.length);
      _pseudonymMap[key] = pseudonym;
      return pseudonym;
    }
  }

  private string scopedKey(string tenantId, string scopePart, string id) {
    return tenantId ~ ":" ~ scopePart ~ ":" ~ id;
  }

  private bool belongsTo(string key, string tenantId) {
    return key.length > tenantId.length + 1 && key[0 .. tenantId.length] == tenantId && key[tenantId
      .length] == ':';
  }
}
