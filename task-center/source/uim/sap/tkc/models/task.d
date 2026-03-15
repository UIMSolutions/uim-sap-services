/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.tkc.models.task;

import uim.sap.tkc;

mixin(ShowModule!());

@safe:

struct TKCTask {
  string tenantId;
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
  SysTime createdAt;
  SysTime updatedAt;
  bool hasDueAt;
  SysTime dueAt;
  TKCTaskAction[] actionHistory;

  override Json toJson()  {
    Json info = super.toJson;
    payload["tenant_id"] = tenantId;
    payload["task_id"] = taskId;
    payload["provider_id"] = providerId;
    payload["provider_task_id"] = providerTaskId;
    payload["title"] = title;
    payload["description"] = description;
    payload["assignee"] = assignee;
    payload["status"] = status;
    payload["priority"] = priority;
    payload["native_app_url"] = nativeAppUrl;
    payload["native_app_name"] = nativeAppName;

    Json tagValues = Json.emptyArray;
    foreach (tag; tags)
      tagValues ~= tag;
    payload["tags"] = tagValues;

    payload["attributes"] = attributes;
    payload["created_at"] = createdAt.toISOExtString();
    payload["updated_at"] = updatedAt.toISOExtString();
    payload["due_at"] = hasDueAt ? dueAt.toISOExtString() : null;

    Json actionValues = Json.emptyArray;
    foreach (item; actionHistory)
      actionValues ~= item.toJson();
    payload["action_history"] = actionValues;
    return payload;
  }
}
