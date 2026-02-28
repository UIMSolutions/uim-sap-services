module uim.sap.cis.models.riskpolicy;

import uim.sap.cis;

mixin(ShowModule!());

@safe:

struct CISRiskPolicy {
    string tenantId;
    string policyId;
    Json ipRanges;
    Json groups;
    string userType;
    string authenticationMethod;
    bool requireTwoFactor = true;
    SysTime updatedAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["policy_id"] = policyId;
        payload["tenant_id"] = tenantId;
        payload["ip_ranges"] = ipRanges;
        payload["groups"] = groups;
        payload["user_type"] = userType;
        payload["authentication_method"] = authenticationMethod;
        payload["require_two_factor"] = requireTwoFactor;
        payload["updated_at"] = updatedAt.toISOExtString();
        return payload;
    }
}