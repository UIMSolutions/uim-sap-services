module uim.sap.atm.models.technicalrole;

class ATMTechnicalRole : SAPTenantEntity {
  mixin(SAPTenantEntityTemplate!ATMTechnicalRole);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    name = request.getString("name", roleId.toString);
    if ("description" in request && request["description"].isString) {
      role.description = request["description"].getString;
    }
    if ("permissions" in request && request["permissions"].isArray) {
      role.permissions = stringArrayFromJson(request["permissions"]);
    }
    updatedAt = "updatedAt" in request ? SysTime.fromISOExtString(request["updatedAt"].get!string) : Clock.currTime();

    return true;
  }

  UUID roleId;
  string name;
  string description;
  string[] permissions;
  SysTime updatedAt;

  override Json toJson() {
    Json perms = permissions.map!(permission => permission).array.toJson;

    return super.toJson()
      .set("role_id", roleId)
      .set("name", name)
      .set("description", description)
      .set("permissions", perms);
  }

  static ATMTechnicalRole opCall(UUID tenantId, string roleId, Json request) {
    ATMTechnicalRole role = new ATMTechnicalRole(request);
    role.tenantId = tenantId;
    role.roleId = roleId.length > 0 ? roleId : randomUUID().toString();

    return role;
  }
}
///
unittest {
  ATMTechnicalRole role = ATMTechnicalRole("tenant-123", "role-456", Json.emptyObject);
  assert(role.tenantId == UUID("tenant-123"));
  assert(role.roleId == "role-456");
  assert(role.name == "role-456");
  assert(role.description == "");
  assert(role.permissions.length == 0);

  Json json = role.toJson();
  assert(json["tenant_id"].get!string == "tenant-123");
  assert(json["role_id"].get!string == "role-456");
  assert(json["name"].get!string == "role-456");
  assert(json["description"].get!string == "");
  assert(json["permissions"].isArray);
}
