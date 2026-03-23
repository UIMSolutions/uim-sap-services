module uim.sap.cag.models.transportqueue;

class CAGTransportQueue : SAPTenantObject {
  mixin(SAPObjectTemplate!CAGTransportQueue);

  UUID queueId;
  string name;
  string queueType;
  string endpoint;
  bool active;

  override Json toJson() {
    return super.toJson
      .set("queue_id", queueId)
      .set("name", name)
      .set("queue_type", queueType)
      .set("endpoint", endpoint)
      .set("active", active);
  }
}