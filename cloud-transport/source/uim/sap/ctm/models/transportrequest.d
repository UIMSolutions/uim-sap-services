module uim.sap.ctm.models.transportrequest;

// ---------------------------------------------------------------------------
// CTMTransportRequest – a transport request moving through the landscape
// ---------------------------------------------------------------------------
struct CTMTransportRequest {
    UUID tenantId;
    string requestId;
    string description;
    /// Owning (source) node
    string sourceNodeId;
    /// Current location node (changes when forwarded)
    string currentNodeId;
    /// Status: "initial" | "queued" | "importing" | "imported" | "error" | "reset"
    string status;
    /// User / pipeline that created the request
    string createdBy;
    SysTime createdAt;
    SysTime updatedAt;

    override Json toJson()  {
        Json j = Json.emptyObject;
        j["tenant_id"]       = tenantId;
        j["request_id"]      = requestId;
        j["description"]     = description;
        j["source_node_id"]  = sourceNodeId;
        j["current_node_id"] = currentNodeId;
        j["status"]          = status;
        j["created_by"]      = createdBy;
        j["created_at"]      = createdAt.toISOExtString();
        j["updated_at"]      = updatedAt.toISOExtString();
        return j;
    }
}