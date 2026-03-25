module uim.sap.isa.models.datacontextreport;
import uim.sap.isa;

mixin(ShowModule!());

@safe:
class DataContextReport : SAPTenantObject {
  mixin(SAPObjectTemplate!DataContextReport);

  string id;
  string title;
  string entityType;
  string situationType;
  string importedFrom;
  SysTime importedAt;

  override Json toJson()  {
    return super.toJson
    .set("id", id)
    .set("title", title)
    .set("entity_type", entityType)
    .set("situation_type", situationType)
    .set("imported_from", importedFrom)
    .set("imported_at", importedAt.toISOExtString());
  }
}