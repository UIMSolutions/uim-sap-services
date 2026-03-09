module uim.sap.mdi.models.filter;

import uim.sap.mdi;

mixin(ShowModule!());

@safe:
struct MDIFilter {
  string tenantId;
  string filterId;
  string objectType;
  Json conditions;
  bool active;
  SysTime updatedAt;

  Json toJson() const {
    Json payload = Json.emptyObject;
    payload["tenant_id"] = tenantId;
    payload["filter_id"] = filterId;
    payload["object_type"] = objectType;
    payload["conditions"] = conditions;
    payload["active"] = active;
    payload["updated_at"] = updatedAt.toISOExtString();
    return payload;
  }
}
