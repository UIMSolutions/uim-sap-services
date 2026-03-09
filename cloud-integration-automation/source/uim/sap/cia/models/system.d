module uim.sap.cia.models.system;

// ---------------------------------------------------------------------------
// System – an entry in the system landscape (SAP Cloud, On-Premises, …)
// ---------------------------------------------------------------------------
struct CIASystem {
  string tenantId;
  string id;
  string name;
  /// System type: "sap-cloud", "s4hana-on-prem", "s4hana-cloud", "successfactors", "ariba", "other"
  string systemType;
  string host;
  string description;
  bool active;
  SysTime createdAt;
  SysTime updatedAt;

  Json toJson() const {
    Json j = Json.emptyObject;
    j["tenant_id"] = tenantId;
    j["id"] = id;
    j["name"] = name;
    j["system_type"] = systemType;
    j["host"] = host;
    j["description"] = description;
    j["active"] = active;
    j["created_at"] = createdAt.toISOExtString();
    j["updated_at"] = updatedAt.toISOExtString();
    return j;
  }
}