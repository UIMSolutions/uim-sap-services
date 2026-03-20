module uim.sap.ctm.models.importqueue;

// ---------------------------------------------------------------------------
// CTMImportQueueEntry – an entry in a node's import queue
// ---------------------------------------------------------------------------
class CTMImportQueueEntry : SAPTenantObject {
    mixin(SAPObjectTemplate!CTMImportQueueEntry);

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
        return super.toJson
        .set("node_id", nodeId)
        .set("request_id", requestId)
        .set("position", position)
        .set("status", status)
        .set("queued_at", queuedAt.toISOExtString())
        .set("imported_at", importedAt.toISOExtString());
    }
}
