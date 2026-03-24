module uim.sap.servicemanager.models.servicebinding;

struct SVMServiceBinding {
  UUID tenantId;
  string bindingId;
  UUID instanceId;
  string name;
  string environmentId;
  string credentialsRef;
  SysTime createdAt;

  override Json toJson()  {
    return super.toJson
      .set("tenant_id", tenantId)
      .set("binding_id", bindingId)
      .set("instance_id", instanceId)
      .set("name", name)
      .set("environment_id", environmentId)
      .set("credentials_ref", credentialsRef)
      .set("created_at", createdAt.toISOExtString());
  }
}
