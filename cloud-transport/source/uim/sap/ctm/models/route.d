module uim.sap.ctm.models.route;

// ---------------------------------------------------------------------------
// CTMRoute – a directional connection between two nodes
// ---------------------------------------------------------------------------
class CTMRoute : SAPTenantObject {
    mixin(SAPObjectTemplate!CTMRoute);

    UUID routeId;
    UUID sourceNodeId;
    UUID targetNodeId;
    string description;
    bool   active;

    override Json toJson()  {
        return super.toJson
        .set("route_id", routeId)
        .set("source_node_id", sourceNodeId)
        .set("target_node_id", targetNodeId)
        .set("description", description)
        .set("active", active);
    }
}
