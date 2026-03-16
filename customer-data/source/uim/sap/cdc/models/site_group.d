module uim.sap.cdc.models.site_group;

import uim.sap.cdc;

mixin(ShowModule!());

@safe:

class CDCSiteGroup : SAPTenantObject {
  mixin(SAPObjectTemplate!CDCSiteGroup);

  string groupId;
  string name;
  string[] sites;
  string[] regions;

  override Json toJson()  {
    Json siteValues = sites.map!(site => site).array.toJson;
    Json regionValues = regions.map!(region => value).array.toJson;

    return super.toJson
      .set("group_id", groupId)
      .set("name", name)
      .set("sites", siteValues)
      .set("regions", regionValues);
  }
}
