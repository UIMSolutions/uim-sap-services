module uim.sap.cps.models.contentitem;
import uim.sap.cps;

mixin(ShowModule!());

@safe:
struct CPSContentItem {
  string tenantId;
  string itemType;
  string itemId;
  string name;
  Json configuration;
  SysTime updatedAt;

  override Json toJson()  {
    Json info = super.toJson;
    payload["tenant_id"] = tenantId;
    payload["item_type"] = itemType;
    payload["item_id"] = itemId;
    payload["name"] = name;
    payload["configuration"] = configuration;
    payload["updated_at"] = updatedAt.toISOExtString();
    return payload;
  }
}