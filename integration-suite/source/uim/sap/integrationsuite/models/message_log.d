/**
 * Message Log model — Cloud Integration monitoring
 *
 * Represents a message processing log entry for integration flows.
 */
module uim.sap.integrationsuite.models.message_log;

import uim.sap.integrationsuite;

mixin(ShowModule!());

@safe:

struct ISMessageLog {
    string tenantId;
    string logId;
    string iflowId;
    string correlationId;
    string status = "processing";  // processing | completed | failed | retry
    string sender;
    string receiver;
    long payloadSizeBytes = 0;
    string errorMessage;
    long durationMs = 0;
    string startedAt;
    string completedAt;
    string createdAt;

    Json toJson() const {
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

ISMessageLog messageLogFromJson(string tenantId, Json request) {
    ISMessageLog l;
    l.tenantId = tenantId;
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

    l.createdAt = Clock.currTime().toISOExtString();
    l.startedAt = l.createdAt;
    return l;
}
