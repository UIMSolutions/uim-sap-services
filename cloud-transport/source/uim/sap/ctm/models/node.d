module uim.sap.ctm.models.node;

// ---------------------------------------------------------------------------
// CTMNode – a logical environment in the transport landscape
// ---------------------------------------------------------------------------
class CTMNode : SAPTenantObject {
  mixin(SAPObjectTemplate!CTMNode);

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
  bool autoImport;
  /// Cron expression for scheduled imports (empty = disabled)
  string importSchedule;
  bool active;

  override Json toJson() {
    return super.toJson
      .set("node_id", nodeId)
      .set("name", name)
      .set("description", description)
      .set("runtime", runtime)
      .set("global_account_id", globalAccountId)
      .set("subaccount_id", subaccountId)
      .set("destination", destination)
      .set("auto_import", autoImport)
      .set("import_schedule", importSchedule)
      .set("active", active);
  }
}
