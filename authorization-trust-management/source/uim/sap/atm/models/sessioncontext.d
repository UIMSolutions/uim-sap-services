module uim.sap.atm.models.sessioncontext;

class ATMSessionContext : SAPTenantObject {
  mixin(SAPObjectTemplate!ATMSessionContext);

  UUID userId;
  UUID idpId;
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

  override Json toJson()  {
    Json info = super.toJson;
    
    payload["user_id"] = userId.toJson;
    payload["idp_id"] = idpId.toJson;
    payload["issuer"] = issuer.toJson;
    payload["audience"] = audience.toJson;
    payload["email"] = email.toJson;
    payload["bootstrap"] = bootstrap.toJson;
    payload["authenticated_at"] = authenticatedAt.toISOExtString().toJson;
    payload["groups"] = groups.toJson;
    payload["scopes"] = scopes.toJson;
    payload["role_collections"] = roleCollections.toJson;
    payload["technical_roles"] = technicalRoles.toJson;
    payload["permissions"] = permissions.toJson;

    return payload;
  }
}