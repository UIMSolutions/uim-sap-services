/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.analytics.models.dataset;
import uim.sap.analytics;

mixin(ShowModule!());

@safe:

class AnalyticsDataset : SAPTenantObject {
  mixin(SAPTenantObjectTemplate!AnalyticsDataset);

  string datasetId;
  string name;
  string description;
  string sourceType;   // "import", "live", "blend"
  string connectionId; // reference to connection for live data
  long rowCount;
  long columnCount;
  Json columns;        // column definitions
  Json importSchedule; // for scheduled imports
  string status;       // "ready", "importing", "error"
  SysTime createdAt;
  SysTime updatedAt;

  override Json toJson() {
    return super.toJson()
      .set("dataset_id", datasetId)
      .set("name", name)
      .set("description", description)
      .set("source_type", sourceType)
      .set("connection_id", connectionId)
      .set("row_count", rowCount)
      .set("column_count", columnCount)
      .set("columns", columns)
      .set("import_schedule", importSchedule)
      .set("status", status)
      .set("created_at", createdAt.toISOExtString())
      .set("updated_at", updatedAt.toISOExtString());
  }
}
