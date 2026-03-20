module uim.sap.isa.models.datacontextreport;
import uim.sap.isa;

mixin(ShowModule!());

@safe:
struct DataContextReport {
  string id;
  UUID tenantId;
  string title;
  string entityType;
  string situationType;
  string importedFrom;
  SysTime importedAt;

  override Json toJson()  {
    Json info = super.toJson;
    payload["id"] = id;
    payload["tenant_id"] = tenantId;
    payload["title"] = title;
    payload["entity_type"] = entityType;
    payload["situation_type"] = situationType;
    payload["imported_from"] = importedFrom;
    payload["imported_at"] = importedAt.toISOExtString();
    return payload;
  }
}