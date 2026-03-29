/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.analytics.models.story;
import uim.sap.analytics;

mixin(ShowModule!());

@safe:

class AnalyticsStory : SAPTenantObject {
  mixin(SAPTenantObjectTemplate!AnalyticsStory);

  string storyId;
  string title;
  string description;
  string storyType; // "canvas", "responsive", "optimized"
  string status;    // "draft", "published", "archived"
  string createdBy;
  Json[] pages;     // array of page definitions with charts/visualizations
  Json sharing;     // sharing and embedding settings
  SysTime createdAt;
  SysTime updatedAt;

  override Json toJson() {
    Json pagesJson = Json.emptyArray;
    foreach (page; pages) {
      pagesJson ~= page;
    }

    return super.toJson()
      .set("story_id", storyId)
      .set("title", title)
      .set("description", description)
      .set("story_type", storyType)
      .set("status", status)
      .set("created_by", createdBy)
      .set("pages", pagesJson)
      .set("sharing", sharing)
      .set("created_at", createdAt.toISOExtString())
      .set("updated_at", updatedAt.toISOExtString());
  }
}
