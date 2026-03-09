module uim.sap.cia.models.role;

// ---------------------------------------------------------------------------
// Role – a named permission group that tasks can be assigned to
// ---------------------------------------------------------------------------
struct CIARole {
  string id;
  string name; // e.g. "Basis Administrator", "Cloud Admin"
  string description;

  Json toJson() const {
    Json j = Json.emptyObject;
    j["id"] = id;
    j["name"] = name;
    j["description"] = description;
    return j;
  }
}
