module uim.sap.ctm.models.importqueue;

// ---------------------------------------------------------------------------
// CTMImportQueueEntry – an entry in a node's import queue
// ---------------------------------------------------------------------------
struct CTMImportQueueEntry {
    UUID tenantId;
    UUID nodeId;
    UUID requestId;
    /// Position in the queue (lower = earlier)
    int    position;
    /// Status: "waiting" | "importing" | "imported" | "error"
    string status;
    SysTime queuedAt;
    SysTime importedAt;

    override Json toJson()  {
        Json j = Json.emptyObject;
        j["tenant_id"]   = tenantId;
        j["node_id"]     = nodeId;
        j["request_id"]  = requestId;
        j["position"]    = position;
        j["status"]      = status;
        j["queued_at"]   = queuedAt.toISOExtString();
        j["imported_at"] = importedAt.toISOExtString();
        return j;
    }
}
