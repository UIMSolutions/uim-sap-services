module uim.sap.cis.models.user;

struct CISUser {
    string tenantId;
    string userId;
    string userName;
    string email;
    string userType = "employee";
    bool active = true;
    Json groups;
    Json attributes;
    SysTime createdAt;
    SysTime updatedAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["id"] = userId;
        payload["tenant_id"] = tenantId;
        payload["userName"] = userName;
        payload["email"] = email;
        payload["user_type"] = userType;
        payload["active"] = active;
        payload["groups"] = groups;
        payload["attributes"] = attributes;
        payload["created_at"] = createdAt.toISOExtString();
        payload["updated_at"] = updatedAt.toISOExtString();
        return payload;
    }
}
