module uim.sap.cia.models.scenariotask;

// ---------------------------------------------------------------------------
// ScenarioTaskTemplate – a task template embedded in a scenario definition
// ---------------------------------------------------------------------------
struct CIAScenarioTaskTemplate {
  int order;
  string name;
  string description;
  /// Step-by-step instructions shown to the assignee
  string instructions;
  /// Role that should execute this step
  string defaultRoleId;
  /// Whether this step can be automated
  bool automated;
  /// Tags such as "pre-requisite", "config", "validation", "post-config"
  string[] tags;

  Json toJson() const {
    Json j = Json.emptyObject;
    j["order"] = order;
    j["name"] = name;
    j["description"] = description;
    j["instructions"] = instructions;
    j["default_role_id"] = defaultRoleId;
    j["automated"] = automated;
    Json t = Json.emptyArray;
    foreach (tag; tags)
      t ~= tag;
    j["tags"] = t;
    return j;
  }
}