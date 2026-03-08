module uim.sap.bas.models.template_;

struct BASTemplate {
  string templateId;
  string scenarioId;
  string name;
  string language;
  bool graphicalEditor;

  Json toJson() const {
    Json payload = Json.emptyObject;
    payload["template_id"] = templateId;
    payload["scenario_id"] = scenarioId;
    payload["name"] = name;
    payload["language"] = language;
    payload["graphical_editor"] = graphicalEditor;
    return payload;
  }
}
