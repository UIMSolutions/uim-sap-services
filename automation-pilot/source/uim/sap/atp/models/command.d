module uim.sap.atp.models.command;

import uim.sap.atp;

mixin(ShowModule!());

@safe:

class ATPCommand : SAPTenantObject {
  mixin(SAPObjectTemplate!ATPCommand);

  UUID commandId;
  UUID catalogId;
  string name;
  string description;
  string commandType;
  string[] steps;
  bool allowPrivateEnvironment;
  Json defaults;
  
  override Json toJson()  {
    Json stepValues = steps.map!(step => step).array.toJson;

    return super.toJson
      .set("command_id", commandId)
      .set("catalog_id", catalogId)
      .set("name", name)
      .set("description", description)
      .set("command_type", commandType)
      .set("steps", stepValues)
      .set("allow_private_environment", allowPrivateEnvironment)
      .set("defaults", defaults);
  }
}
