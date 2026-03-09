module uim.sap.mdg.store;

import core.sync.mutex : Mutex;

import uim.sap.mdg;

mixin(ShowModule!());

@safe:
class MDGStore : SAPStore {
  private MDGBusinessPartner[string] _businessPartners;
  private MDGQualityRule[string] _rules;
  private Mutex _lock;

  this() {
    _lock = new Mutex;
  }

  MDGBusinessPartner upsertBusinessPartner(MDGBusinessPartner bp) {
    synchronized (_lock) {
      auto key = bpKey(bp.tenantId, bp.bpId);
      if (auto existing = key in _businessPartners) {
        bp.createdAt = existing.createdAt;
      }
      _businessPartners[key] = bp;
      return bp;
    }
  }

  bool deleteBusinessPartner(string tenantId, string bpId) {
    synchronized (_lock) {
      auto key = bpKey(tenantId, bpId);
      if ((key in _businessPartners) is null) {
        return false;
      }
      _businessPartners.remove(key);
      return true;
    }
  }

  MDGBusinessPartner getBusinessPartner(string tenantId, string bpId) {
    synchronized (_lock) {
      auto key = bpKey(tenantId, bpId);
      if (auto value = key in _businessPartners) {
        return *value;
      }
    }
    return MDGBusinessPartner.init;
  }

  MDGBusinessPartner[] listBusinessPartners(string tenantId) {
    MDGBusinessPartner[] values;
    synchronized (_lock) {
      foreach (key, bp; _businessPartners) {
        if (belongsToTenant(key, tenantId)) {
          values ~= bp;
        }
      }
    }
    return values;
  }

  MDGQualityRule upsertRule(MDGQualityRule rule) {
    synchronized (_lock) {
      auto key = ruleKey(rule.tenantId, rule.ruleId);
      _rules[key] = rule;
      return rule;
    }
  }

  MDGQualityRule getRule(string tenantId, string ruleId) {
    synchronized (_lock) {
      auto key = ruleKey(tenantId, ruleId);
      if (auto rule = key in _rules) {
        return *rule;
      }
    }
    return MDGQualityRule.init;
  }

  MDGQualityRule[] listRules(string tenantId) {
    MDGQualityRule[] values;
    synchronized (_lock) {
      foreach (key, rule; _rules) {
        if (belongsToTenant(key, tenantId)) {
          values ~= rule;
        }
      }
    }
    return values;
  }

  private string bpKey(string tenantId, string bpId) {
    return tenantId ~ ":bp:" ~ bpId;
  }

  private string ruleKey(string tenantId, string ruleId) {
    return tenantId ~ ":rule:" ~ ruleId;
  }

  private bool belongsToTenant(string key, string tenantId) {
    return key.length > tenantId.length + 1 && key[0 .. tenantId.length] == tenantId && key[tenantId
      .length] == ':';
  }
}
