/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.datasphere.models.auditevent;

import uim.sap.datasphere;

mixin(ShowModule!());

@safe:

/** 
 * Represents an audit event in the system, capturing key information about operations performed by users or system processes.
 * This struct is designed to be immutable and thread-safe, ensuring that audit records are consistent and reliable for tracking and analysis purposes. 
  * The `toJson` method allows for easy serialization of audit events into a JSON format, facilitating storage and integration with logging systems or external monitoring tools.
  * 
  * Fields:
  * - tenantId: The ID of the tenant associated with this audit event.
  * - eventId: A unique identifier for the audit event.
  * - operation: A string describing the operation performed (e.g., "CREATE", "UPDATE", "DELETE").
  * - layer: The layer of the application where the event occurred (e.g., "UI", "Service", "Data").
  * - actor: The user or system process that performed the operation.
  * - details: Additional details about the event, such as parameters or context information.
  * - createdAt: The timestamp when the audit event was created.
 */
class DATAuditEvent : SAPTenantEntity {
  mixin(SAPTenantEntityTemplate!DATAuditEvent);

  UUID eventId;
  string operation;
  string layer;
  string actor;
  string details;
  
  override Json toJson() {
    return super.toJson
    .set("event_id", eventId)
    .set("operation", operation)
    .set("layer", layer)
    .set("actor", actor)
    .set("details", details);
  }
}
