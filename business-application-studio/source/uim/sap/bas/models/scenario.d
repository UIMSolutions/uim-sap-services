module uim.sap.bas.models.scenario;

import uim.sap.bas;

mixin(ShowModule!());

@safe:

class BASScenario : SAPEntity {
  mixin(SAPEntityTemplate!BASScenario);

  UUID scenarioId;
  string name;
  string description;
  string[] supportedSolutions;

  override Json toJson() {
    Json solutions = Json.emptyArray;
    foreach (solution; supportedSolutions)
      solutions ~= solution;

    return super.toJson()
      .set("scenario_id", scenarioId)
      .set("name", name)
      .set("description", description)
      .set("supported_solutions", solutions);
  }
}
