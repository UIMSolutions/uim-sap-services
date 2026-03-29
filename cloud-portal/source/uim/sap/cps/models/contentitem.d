module uim.sap.cps.models.contentitem;
import uim.sap.cps;

mixin(ShowModule!());

@safe:
class CPSContentItem : SAPTenantEntity {
  mixin(SAPTenantEntityTemplate!CPSContentItem);

  string itemType;
  UUID itemId;
  string name;
  Json configuration;
  SysTime updatedAt;

  override Json toJson() {
    return super.toJson()
      .set("item_type", itemType)
      .set("item_id", itemId)
      .set("name", name)
      .set("configuration", configuration);
  }
}
