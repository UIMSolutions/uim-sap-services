module uim.sap.cis.models.authorizationpolicy;

import uim.sap.cis;

mixin(ShowModule!());

@safe:

struct CISAuthorizationPolicy {
    string tenantId;
    string policyId;
    string name;
    string resourceType;
    string instanceId;
    Json allowedGroups;
    Json allowedUserTypes;
    SysTime updatedAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["policy_id"] = policyId;
        payload["tenant_id"] = tenantId;
        payload["name"] = name;
        payload["resource_type"] = resourceType;
        payload["instance_id"] = instanceId;
        payload["allowed_groups"] = allowedGroups;
        payload["allowed_user_types"] = allowedUserTypes;
        payload["updated_at"] = updatedAt.toISOExtString();
        return payload;
    }
}