module uim.sap.atp.models.eventtrigger;

import uim.sap.atp;

mixin(ShowModule!());

@safe:

/**
  * Represents an event trigger in the ATP system. An event trigger defines a specific event that can activate an ATP command.
  *
  * This class is used to store and manage event triggers, which link specific events (like changes in inventory or new orders) to ATP commands that should be executed when those events occur.
  *
  * Fields:
  * - triggerId: Unique identifier for the event trigger.
  * - eventSource: The source of the event (e.g., "inventory", "orders").
  * - eventType: The type of the event (e.g., "update", "create").
  * - commandId: The ID of the ATP command to execute when the event occurs.
  * - active: A boolean indicating whether the trigger is active.
  *
  * Methods:
  * - toJson(): Serializes the event trigger object to JSON format for storage or transmission.
  */
class ATPEventTrigger : SAPTenantObject {
  mixin(SAPTenantObjectTemplate!ATPEventTrigger);

  UUID triggerId;
  string eventSource;
  string eventType;
  UUID commandId;
  bool active;

  override Json toJson() {
    return super.toJson
      .set("trigger_id", triggerId)
      .set("event_source", eventSource)
      .set("event_type", eventType)
      .set("command_id", commandId)
      .set("active", active);
  }
}
