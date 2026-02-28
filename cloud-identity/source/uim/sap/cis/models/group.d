module uim.sap.cis.models.group;

import uim.sap.cis;

mixin(ShowModule!());

@safe:

struct CISGroup {
    string tenantId;
    string groupId;
    string displayName;
    Json members;
    SysTime updatedAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["id"] = groupId;
        payload["tenant_id"] = tenantId;
        payload["displayName"] = displayName;
        payload["members"] = members;
        payload["updated_at"] = updatedAt.toISOExtString();
        return payload;
    }
}
