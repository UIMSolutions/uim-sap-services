/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.datasphere.models.businessmodel;

import uim.sap.datasphere;

mixin(ShowModule!());

@safe:

/**
  * Represents a business model in the Datasphere application.
  *
  * A business model defines the semantic layer of the data, including dimensions, measures, and grain.
  * It is used to create meaningful insights and analytics on top of the underlying data models.
  * Fields:
  * - tenantId: The ID of the tenant this business model belongs to.
  * - modelId: A unique identifier for the business model.
  * - name: The name of the business model.
  * - description: A brief description of the business model.
  * - grain: The level of detail for the business model (e.g., "daily", "transactional").
  * - dimensions: An array of dimension names included in the business model.
  * - measures: An array of measure names included in the business model.
  * - updatedAt: The timestamp of the last update to this business model.
  */
struct DATBusinessModel {
  UUID tenantId;
  string modelId;
  string name;
  string description;
  string grain;
  string[] dimensions;
  string[] measures;
  SysTime updatedAt;

  override Json toJson()  {
    Json info = super.toJson;
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
