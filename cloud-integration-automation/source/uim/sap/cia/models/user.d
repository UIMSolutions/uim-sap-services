module uim.sap.cia.models.user;
import uim.sap.cia;

mixin(ShowModule!());

@safe:
// ---------------------------------------------------------------------------
// User – a person who can be assigned tasks
// ---------------------------------------------------------------------------
struct CIAUser {
  UUID tenantId;
  UUID id;
  string name;
  string email;
  UUID roleId;

  override Json toJson()  {
    Json j = Json.emptyObject;
    j["tenant_id"] = tenantId;
    j["id"] = id;
    j["name"] = name;
    j["email"] = email;
    j["role_id"] = roleId;
    return j;
  }
}
