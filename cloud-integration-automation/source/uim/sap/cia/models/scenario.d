module uim.sap.cia.models.scenario;

import uim.sap.cia;

mixin(ShowModule!());

@safe:
// ---------------------------------------------------------------------------
// Scenario – an integration scenario template (e.g. S/4HANA → SuccessFactors)
// ---------------------------------------------------------------------------
class CIAScenario : SAPEntity {
  mixin(SAPEntityTemplate!CIAScenario);

  UUID id;
  string name;
  string description;
  /// Tags such as "cloud-to-cloud", "on-prem-to-cloud"
  string[] tags;
  /// System types required by this scenario
  string[] requiredSystemTypes;
  /// Ordered task templates generated when a workflow is planned
  CIAScenarioTaskTemplate[] taskTemplates;

  override Json toJson() {
    Json sysTypes = requiredSystemTypes.map!(st => st).array.toJson();
    Json tmpl = Json.emptyArray;
    foreach (tt; taskTemplates)
      tmpl ~= tt.toJson();
    Json t = Json.emptyArray;
    foreach (tag; tags)
      t ~= tag;

    return super.toJson
      .set("id", id)
      .set("name", name)
      .set("description", description)
      .set("tags", t)
      .set("required_system_types", sysTypes)
      .set("task_templates", tmpl);
  }
}
