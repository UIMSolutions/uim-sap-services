module uim.sap.ctm.models.node;

// ---------------------------------------------------------------------------
// CTMNode – a logical environment in the transport landscape
// ---------------------------------------------------------------------------
struct CTMNode {
    UUID tenantId;
    UUID nodeId;
    string name;
    string description;
    /// Runtime: "cloud-foundry" | "abap" | "neo"
    string runtime;
    /// Global account / subaccount identifiers
    UUID globalAccountId;
    UUID subaccountId;
    /// Destination name for deployment (optional)
    string destination;
    /// Whether requests to this node are imported automatically
    bool   autoImport;
    /// Cron expression for scheduled imports (empty = disabled)
    string importSchedule;
    bool   active;
    SysTime createdAt;
    SysTime updatedAt;

    override Json toJson()  {
        Json j = Json.emptyObject;
        j["tenant_id"]         = tenantId;
        j["node_id"]           = nodeId;
        j["name"]              = name;
        j["description"]       = description;
        j["runtime"]           = runtime;
        j["global_account_id"] = globalAccountId;
        j["subaccount_id"]     = subaccountId;
        j["destination"]       = destination;
        j["auto_import"]       = autoImport;
        j["import_schedule"]   = importSchedule;
        j["active"]            = active;
        j["created_at"]        = createdAt.toISOExtString();
        j["updated_at"]        = updatedAt.toISOExtString();
        return j;
    }
}
