module uim.sap.cps.models.contentitem;

struct CPSContentItem {
  string tenantId;
  string itemType;
  string itemId;
  string name;
  Json configuration;
  SysTime updatedAt;

  Json toJson() const {
    Json payload = Json.emptyObject;
    payload["tenant_id"] = tenantId;
    payload["item_type"] = itemType;
    payload["item_id"] = itemId;
    payload["name"] = name;
    payload["configuration"] = configuration;
    payload["updated_at"] = updatedAt.toISOExtString();
    return payload;
  }
}