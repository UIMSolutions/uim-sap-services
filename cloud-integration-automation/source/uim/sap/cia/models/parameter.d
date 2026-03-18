module uim.sap.cia.models.parameter;
import uim.sap.cia;

mixin(ShowModule!());

@safe:
// ---------------------------------------------------------------------------
// Parameter – a key/value pair scoped to a workflow (reused across tasks)
// ---------------------------------------------------------------------------
class CIAParameter : SAPObject {
mixin(SAPObjectTemplate!CIAParameter);

  string workflowId;
  string key;
  string value;
  string description;
  bool sensitive; // mask in logs/UI if true

  override Json toJson()  {
    return super.toJson()
    .set("workflow_id", workflowId)
    .set("key", key)
    .set("value", sensitive ? "***" : value)
    .set("description", description)
    .set("sensitive", sensitive);
  }
}