module uim.sap.cag.models.models;

import std.datetime : SysTime;

import vibe.data.json : Json;

class CAGContentProvider : SAPTenantObject {
  mixin(SAPObjectTemplate!CAGContentProvider);

  UUID providerId;
  string name;
  string providerType;
  string endpoint;
  string[] supportedTypes;
  bool active;

  override Json toJson() {
    Json types = Json.emptyArray;
    foreach (value; supportedTypes)
      types ~= value;

    return super.toJson()
      .set("provider_id", providerId)
      .set("name", name)
      .set("provider_type", providerType)
      .set("endpoint", endpoint)
      .set("supported_types", types)
      .set("active", active);
  }
}

struct CAGTransportActivity {
  UUID tenantId;
  string activityId;
  string assemblyId;
  string queueId;
  string status;
  string message;
  string initiatedBy;
  Json exportPayload;
  SysTime createdAt;

  override Json toJson() {
    Json payload = Json.emptyObject;
    payload["tenant_id"] = tenantId;
    payload["activity_id"] = activityId;
    payload["assembly_id"] = assemblyId;
    payload["queue_id"] = queueId;
    payload["status"] = status;
    payload["message"] = message;
    payload["initiated_by"] = initiatedBy;
    payload["export_payload"] = exportPayload;
    payload["created_at"] = createdAt.toISOExtString();
    return payload;
  }
}
