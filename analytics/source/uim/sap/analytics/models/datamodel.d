/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.analytics.models.datamodel;
import uim.sap.analytics;

mixin(ShowModule!());

@safe:

class AnalyticsDataModel : SAPTenantEntity {
  mixin(SAPTenantEntityTemplate!AnalyticsDataModel);

  string modelId;
  string name;
  string description;
  string modelType;   // "planning", "analytic", "embedded"
  Json dimensions;    // dimension definitions with hierarchies
  Json measures;      // measure definitions (calculated, restricted, etc.)
  Json hierarchies;   // hierarchy definitions for dimensions
  Json variables;     // input variables for filtering
  string datasetId;   // linked dataset
  string status;      // "active", "draft", "error"
  SysTime createdAt;
  SysTime updatedAt;

  override Json toJson() {
    return super.toJson()
      .set("model_id", modelId)
      .set("name", name)
      .set("description", description)
      .set("model_type", modelType)
      .set("dimensions", dimensions)
      .set("measures", measures)
      .set("hierarchies", hierarchies)
      .set("variables", variables)
      .set("dataset_id", datasetId)
      .set("status", status)
      .set("created_at", createdAt.toISOExtString())
      .set("updated_at", updatedAt.toISOExtString());
  }
}
