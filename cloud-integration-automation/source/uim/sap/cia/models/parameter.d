module uim.sap.cia.models.parameter;

// ---------------------------------------------------------------------------
// Parameter – a key/value pair scoped to a workflow (reused across tasks)
// ---------------------------------------------------------------------------
struct CIAParameter {
  string workflowId;
  string key;
  string value;
  string description;
  bool sensitive; // mask in logs/UI if true

  override Json toJson()  {
    Json j = Json.emptyObject;
    j["workflow_id"] = workflowId;
    j["key"] = key;
    j["value"] = sensitive ? "***" : value;
    j["description"] = description;
    j["sensitive"] = sensitive;
    return j;
  }
}