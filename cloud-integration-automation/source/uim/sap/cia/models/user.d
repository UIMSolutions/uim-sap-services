module uim.sap.cia.models.user;

// ---------------------------------------------------------------------------
// User – a person who can be assigned tasks
// ---------------------------------------------------------------------------
struct CIAUser {
  string tenantId;
  string id;
  string name;
  string email;
  string roleId;

  Json toJson() const {
    Json j = Json.emptyObject;
    j["tenant_id"] = tenantId;
    j["id"] = id;
    j["name"] = name;
    j["email"] = email;
    j["role_id"] = roleId;
    return j;
  }
}
