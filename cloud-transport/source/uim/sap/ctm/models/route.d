module uim.sap.ctm.models.route;

// ---------------------------------------------------------------------------
// CTMRoute – a directional connection between two nodes
// ---------------------------------------------------------------------------
struct CTMRoute {
    string tenantId;
    string routeId;
    string sourceNodeId;
    string targetNodeId;
    string description;
    bool   active;
    SysTime createdAt;

    override Json toJson()  {
        Json j = Json.emptyObject;
        j["tenant_id"]      = tenantId;
        j["route_id"]       = routeId;
        j["source_node_id"] = sourceNodeId;
        j["target_node_id"] = targetNodeId;
        j["description"]    = description;
        j["active"]         = active;
        j["created_at"]     = createdAt.toISOExtString();
        return j;
    }
}
