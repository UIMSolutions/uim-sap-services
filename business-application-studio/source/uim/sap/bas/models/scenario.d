module uim.sap.bas.models.scenario;

import uim.sap.bas;

mixin(ShowModule!());

@safe:


struct BASScenario {
  string scenarioId;
  string name;
  string description;
  string[] supportedSolutions;

  Json toJson() const {
    Json payload = Json.emptyObject;
    payload["scenario_id"] = scenarioId;
    payload["name"] = name;
    payload["description"] = description;

    Json solutions = Json.emptyArray;
    foreach (solution; supportedSolutions)
      solutions ~= solution;
    payload["supported_solutions"] = solutions;
    return payload;
  }
}
