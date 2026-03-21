/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.integrationsuite.models.message_log;

import uim.sap.integrationsuite;

mixin(ShowModule!());

@safe:

/**
  * Represents a log entry for a message processed through the SAP Integration Suite.
  * This model captures key information about the message, including its processing status, sender and receiver details, payload size, and any errors encountered.
  *
  * Status values:
  * - processing: The message is currently being processed.
  * - completed: The message was processed successfully.
  * - failed: An error occurred during processing.
  * - retry: The message is scheduled for retry after a failure.
  *
  * This model can be used for monitoring and troubleshooting message processing within the SAP Integration Suite.
  * For more information on message logs and their management, refer to the SAP Integration Suite documentation.
  *
  * Fields:
  * - tenantId: The ID of the tenant that owns this message log entry.
  * - logId: A unique identifier for the message log entry.
  * - iflowId: The ID of the integration flow that processed the message.
  * - correlationId: A unique identifier that correlates related messages across different systems and processes
*/
struct INTMessageLog {
  UUID tenantId;
  UUID logId;
  string iflowId;
  string correlationId;
  string status = "processing"; // processing | completed | failed | retry
  string sender;
  string receiver;
  long payloadSizeBytes = 0;
  string errorMessage;
  long durationMs = 0;
  string startedAt;
  string completedAt;
  string createdAt;

  override Json toJson()  {
    Json j = Json.emptyObject;
    j["tenant_id"] = tenantId;
    j["log_id"] = logId;
    j["iflow_id"] = iflowId;
    j["correlation_id"] = correlationId;
    j["status"] = status;
    j["sender"] = sender;
    j["receiver"] = receiver;
    j["payload_size_bytes"] = payloadSizeBytes;
    j["error_message"] = errorMessage;
    j["duration_ms"] = durationMs;
    j["started_at"] = startedAt;
    j["completed_at"] = completedAt;
    j["created_at"] = createdAt;
    return j;
  }
}

INTMessageLog messageLogFromJson(UUID tenantId, Json request) {
  INTMessageLog l;
  l.tenantId = UUID(tenantId);
  l.logId = randomUUID().toString();

  if ("iflow_id" in request && request["iflow_id"].isString)
    l.iflowId = request["iflow_id"].get!string;
  if ("correlation_id" in request && request["correlation_id"].isString)
    l.correlationId = request["correlation_id"].get!string;
  if ("status" in request && request["status"].isString)
    l.status = request["status"].get!string;
  if ("sender" in request && request["sender"].isString)
    l.sender = request["sender"].get!string;
  if ("receiver" in request && request["receiver"].isString)
    l.receiver = request["receiver"].get!string;
  if ("payload_size_bytes" in request && request["payload_size_bytes"].type == Json.Type.int_)
    l.payloadSizeBytes = request["payload_size_bytes"].get!long;
  if ("error_message" in request && request["error_message"].isString)
    l.errorMessage = request["error_message"].get!string;
  if ("duration_ms" in request && request["duration_ms"].type == Json.Type.int_)
    l.durationMs = request["duration_ms"].get!long;

  l.createdAt = Clock.currTime().toINTOExtString();
  l.startedAt = l.createdAt;
  return l;
}
