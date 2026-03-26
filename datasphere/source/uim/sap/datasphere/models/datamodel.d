/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.datasphere.models.datamodel;

import uim.sap.datasphere;

mixin(ShowModule!());

@safe:

/**
  * Represents a data model in the Datasphere service.
  * This struct is used for storing and transferring data model information within the service.
  * It includes fields for tenant ID, model ID, name, type, SQL definition, data flow definition, sources, status, and the last updated timestamp.
  * The toJson method allows for easy conversion of the data model to a JSON object for API responses or storage.
  * 
  * Fields:
  * - tenantId: The ID of the tenant this data model belongs to.
  * - modelId: A unique identifier for the data model.
  * - name: The name of the data model.
  * - modelType: The type of the data model (e.g., "sql", "graph").
  * - sqlDefinition: The SQL definition of the data model, if applicable.
  * - dataFlowDefinition: The definition of the data flow associated with this model, if applicable.
  * - sources: An array of source identifiers that this data model depends on.
  * - status: The current status of the data model (e.g., "active", "inactive", "error").
  * - updatedAt: The timestamp of the last update to this data model.
 */
struct DATDataModel {
  UUID tenantId;
  UUID modelId;
  string name;
  string modelType;
  string sqlDefinition;
  string dataFlowDefinition;
  string[] sources;
  string status;
  SysTime updatedAt;

  override Json toJson() {
    auto sourcePayload = sources.map!(s => s.toJson).array;

    return super.toJson
      .set("tenant_id", tenantId)
      .set("model_id", modelId)
      .set("name", name)
      .set("model_type", modelType)
      .set("sql_definition", sqlDefinition)
      .set("data_flow_definition", dataFlowDefinition)
      .set("sources", sourcePayload)
      .set("status", status)
      .set("updated_at", updatedAt.toISOExtString());
  }
}
