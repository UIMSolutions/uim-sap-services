module uim.sap.bas.models.template_;

import uim.sap.bas;

mixin(ShowModule!());

@safe:

class BASTemplate : SAPEntity {
  mixin(SAPEntityTemplate!BASTemplate);

  UUID templateId;
  UUID scenarioId;
  string name;
  string language;
  bool graphicalEditor;

  override Json toJson()  {
    return super.toJson
      .set("template_id", templateId)
      .set("scenario_id", scenarioId)
      .set("name", name)
      .set("language", language)
      .set("graphical_editor", graphicalEditor);
  }
}
