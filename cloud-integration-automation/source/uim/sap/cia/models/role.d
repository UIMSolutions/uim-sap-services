module uim.sap.cia.models.role;
import uim.sap.cia;

mixin(ShowModule!());

@safe:
// ---------------------------------------------------------------------------
// Role – a named permission group that tasks can be assigned to
// ---------------------------------------------------------------------------
class CIARole : SAPObject {
mixin(SAPObjectTemplate!CIARole);

  UUID id;
  string name; // e.g. "Basis Administrator", "Cloud Admin"
  string description;

  override Json toJson()  {
    return super.toJson()
    .set("id", id)
    .set("name", name)
    .set("description", description);
  }
}
