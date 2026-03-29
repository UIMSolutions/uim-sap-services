/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.analytics.models.plan;
import uim.sap.analytics;

mixin(ShowModule!());

@safe:

class AnalyticsPlan : SAPTenantEntity {
  mixin(SAPTenantEntityTemplate!AnalyticsPlan);

  string planId;
  string name;
  string description;
  string modelId;     // linked planning model
  string planType;    // "budget", "forecast", "what-if"
  string status;      // "draft", "in_review", "approved", "published"
  string createdBy;
  Json versions;      // plan versions (actual, plan, forecast)
  Json cells;         // planning cell data
  Json workflows;     // approval workflow definitions
  SysTime startDate;
  SysTime endDate;
  SysTime createdAt;
  SysTime updatedAt;

  override Json toJson() {
    return super.toJson()
      .set("plan_id", planId)
      .set("name", name)
      .set("description", description)
      .set("model_id", modelId)
      .set("plan_type", planType)
      .set("status", status)
      .set("created_by", createdBy)
      .set("versions", versions)
      .set("cells", cells)
      .set("workflows", workflows)
      .set("start_date", startDate.toISOExtString())
      .set("end_date", endDate.toISOExtString())
      .set("created_at", createdAt.toISOExtString())
      .set("updated_at", updatedAt.toISOExtString());
  }
}
