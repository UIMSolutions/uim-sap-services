module uim.sap.cia.models.user;

import uim.sap.cia;

mixin(ShowModule!());

@safe:
// ---------------------------------------------------------------------------
// User – a person who can be assigned tasks
// ---------------------------------------------------------------------------
class CIAUser : SAPTenantObject {
  mixin(SAPObjectTemplate!CIAUser);

  UUID id;
  string name;
  string email;
  UUID roleId;

  override Json toJson() {
    return super.toJson()
      .set("tenant_id", tenantId)
      .set("id", id)
      .set("name", name)
      .set("email", email)
      .set("role_id", roleId);
  }
}
