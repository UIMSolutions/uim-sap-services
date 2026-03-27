module uim.sap.mdg.store;

import core.sync.mutex : Mutex;

import uim.sap.mdg;

mixin(ShowModule!());

@safe:
class MDGStore : SAPStore {
  private MDGBusinessPartner[string] _businessPartners;
  private MDGQualityRule[string] _rules;

  MDGBusinessPartner upsertBusinessPartner(MDGBusinessPartner bp) {
    synchronized (_lock) {
      auto key = bpKey(bp.tenantId, bp.bpId);
      if (key in _businessPartners) {
        bp.createdAt = _businessPartners[key].createdAt;
      }
      _businessPartners[key] = bp;
      return bp;
    }
  }

  bool deleteBusinessPartner(UUID tenantId, string bpId) {
    synchronized (_lock) {
      auto key = bpKey(tenantId, bpId);
      if (!(key in _businessPartners)) {
        return false;
      }
      _businessPartners.remove(key);
      return true;
    }
  }

  MDGBusinessPartner getBusinessPartner(UUID tenantId, string bpId) {
    synchronized (_lock) {
      auto key = bpKey(tenantId, bpId);
      if (key in _businessPartners) {
        return _businessPartners[key];
      }
    }
    return MDGBusinessPartner.init;
  }

  MDGBusinessPartner[] listBusinessPartners(UUID tenantId) {
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

  MDGQualityRule getRule(UUID tenantId, string ruleId) {
    synchronized (_lock) {
      auto key = ruleKey(tenantId, ruleId);
      if (key in _rules) {
        return _rules[key];
      }
    }
    return MDGQualityRule.init;
  }

  MDGQualityRule[] listRules(UUID tenantId) {
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

  private string bpKey(UUID tenantId, string bpId) {
    return tenantId ~ ":bp:" ~ bpId;
  }

  private string ruleKey(UUID tenantId, string ruleId) {
    return tenantId ~ ":rule:" ~ ruleId;
  }

  private bool belongsToTenant(string key, UUID tenantId) {
    return key.length > tenantId.length + 1 && key[0 .. tenantId.length] == tenantId && key[tenantId
      .length] == ':';
  }
}
