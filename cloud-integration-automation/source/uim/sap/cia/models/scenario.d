module uim.sap.cia.models.scenario;

// ---------------------------------------------------------------------------
// Scenario – an integration scenario template (e.g. S/4HANA → SuccessFactors)
// ---------------------------------------------------------------------------
struct CIAScenario {
  string id;
  string name;
  string description;
  /// Tags such as "cloud-to-cloud", "on-prem-to-cloud"
  string[] tags;
  /// System types required by this scenario
  string[] requiredSystemTypes;
  /// Ordered task templates generated when a workflow is planned
  CIAScenarioTaskTemplate[] taskTemplates;
  SysTime createdAt;
  SysTime updatedAt;

  Json toJson() const {
    Json j = Json.emptyObject;
    j["id"] = id;
    j["name"] = name;
    j["description"] = description;

    Json t = Json.emptyArray;
    foreach (tag; tags)
      t ~= tag;
    j["tags"] = t;

    Json r = Json.emptyArray;
    foreach (st; requiredSystemTypes)
      r ~= st;
    j["required_system_types"] = r;

    Json tmpl = Json.emptyArray;
    foreach (tt; taskTemplates)
      tmpl ~= tt.toJson();
    j["task_templates"] = tmpl;

    j["created_at"] = createdAt.toISOExtString();
    j["updated_at"] = updatedAt.toISOExtString();
    return j;
  }
}
