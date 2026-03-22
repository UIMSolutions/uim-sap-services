module uim.sap.cag.models.transportqueue;

struct CAGTransportQueue {
  UUID tenantId;
  string queueId;
  string name;
  string queueType;
  string endpoint;
  bool active;
  SysTime createdAt;
  SysTime updatedAt;

  override Json toJson() {
    return Json.emptyObject
      .set("tenant_id", tenantId)
      .set("queue_id", queueId)
      .set("name", name)
      .set("queue_type", queueType)
      .set("endpoint", endpoint)
      .set("active", active)
      .set("created_at", createdAt.toISOExtString())
      .set("updated_at", updatedAt.toISOExtString());
  }
}