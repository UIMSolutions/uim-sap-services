module uim.sap.tc.models.task;

import std.datetime : SysTime;

import vibe.data.json : Json;

import uim.sap.tc.models.taskaction;

@safe:

struct TCTask {
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
    TCTaskAction[] actionHistory;

    Json toJson() const {
        Json payload = Json.emptyObject;
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
        foreach (tag; tags) tagValues ~= tag;
        payload["tags"] = tagValues;

        payload["attributes"] = attributes;
        payload["created_at"] = createdAt.toISOExtString();
        payload["updated_at"] = updatedAt.toISOExtString();
        payload["due_at"] = hasDueAt ? dueAt.toISOExtString() : null;

        Json actionValues = Json.emptyArray;
        foreach (item; actionHistory) actionValues ~= item.toJson();
        payload["action_history"] = actionValues;
        return payload;
    }
}
