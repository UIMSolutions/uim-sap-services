/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.analytics.models.dashboard;
import uim.sap.analytics;

mixin(ShowModule!());

@safe:

class AnalyticsDashboard : SAPTenantObject {
  mixin(SAPTenantObjectTemplate!AnalyticsDashboard);

  string dashboardId;
  string title;
  string description;
  string layout;     // "grid", "freeform", "responsive"
  string status;     // "draft", "published", "archived"
  string createdBy;
  bool isInteractive;
  Json[] widgets;    // array of widget definitions (charts, KPIs, filters)
  Json filters;      // global dashboard filters
  SysTime createdAt;
  SysTime updatedAt;

  override Json toJson() {
    Json widgetsJson = Json.emptyArray;
    foreach (widget; widgets) {
      widgetsJson ~= widget;
    }

    return super.toJson()
      .set("dashboard_id", dashboardId)
      .set("title", title)
      .set("description", description)
      .set("layout", layout)
      .set("status", status)
      .set("created_by", createdBy)
      .set("is_interactive", isInteractive)
      .set("widgets", widgetsJson)
      .set("filters", filters)
      .set("created_at", createdAt.toISOExtString())
      .set("updated_at", updatedAt.toISOExtString());
  }
}
