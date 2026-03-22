module uim.sap.cag.models.models;

import std.datetime : SysTime;

import vibe.data.json : Json;

struct CAGContentProvider {
  UUID tenantId;
  string providerId;
  string name;
  string providerType;
  string endpoint;
  string[] supportedTypes;
  bool active;
  SysTime createdAt;
  SysTime updatedAt;

  override Json toJson() {
    Json payload = Json.emptyObject;
    payload["tenant_id"] = tenantId;
    payload["provider_id"] = providerId;
    payload["name"] = name;
    payload["provider_type"] = providerType;
    payload["endpoint"] = endpoint;

    Json types = Json.emptyArray;
    foreach (value; supportedTypes)
      types ~= value;
    payload["supported_types"] = types;

    payload["active"] = active;
    payload["created_at"] = createdAt.toISOExtString();
    payload["updated_at"] = updatedAt.toISOExtString();
    return payload;
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
