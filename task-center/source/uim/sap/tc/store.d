/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.tkc.store;

import core.sync.mutex : Mutex;

import std.datetime : SysTime;
import std.exception : enforce;
import std.file : exists, mkdirRecurse, readText, write;
import std.path : dirName;
import std.typecons : Nullable;

import vibe.data.json : Json, parseJsonString;

import uim.sap.tkc.exceptions;
import uim.sap.tkc.models;

class TCStore : SAPStore {
  private TCProvider[string] _providers;
  private TCTask[string] _tasks;
  private string _cacheFilePath;
  private Mutex _lock;

  this(string cacheFilePath) {
    _cacheFilePath = cacheFilePath;
    _lock = new Mutex;
    loadSnapshot();
  }

  TCProvider upsertProvider(TCProvider provider) {
    synchronized (_lock) {
      auto key = scopedProviderKey(provider.providerId);
      if (auto existing = key in _providers)
        provider.createdAt = existing.createdAt;
      _providers[key] = provider;
      persistSnapshot();
      return provider;
    }
  }

  Nullable!TCProvider getProvider(string providerId) {
    synchronized (_lock) {
      auto key = scopedProviderKey(providerId);
      if (auto value = key in _providers)
        return Nullable!TCProvider(*value);
      return Nullable!TCProvider.init;
    }
  }

  TCProvider[] listProviders() {
    TCProvider[] values;
    synchronized (_lock) {
      foreach (_key, value; _providers)
        values ~= value;
    }
    return values;
  }

  TCTask upsertTask(TCTask task) {
    synchronized (_lock) {
      auto key = scopedTaskKey(task.tenantId, task.taskId);
      if (auto existing = key in _tasks) {
        task.createdAt = existing.createdAt;
        if (task.actionHistory.length == 0)
          task.actionHistory = existing.actionHistory;
      }
      _tasks[key] = task;
      persistSnapshot();
      return task;
    }
  }

  Nullable!TCTask getTask(string tenantId, string taskId) {
    synchronized (_lock) {
      auto key = scopedTaskKey(tenantId, taskId);
      if (auto value = key in _tasks)
        return Nullable!TCTask(*value);
      return Nullable!TCTask.init;
    }
  }

  TCTask[] listTasks() {
    TCTask[] values;
    synchronized (_lock) {
      foreach (_key, value; _tasks)
        values ~= value;
    }
    return values;
  }

  private void loadSnapshot() {
    if (!exists(_cacheFilePath))
      return;

    try {
      auto raw = readText(_cacheFilePath);
      if (raw.length == 0)
        return;

      auto snapshot = parseJsonString(raw);
      if ("providers" in snapshot && snapshot["providers"].isArray) {
        foreach (item; snapshot["providers"]) {
          auto provider = parseProvider(item);
          _providers[scopedProviderKey(provider.providerId)] = provider;
        }
      }

      if ("tasks" in snapshot && snapshot["tasks"].isArray) {
        foreach (item; snapshot["tasks"]) {
          auto task = parseTask(item);
          _tasks[scopedTaskKey(task.tenantId, task.taskId)] = task;
        }
      }
    } catch (Exception e) {
      throw new TCStoreException("Failed to read task cache snapshot: " ~ e.msg);
    }
  }

  private void persistSnapshot() {
    try {
      auto parentDir = dirName(_cacheFilePath);
      if (!exists(parentDir))
        mkdirRecurse(parentDir);

      Json snapshot = Json.emptyObject;

      Json providerValues = Json.emptyArray;
      foreach (_key, provider; _providers)
        providerValues ~= provider.toJson();
      snapshot["providers"] = providerValues;

      Json taskValues = Json.emptyArray;
      foreach (_key, task; _tasks)
        taskValues ~= task.toJson();
      snapshot["tasks"] = taskValues;

      write(_cacheFilePath, snapshot.toString());
    } catch (Exception e) {
      throw new TCStoreException("Failed to persist task cache snapshot: " ~ e.msg);
    }
  }

  private TCProvider parseProvider(Json item) {
    enforce(item.isObject, new TCStoreException("Provider entry must be an object"));

    TCProvider provider;
    provider.providerId = readString(item, "provider_id", true);
    provider.name = readString(item, "name", true);
    provider.providerType = readString(item, "provider_type", false, "sap");
    provider.endpoint = readString(item, "endpoint", false, "");
    provider.active = readBool(item, "active", true);
    provider.createdAt = readTime(item, "created_at");
    provider.updatedAt = readTime(item, "updated_at");
    if ("last_sync_at" in item && item["last_sync_at"].isString) {
      provider.hasLastSync = true;
      provider.lastSyncAt = SysTime.fromISOExtString(item["last_sync_at"].get!string);
    }
    return provider;
  }

  private TCTask parseTask(Json item) {
    enforce(item.isObject, new TCStoreException("Task entry must be an object"));

    TCTask task;
    task.tenantId = readString(item, "tenant_id", true);
    task.taskId = readString(item, "task_id", true);
    task.providerId = readString(item, "provider_id", true);
    task.providerTaskId = readString(item, "provider_task_id", false, "");
    task.title = readString(item, "title", true);
    task.description = readString(item, "description", false, "");
    task.assignee = readString(item, "assignee", false, "");
    task.status = readString(item, "status", false, "open");
    task.priority = readString(item, "priority", false, "medium");
    task.nativeAppUrl = readString(item, "native_app_url", false, "");
    task.nativeAppName = readString(item, "native_app_name", false, "");
    task.tags = readStringArray(item, "tags");
    task.attributes = readObject(item, "attributes");
    task.createdAt = readTime(item, "created_at");
    task.updatedAt = readTime(item, "updated_at");

    if ("due_at" in item && item["due_at"].isString) {
      task.hasDueAt = true;
      task.dueAt = SysTime.fromISOExtString(item["due_at"].get!string);
    }

    if ("action_history" in item && item["action_history"].isArray) {
      foreach (entry; item["action_history"]) {
        if (entry.type != Json.Type.object)
          continue;
        TCTaskAction action;
        action.action = readString(entry, "action", false, "");
        action.performedBy = readString(entry, "performed_by", false, "");
        action.comment = readString(entry, "comment", false, "");
        action.performedAt = readTime(entry, "performed_at");
        task.actionHistory ~= action;
      }
    }

    return task;
  }

  private string readString(Json item, string key, bool required, string fallback = "") {
    if (!(key in item) || item[key].type == Json.Type.null_) {
      if (required)
        throw new TCStoreException(key ~ " is required in cache item");
      return fallback;
    }
    if (!item[key].isString)
      throw new TCStoreException(key ~ " must be a string in cache item");
    auto value = item[key].get!string;
    if (required && value.length == 0)
      throw new TCStoreException(key ~ " cannot be empty in cache item");
    return value.length > 0 ? value : fallback;
  }

  private bool readBool(Json item, string key, bool fallback) {
    if (!(key in item) || item[key].type == Json.Type.null_)
      return fallback;
    if (!item[key].isBoolean)
      throw new TCStoreException(key ~ " must be boolean in cache item");
    return item[key].get!bool;
  }

  private SysTime readTime(Json item, string key) {
    if (!(key in item) || !item[key].isString || item[key].get!string.length == 0) {
      return SysTime.fromISOExtString("1970-01-01T00:00:00Z");
    }
    return SysTime.fromISOExtString(item[key].get!string);
  }

  private string[] readStringArray(Json item, string key) {
    string[] values;
    if (!(key in item) || item[key].type == Json.Type.null_)
      return values;
    if (!item[key].isArray)
      throw new TCStoreException(key ~ " must be an array in cache item");
    foreach (entry; item[key]) {
      if (entry.isString)
        values ~= entry.get!string;
    }
    return values;
  }

  private Json readObject(Json item, string key) const {
    if (!(key in item) || item[key].type == Json.Type.null_)
      return Json.emptyObject;
    if (!item[key].isObject)
      throw new TCStoreException(key ~ " must be an object in cache item");
    return item[key];
  }

  private string scopedProviderKey(string providerId) const {
    return providerId;
  }

  private string scopedTaskKey(string tenantId, string taskId) const {
    return tenantId ~ ":" ~ taskId;
  }
}
