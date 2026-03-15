module uim.sap.bas.models.template_;

import uim.sap.bas;

mixin(ShowModule!());

@safe:


struct BASTemplate {
  string templateId;
  string scenarioId;
  string name;
  string language;
  bool graphicalEditor;

  override Json toJson()  {
    Json info = super.toJson;
    payload["template_id"] = templateId;
    payload["scenario_id"] = scenarioId;
    payload["name"] = name;
    payload["language"] = language;
    payload["graphical_editor"] = graphicalEditor;
    return payload;
  }
}
