module uim.sap.atp.models.command;

import uim.sap.atp;

mixin(ShowModule!());

@safe:

/**
  * Represents a command in the ATP system, which defines a set of steps to be executed as part of an automation scenario.
  *
  * Fields:
  * - commandId: Unique identifier for the command
  * - catalogId: Identifier of the catalog this command belongs to
  * - name: Name of the command
  * - description: Description of what the command does
  * - commandType: Type/category of the command (e.g., "shell", "python", "http")
  * - steps: An array of steps that define the execution flow of the command. Each step could be a script, an API call, etc.
  * - allowPrivateEnvironment: Indicates whether this command can be executed in a private environment
  * - defaults: A JSON object containing default values for parameters used in the command
  *
  * Methods:
  * - toJson(): Serializes the command object to JSON format for storage or transmission.
  */
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
