module uim.sap.atm.models.technicalrole;

struct ATMTechnicalRole {
  string tenantId;
  string roleId;
  string name;
  string description;
  string[] permissions;
  SysTime updatedAt;

  override Json toJson()  {
    Json info = super.toJson;
    Json perms = Json.emptyArray;
    foreach (permission; permissions) {
      perms ~= permission;
    }

    payload["tenant_id"] = tenantId;
    payload["role_id"] = roleId;
    payload["name"] = name;
    payload["description"] = description;
    payload["permissions"] = perms;
    payload["updated_at"] = updatedAt.toISOExtString();
    return payload;
  }
}

ATMTechnicalRole technicalRoleFromJson(string tenantId, string roleId, Json request) {
  ATMTechnicalRole role;
  role.tenantId = tenantId;
  role.roleId = roleId.length > 0 ? roleId : randomUUID().toString();
  role.name = role.roleId;
  role.updatedAt = Clock.currTime();

  if ("name" in request && request["name"].isString) {
    role.name = request["name"].get!string;
  }
  if ("description" in request && request["description"].isString) {
    role.description = request["description"].get!string;
  }
  if ("permissions" in request && request["permissions"].isArray) {
    role.permissions = stringArrayFromJson(request["permissions"]);
  }

  return role;
}
