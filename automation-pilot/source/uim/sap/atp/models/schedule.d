module uim.sap.atp.models.schedule;

import uim.sap.atp;

mixin(ShowModule!());

@safe:

/**
  * Represents a schedule for executing ATP commands or event triggers.
  *
  * This class is used to define schedules that can automatically execute ATP commands or event triggers based on a specified timing expression (e.g., cron expression). It allows for automating the execution of ATP tasks at regular intervals or specific times.
  * Fields:
  * - scheduleId: Unique identifier for the schedule.
  * - targetType: The type of target this schedule is for (e.g., "command", "event_trigger").
  * - targetId: The ID of the command or event trigger that this schedule will execute.
  * - mode: The scheduling mode (e.g., "cron", "interval").
  * - expression: The scheduling expression (e.g., cron expression or interval duration).
  * - active: A boolean indicating whether the schedule is active.
  * Methods:
  * - toJson(): Serializes the schedule object to JSON format for storage or transmission 
  */
class ATPSchedule : SAPTenantObject {
  mixin(SAPTenantObjectTemplate!ATPSchedule);

  UUID scheduleId;
  string targetType;
  UUID targetId;
  string mode;
  string expression;
  bool active;

  override Json toJson() {
    return super.toJson
      .set("schedule_id", scheduleId)
      .set("target_type", targetType)
      .set("target_id", targetId)
      .set("mode", mode)
      .set("expression", expression)
      .set("active", active);
  }
}
