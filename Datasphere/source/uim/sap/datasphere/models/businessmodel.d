module uim.sap.datasphere.models.businessmodel;

import uim.sap.datasphere;

@safe:

struct DATBusinessModel {
  string tenantId;
  string modelId;
  string name;
  string description;
  string grain;
  string[] dimensions;
  string[] measures;
  SysTime updatedAt;

  Json toJson() const {
    Json payload = Json.emptyObject;
    Json dimPayload = Json.emptyArray;
    Json measurePayload = Json.emptyArray;

    foreach (dim; dimensions)
      dimPayload ~= dim;
    foreach (measure; measures)
      measurePayload ~= measure;

    payload["tenant_id"] = tenantId;
    payload["model_id"] = modelId;
    payload["name"] = name;
    payload["description"] = description;
    payload["grain"] = grain;
    payload["dimensions"] = dimPayload;
    payload["measures"] = measurePayload;
    payload["updated_at"] = updatedAt.toISOExtString();
    return payload;
  }
}
