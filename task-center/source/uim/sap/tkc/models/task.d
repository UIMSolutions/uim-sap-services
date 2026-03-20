/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.tkc.models.task;

import uim.sap.tkc;

mixin(ShowModule!());

@safe:

class TKCTask : SAPTenantObject {
mixin(SAPObjectTemplate!TKCTask);

  string taskId;
  string providerId;
  string providerTaskId;
  string title;
  string description;
  string assignee;
  string status;
  string priority;
  string nativeAppUrl;
  string nativeAppName;
  string[] tags;
  Json attributes;
  bool hasDueAt;
  SysTime dueAt;
  TKCTaskAction[] actionHistory;

  override Json toJson()  {
    Json tagValues = Json.emptyArray;
    foreach (tag; tags)
      tagValues ~= tag;

    Json actionValues = Json.emptyArray;
    foreach (item; actionHistory)
      actionValues ~= item.toJson();

    return super.toJson
    .set("task_id", taskId)
    .set("provider_id", providerId)
    .set("provider_task_id", providerTaskId)
    .set("title"] = title)
    .set("description"] = description)
    .set("assignee"] = assignee)
    .set("status"] = status)
    .set("priority"] = priority)
    .set("native_app_url"] = nativeAppUrl)
    .set("native_app_name"] = nativeAppName)
    .set("tags"] = tagValues)
    .set("attributes", attributes)
    .set("due_at", hasDueAt ? dueAt.toISOExtString() : null)
    .set("action_history", actionValues);
  }
}
