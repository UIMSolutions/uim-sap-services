module uim.sap.cia.models.system;
import uim.sap.cia;

mixin(ShowModule!());

@safe:
// ---------------------------------------------------------------------------
// System – an entry in the system landscape (SAP Cloud, On-Premises, …)
// ---------------------------------------------------------------------------
class CIASystem : SAPTenantEntity {
mixin(SAPEntityTemplate!CIASystem);

  UUID id;
  string name;
  /// System type: "sap-cloud", "s4hana-on-prem", "s4hana-cloud", "successfactors", "ariba", "other"
  string systemType;
  string host;
  string description;
  bool active;
  
  override Json toJson()  {
    return super.toJson
    .set("id", id)
    .set("name", name)
    .set("system_type", systemType)
    .set("host", host)
    .set("description", description)
    .set("active", active);
   }
}