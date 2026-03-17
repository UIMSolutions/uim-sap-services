module uim.sap.atp.models.excecution;

import uim.sap.atp;

mixin(ShowModule!());

@safe:

/**
  * Represents the execution of an ATP command. Contains details about the execution such as input, result, status, and timestamps.
  *
  * This class is used to track the execution of ATP commands, allowing for monitoring and debugging of command runs.
  *
  * Fields:
  * - executionId: Unique identifier for the execution instance.
  * - commandId: Identifier of the command being executed.
  * - triggerType: The type of trigger that initiated the execution (e.g., "manual", "scheduled").
  * - status: Current status of the execution (e.g., "pending", "running", "completed", "failed").
  * - input: The input parameters provided for the command execution, stored as JSON.
  * - result: The output or result of the command execution, stored as JSON.
  * - startedAt: Timestamp when the execution started.
  * - finishedAt: Timestamp when the execution finished.
  *
  * Methods:
  * - toJson(): Serializes the execution object to JSON format for storage or transmission.
  */
class ATPExecution : SAPTenantObject {
  mixin(SAPObjectTemplate!ATPExecution);

  UUID executionId;
  UUID commandId;
  string triggerType;
  string status;
  Json input;
  Json result;
  SysTime startedAt;
  SysTime finishedAt;

  override Json toJson() {
    return super.toJson()
      .set("execution_id", executionId)
      .set("command_id", commandId)
      .set("trigger_type", triggerType)
      .set("status", status)
      .set("input", input)
      .set("result", result)
      .set("started_at", startedAt.toISOExtString())
      .set("finished_at", finishedAt.toISOExtString());
  }
}
