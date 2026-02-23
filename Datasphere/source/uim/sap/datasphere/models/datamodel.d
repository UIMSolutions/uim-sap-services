module uim.sap.datasphere.models.datamodel;

import uim.sap.datasphere;

@safe:

struct DATDataModel {
  string tenantId;
  string modelId;
  string name;
  string modelType;
  string sqlDefinition;
  string dataFlowDefinition;
  string[] sources;
  string status;
  SysTime updatedAt;

  Json toJson() const {
    Json payload = Json.emptyObject;
    Json sourcePayload = Json.emptyArray;
    foreach (source; sources)
      sourcePayload ~= source;

    payload["tenant_id"] = tenantId;
    payload["model_id"] = modelId;
    payload["name"] = name;
    payload["model_type"] = modelType;
    payload["sql_definition"] = sqlDefinition;
    payload["data_flow_definition"] = dataFlowDefinition;
    payload["sources"] = sourcePayload;
    payload["status"] = status;
    payload["updated_at"] = updatedAt.toISOExtString();
    return payload;
  }
}
