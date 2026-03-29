module uim.sap.ctm.models.transportrequest;

// ---------------------------------------------------------------------------
// CTMTransportRequest – a transport request moving through the landscape
// ---------------------------------------------------------------------------
class CTMTransportRequest : SAPTenantEntity {
      mixin(SAPEntityTemplate!CTMTransportRequest);

    UUID requestId;
    string description;
    /// Owning (source) node
    UUID sourceNodeId;
    /// Current location node (changes when forwarded)
    UUID currentNodeId;
    /// Status: "initial" | "queued" | "importing" | "imported" | "error" | "reset"
    string status;
    /// User / pipeline that created the request
    string createdBy;

    override Json toJson()  {
        return super.toJson
        .set("request_id", requestId)
        .set("description", description)
        .set("source_node_id", sourceNodeId)
        .set("current_node_id", currentNodeId)
        .set("status", status)
        .set("created_by", createdBy);
    }
}