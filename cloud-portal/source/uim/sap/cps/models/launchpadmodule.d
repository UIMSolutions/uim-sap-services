module uim.sap.cps.models.launchpadmodule;
import uim.sap.cps;

mixin(ShowModule!());

@safe:
class CPSLaunchpadModule : SAPTenantEntity {
  mixin(SAPTenantEntityTemplate!CPSLaunchpadModule);

  UUID moduleId;
  string solutionName;
  bool personalization;
  bool translation;
  bool customThemes;
  SysTime updatedAt;

  override Json toJson() {
    return super.toJson
      .set("module_id", moduleId)
      .set("solution_name", solutionName)
      .set("personalization", personalization)
      .set("translation", translation)
      .set("custom_themes", customThemes);
  }
}
