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

  override Json toJson() {
    return super.toJson
      .set("user_id", userId.toJson)
      .set("idp_id", idpId.toJson)
      .set("issuer", issuer.toJson)
      .set("audience", audience.toJson)
      .set("email", email.toJson)
      .set("bootstrap", bootstrap.toJson)
      .set("authenticated_at", authenticatedAt.toISOExtString().toJson)
      .set("groups", groups.toJson)
      .set("scopes", scopes.toJson)
      .set("role_collections", roleCollections.toJson)
      .set("technical_roles", technicalRoles.toJson)
      .set("permissions", permissions.toJson);
  }
}