module uim.sap.cis.models.delegationrule;

import uim.sap.cis;

mixin(ShowModule!());

@safe:

struct CISDelegationRule {
    string tenantId;
    string ruleId;
    string targetIdp;
    bool isDefault = false;
    string emailDomain;
    string userType;
    string group;
    SysTime updatedAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["rule_id"] = ruleId;
        payload["tenant_id"] = tenantId;
        payload["target_idp"] = targetIdp;
        payload["is_default"] = isDefault;
        payload["email_domain"] = emailDomain;
        payload["user_type"] = userType;
        payload["group"] = group;
        payload["updated_at"] = updatedAt.toISOExtString();
        return payload;
    }
}
