module uim.sap.cps.models.provider;

struct CPSContentProvider {
  UUID tenantId;
  UUID providerId;
  string solutionName;
  bool saasEnabled;
  Json catalogs;
  SysTime updatedAt;

  override Json toJson()  {
    Json info = super.toJson;
    payload["tenant_id"] = tenantId;
    payload["provider_id"] = providerId;
    payload["solution_name"] = solutionName;
    payload["saas_enabled"] = saasEnabled;
    payload["catalogs"] = catalogs;
    payload["updated_at"] = updatedAt.toISOExtString();
    return payload;
  }
}