module uim.sap.cps.models.launchpadmodule;

struct CPSLaunchpadModule {
  UUID tenantId;
  UUID moduleId;
  string solutionName;
  bool personalization;
  bool translation;
  bool customThemes;
  SysTime updatedAt;

  override Json toJson()  {
    Json info = super.toJson;
    payload["tenant_id"] = tenantId;
    payload["module_id"] = moduleId;
    payload["solution_name"] = solutionName;
    payload["personalization"] = personalization;
    payload["translation"] = translation;
    payload["custom_themes"] = customThemes;
    payload["updated_at"] = updatedAt.toISOExtString();
    return payload;
  }
}