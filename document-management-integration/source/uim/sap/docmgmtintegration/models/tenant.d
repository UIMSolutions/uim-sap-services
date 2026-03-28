module uim.sap.docmgmtintegration.models.tenant;

// ---------------------------------------------------------------------------
// Tenant
// ---------------------------------------------------------------------------

/// Represents a tenant in the multi-tenant system.
class Tenant : SAPTenantObject {
  mixin(SAPObjectTemplate!Tenant);

  UUID tenantId;
  string name;
  string description;
  bool active = true;
  SysTime createdAt;
  SysTime modifiedAt;

  override Json toJson() {
    return super.toJson()
      .set("tenant_id", tenantId)
      .set("name", name)
      .set("description", description)
      .set("active", active)
      .set("created_at", createdAt.toISOExtString())
      .set("modified_at", modifiedAt.toISOExtString());
  }

  static Tenant tenantFromJson(Json request) {
    Tenant t = new Tenant(request);
    t.tenantId = randomUUID();
    t.createdAt = Clock.currTime();
    t.modifiedAt = t.createdAt;
    t.active = true;

    if ("name" in request && request["name"].isString)
      t.name = request["name"].getString;
    if ("description" in request && request["description"].isString)
      t.description = request["description"].getString;

    return t;
  }
}
