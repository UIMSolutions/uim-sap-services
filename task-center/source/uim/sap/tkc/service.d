/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.tkc.service;

import uim.sap.tkc;

mixin(ShowModule!());

@safe:

class TKCService : SAPService {
  private TKCConfig _config;
  private TKCStore _store;

  this(TKCConfig config) {
    super(config);

    _store = new TKCStore(config.cacheFilePath);
  }

  override Json health() {
    Json payload = super.health();
    payload["domain"] = "task-center";
    return payload;
  }

  Json listProviders() {
    Json providers = _store.listProviders().map!(provider => provider.toJson).array.toJson;

    return Json.emptyObject
      .set("providers", providers)
      .set("count", cast(long)providers.length);
  }

  Json registerProvider(Json data) {
    auto now = Clock.currTime();

    TKCProvider provider;
    provider.providerid = requiredUUID(body, "provider_id");
    provider.name = requiredString(body, "name");
    provider.providerType = optionalString(body, "provider_type", "sap");
    provider.endpoint = optionalString(body, "endpoint", "");
    provider.active = optionalBoolean(data, "active", true);
    provider.createdAt = now;
    provider.updatedAt = now;

    auto saved = _store.upsertProvider(provider);

    return Json.emptyObject
      .set("message", "Provider registered")
      .set("provider", saved.toJson());
  }

  Json federateTasks(UUID tenantId, string providerId, Json data) {
    validateTenant(tenantId);
    if (providerId.length == 0)
      throw new TKCValidationException("provider_id is required");

    auto provider = _store.getProvider(providerId);
    if (provider.isNull)
      throw new TKCNotFoundException("Provider", providerId);
    if (!provider.get.active)
      throw new TKCValidationException("Provider is inactive");

    if (!("tasks" in data) || !data["tasks"].isArray) {
      throw new TKCValidationException("tasks must be an array");
    }

    auto now = Clock.currTime();
    Json savedTasks = Json.emptyArray;

    foreach (entry; data["tasks"]) {
      if (!entry.isObject)
        throw new TKCValidationException("tasks must contain objects");

      TKCTask task;
      task.tenantId = tenantId;
      task.providerId = providerId;
      task.taskid = requiredUUID(entry, "task_id");
      task.providerTaskId = optionalString(entry, "provider_task_id", task.taskId);
      task.title = requiredString(entry, "title");
      task.description = optionalString(entry, "description", "");
      task.assignee = optionalString(entry, "assignee", "");
      task.status = normalizeStatus(optionalString(entry, "status", "open"));
      task.priority = normalizePriority(optionalString(entry, "priority", "medium"));
      task.nativeAppUrl = optionalString(entry, "native_app_url", provider.get.endpoint);
      task.nativeAppName = optionalString(entry, "native_app_name", provider.get.name);
      task.tags = readStringArray(entry, "tags");
      task.attributes = readObject(entry, "attributes");
      task.createdAt = now;
      task.updatedAt = now;

      auto dueAtRaw = optionalString(entry, "due_at", "");
      if (dueAtRaw.length > 0) {
        task.hasDueAt = true;
        task.dueAt = parseIsoTime(dueAtRaw, "due_at");
      }

      auto saved = _store.upsertTask(task);
      savedTasks ~= saved.toJson();
    }

    auto providerToUpdate = provider.get;
    providerToUpdate.hasLastSync = true;
    providerToUpdate.lastSyncAt = now;
    providerToUpdate.updatedAt = now;
    _store.upsertProvider(providerToUpdate);

    return Json.emptyObject
      .set("message", "Tasks federated and cached")
      .set("tenant_id", tenantId)
      .set("provider_id", providerId)
      .set("count", cast(long)savedTasks.length)
      .set("tasks", savedTasks);
    return payload;
  }

  Json listTasks(
    UUID tenantId,
    string assignee,
    string status,
    string providerId,
    string priority,
    string search,
    string sortBy,
    string sortOrder,
    size_t limit,
    size_t offset
  ) {
    validateTenant(tenantId);

    auto normalizedStatus = status.length > 0 ? normalizeStatus(status) : "";
    auto normalizedPriority = priority.length > 0 ? normalizePriority(priority) : "";
    auto normalizedSearch = toLower(search);
    auto normalizedProvider = providerId;
    auto normalizedSortBy = normalizeSortBy(sortBy);
    auto descending = toLower(sortOrder) == "desc";

    TKCTask[] filtered;
    foreach (task; _store.listTasks()) {
      if (task.tenantId != tenantId)
        continue;
      if (assignee.length > 0 && task.assignee != assignee)
        continue;
      if (normalizedStatus.length > 0 && task.status != normalizedStatus)
        continue;
      if (normalizedProvider.length > 0 && task.providerId != normalizedProvider)
        continue;
      if (normalizedPriority.length > 0 && task.priority != normalizedPriority)
        continue;
      if (normalizedSearch.length > 0) {
        auto hayTitle = toLower(task.title);
        auto hayDescription = toLower(task.description);
        if (hayTitle.indexOf(normalizedSearch) < 0 && hayDescription.indexOf(normalizedSearch) < 0)
          continue;
      }
      filtered ~= task;
    }

    sort!((a, b) => compareTasks(a, b, normalizedSortBy, descending))(filtered);

    auto safeOffset = offset > filtered.length ? filtered.length : offset;
    auto safeLimit = limit == 0 ? 100 : limit;
    auto end = safeOffset + safeLimit;
    if (end > filtered.length)
      end = filtered.length;

    Json tasks = Json.emptyArray;
    foreach (task; filtered[safeOffset .. end])
      tasks ~= task.toJson();

    return Json.emptyObject
      .set("tenant_id", tenantId)
      .set("total", cast(long)filtered.length)
      .set("returned", cast(long)tasks.length)
      .set("offset", cast(long)safeOffset)
      .set("limit", cast(long)safeLimit)
      .set("tasks", tasks);
  }

  Json getTask(UUID tenantId, string taskId) {
    validateTenant(tenantId);
    if (taskId.length == 0)
      throw new TKCValidationException("task_id is required");

    auto task = _store.getTask(tenantId, taskId);
    if (task.isNull)
      throw new TKCNotFoundException("Task", taskId);

    Json payload = Json.emptyObject;
    payload["task"] = task.get.toJson();
    return payload;
  }

  Json performTaskAction(UUID tenantId, string taskId, Json data) {
    validateTenant(tenantId);
    if (taskId.length == 0)
      throw new TKCValidationException("task_id is required");

    auto storedTask = _store.getTask(tenantId, taskId);
    if (storedTask.isNull)
      throw new TKCNotFoundException("Task", taskId);

    auto action = normalizeAction(requiredString(body, "action"));
    auto performedBy = requiredString(body, "performed_by");
    auto comment = optionalString(body, "comment", "");

    auto task = storedTask.get;
    auto now = Clock.currTime();

    TKCTaskAction history;
    history.action = action;
    history.performedBy = performedBy;
    history.comment = comment;
    history.performedAt = now;
    task.actionHistory ~= history;

    task.status = applyAction(task.status, action);
    task.updatedAt = now;

    auto saved = _store.upsertTask(task);

    return Json.emptyObject
      .set("message", "Task action executed")
      .set("task", saved.toJson());
  }

  Json navigateToTaskApp(UUID tenantId, string taskId) {
    validateTenant(tenantId);
    if (taskId.length == 0)
      throw new TKCValidationException("task_id is required");

    auto storedTask = _store.getTask(tenantId, taskId);
    if (storedTask.isNull)
      throw new TKCNotFoundException("Task", taskId);

    auto task = storedTask.get;
    if (task.nativeAppUrl.length == 0)
      throw new TKCValidationException("Task has no native_app_url");

    return Json.emptyObject
      .set("task_id", task.taskId)
      .set("native_app_url", task.nativeAppUrl)
      .set("native_app_name", task.nativeAppName)
      .set("message", "Open native task application using native_app_url");

  }

  private string normalizeStatus(string value) const {
    auto normalized = toLower(value);
    if (normalized == "in-process")
      normalized = "in_progress";
    if (
      normalized != "open" && normalized != "in_progress" && normalized != "completed" &&
      normalized != "canceled" && normalized != "ready"
      ) {
      throw new TKCValidationException(
        "status must be one of open|in_progress|completed|canceled|ready");
    }
    return normalized;
  }

  private string normalizePriority(string value) const {
    auto normalized = toLower(value);
    if (normalized != "low" && normalized != "medium" && normalized != "high" && normalized != "critical") {
      throw new TKCValidationException("priority must be one of low|medium|high|critical");
    }
    return normalized;
  }

  private string normalizeSortBy(string value) const {
    auto normalized = toLower(value);
    if (normalized.length == 0)
      return "updated_at";
    if (
      normalized != "updated_at" && normalized != "created_at" && normalized != "due_at" &&
      normalized != "priority" && normalized != "title" && normalized != "status"
      ) {
      throw new TKCValidationException(
        "sort_by must be one of updated_at|created_at|due_at|priority|title|status"
      );
    }
    return normalized;
  }

  private bool compareTasks(TKCTask left, TKCTask right, string sortBy, bool descending) const {
    if (descending)
      return compareTasksAscending(right, left, sortBy);
    return compareTasksAscending(left, right, sortBy);
  }

  private bool compareTasksAscending(TKCTask left, TKCTask right, string sortBy) const {
    bool less;
    final switch (sortBy) {
    case "created_at":
      less = left.createdAt < right.createdAt;
      break;
    case "due_at":
      auto leftDue = left.hasDueAt ? left.dueAt : SysTime.fromISOExtString("9999-12-31T23:59:59Z");
      auto rightDue = right.hasDueAt ? right.dueAt
        : SysTime.fromISOExtString("9999-12-31T23:59:59Z");
      less = leftDue < rightDue;
      break;
    case "priority":
      less = priorityRank(left.priority) < priorityRank(right.priority);
      break;
    case "title":
      less = left.title < right.title;
      break;
    case "status":
      less = left.status < right.status;
      break;
    case "updated_at":
      less = left.updatedAt < right.updatedAt;
      break;
    }

    return less;
  }

  private int priorityRank(string value) const {
    switch (value) {
    case "low":
      return 1;
    case "medium":
      return 2;
    case "high":
      return 3;
    case "critical":
      return 4;
    default:
      return 2;
    }
  }

  private string normalizeAction(string value) const {
    auto normalized = toLower(value);
    if (
      normalized != "claim" && normalized != "release" && normalized != "approve" &&
      normalized != "reject" && normalized != "complete" && normalized != "reopen"
      ) {
      throw new TKCValidationException(
        "action must be one of claim|release|approve|reject|complete|reopen");
    }
    return normalized;
  }

  private string applyAction(string currentStatus, string action) const {
    final switch (action) {
    case "claim":
      return "in_progress";
    case "release":
      return "open";
    case "approve":
      return "completed";
    case "reject":
      return "canceled";
    case "complete":
      return "completed";
    case "reopen":
      return "open";
    }
  }

  private SysTime parseIsoTime(string value, string key) const {
    try {
      return SysTime.fromISOExtString(value);
    } catch (Exception) {
      throw new TKCValidationException(key ~ " must be an ISO-8601 datetime");
    }
  }
}
