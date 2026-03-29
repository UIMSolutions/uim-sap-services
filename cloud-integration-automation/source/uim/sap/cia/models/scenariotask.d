module uim.sap.cia.models.scenariotask;
import uim.sap.cia;

mixin(ShowModule!());

@safe:

// ---------------------------------------------------------------------------
// ScenarioTaskTemplate – a task template embedded in a scenario definition
// ---------------------------------------------------------------------------
class CIAScenarioTaskTemplate : SAPEntity {
  mixin(SAPEntityTemplate!CIAScenarioTaskTemplate);

  int order;
  string name;
  string description;
  /// Step-by-step instructions shown to the assignee
  string instructions;
  /// Role that should execute this step
  UUID defaultRoleId;
  /// Whether this step can be automated
  bool automated;
  /// Tags such as "pre-requisite", "config", "validation", "post-config"
  string[] tags;

  override Json toJson() {
    Json jTags = tags.map!(t => t.toJson).array.toJson();

    return super.toJson
      .set("order", order)
      .set("name", name)
      .set("description", description)
      .set("instructions", instructions)
      .set("default_role_id", defaultRoleId.toString())
      .set("automated", automated)
      .set("tags", jTags);
  }
}