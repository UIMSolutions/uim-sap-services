module uim.sap.isa.models.datacontextreport;

struct DataContextReport {
  string id;
  string tenantId;
  string title;
  string entityType;
  string situationType;
  string importedFrom;
  SysTime importedAt;

  Json toJson() const {
    Json payload = Json.emptyObject;
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