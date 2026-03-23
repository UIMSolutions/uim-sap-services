module uim.sap.cps.models.provider;
import uim.sap.cps;

mixin(ShowModule!());

@safe:
class CPSContentProvider : SAPTenantObject {
  mixin(SAPObjectTemplate!CPSContentProvider);

  UUID providerId;
  string solutionName;
  bool saasEnabled;
  Json catalogs;
  SysTime updatedAt;

  override Json toJson()  {
    return super.toJson
      .set("provider_id", providerId)
      .set("solution_name", solutionName)
      .set("saas_enabled", saasEnabled)
      .set("catalogs", catalogs);
  }
}