module uim.sap.atm.models.sessioncontext;

struct ATMSessionContext {
  string tenantId;
  string userId;
  string idpId;
  string issuer;
  string audience;
  string email;
  string[] groups;
  string[] scopes;
  string[] roleCollections;
  string[] technicalRoles;
  string[] permissions;
  bool bootstrap;
  SysTime authenticatedAt;

  Json toJson() const {
    Json payload = Json.emptyObject;
    payload["tenant_id"] = tenantId;
    payload["user_id"] = userId;
    payload["idp_id"] = idpId;
    payload["issuer"] = issuer;
    payload["audience"] = audience;
    payload["email"] = email;
    payload["bootstrap"] = bootstrap;
    payload["authenticated_at"] = authenticatedAt.toISOExtString();
    payload["groups"] = groups.toJson;
    payload["scopes"] = scopes.toJson;
    payload["role_collections"] = roleCollections.toJson;
    payload["technical_roles"] = technicalRoles.toJson;
    payload["permissions"] = permissions.toJson;
    return payload;
  }
}