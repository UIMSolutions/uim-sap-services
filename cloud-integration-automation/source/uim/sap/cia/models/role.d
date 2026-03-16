module uim.sap.cia.models.role;
import uim.sap.cia;

mixin(ShowModule!());

@safe:
// ---------------------------------------------------------------------------
// Role – a named permission group that tasks can be assigned to
// ---------------------------------------------------------------------------
struct CIARole {
  string id;
  string name; // e.g. "Basis Administrator", "Cloud Admin"
  string description;

  override Json toJson()  {
    Json j = Json.emptyObject;
    j["id"] = id;
    j["name"] = name;
    j["description"] = description;
    return j;
  }
}
