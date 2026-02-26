module uim.sap.tc.service;

import std.algorithm.sorting : sort;
import std.datetime : Clock, SysTime;
import std.string : indexOf, toLower;

import vibe.data.json : Json;

import uim.sap.tc.config;
import uim.sap.tc.exceptions;
import uim.sap.tc.models;
import uim.sap.tc.store;

class TCService {
    private TCConfig _config;
    private TCStore _store;

    this(TCConfig config) {
        config.validate();
        _config = config;
        _store = new TCStore(config.cacheFilePath);
    }

    @property inout(TCConfig) config() inout {
        return _config;
    }

    Json health() const {
        Json payload = Json.emptyObject;
        payload["status"] = "UP";
        payload["service"] = _config.serviceName;
        payload["version"] = _config.serviceVersion;
        payload["domain"] = "task-center";
        return payload;
    }

    Json ready() const {
        Json payload = Json.emptyObject;
        payload["status"] = "READY";
        return payload;
    }

    Json listProviders() {
        Json providers = Json.emptyArray;
        foreach (provider; _store.listProviders()) providers ~= provider.toJson();

        Json payload = Json.emptyObject;
        payload["providers"] = providers;
        payload["count"] = cast(long)providers.length;
        return payload;
    }

    Json registerProvider(Json body) {
        auto now = Clock.currTime();

        TCProvider provider;
        provider.providerId = readRequired(body, "provider_id");
        provider.name = readRequired(body, "name");
        provider.providerType = readOptional(body, "provider_type", "sap");
        provider.endpoint = readOptional(body, "endpoint", "");
        provider.active = readOptionalBool(body, "active", true);
        provider.createdAt = now;
        provider.updatedAt = now;

        auto saved = _store.upsertProvider(provider);

        Json payload = Json.emptyObject;
        payload["message"] = "Provider registered";
        payload["provider"] = saved.toJson();
        return payload;
    }

    Json federateTasks(string tenantId, string providerId, Json body) {
        validateTenant(tenantId);
        if (providerId.length == 0) throw new TCValidationException("provider_id is required");

        auto provider = _store.getProvider(providerId);
        if (provider.isNull) throw new TCNotFoundException("Provider", providerId);
        if (!provider.get.active) throw new TCValidationException("Provider is inactive");

        if (!("tasks" in body) || body["tasks"].type != Json.Type.array) {
            throw new TCValidationException("tasks must be an array");
        }

        auto now = Clock.currTime();
        Json savedTasks = Json.emptyArray;

        foreach (entry; body["tasks"]) {
            if (entry.type != Json.Type.object) throw new TCValidationException("tasks must contain objects");

            TCTask task;
            task.tenantId = tenantId;
            task.providerId = providerId;
            task.taskId = readRequired(entry, "task_id");
            task.providerTaskId = readOptional(entry, "provider_task_id", task.taskId);
            task.title = readRequired(entry, "title");
            task.description = readOptional(entry, "description", "");
            task.assignee = readOptional(entry, "assignee", "");
            task.status = normalizeStatus(readOptional(entry, "status", "open"));
            task.priority = normalizePriority(readOptional(entry, "priority", "medium"));
            task.nativeAppUrl = readOptional(entry, "native_app_url", provider.get.endpoint);
            task.nativeAppName = readOptional(entry, "native_app_name", provider.get.name);
            task.tags = readStringArray(entry, "tags");
            task.attributes = readObject(entry, "attributes");
            task.createdAt = now;
            task.updatedAt = now;

            auto dueAtRaw = readOptional(entry, "due_at", "");
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

        Json payload = Json.emptyObject;
        payload["message"] = "Tasks federated and cached";
        payload["tenant_id"] = tenantId;
        payload["provider_id"] = providerId;
        payload["count"] = cast(long)savedTasks.length;
        payload["tasks"] = savedTasks;
        return payload;
    }

    Json listTasks(
        string tenantId,
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

        TCTask[] filtered;
        foreach (task; _store.listTasks()) {
            if (task.tenantId != tenantId) continue;
            if (assignee.length > 0 && task.assignee != assignee) continue;
            if (normalizedStatus.length > 0 && task.status != normalizedStatus) continue;
            if (normalizedProvider.length > 0 && task.providerId != normalizedProvider) continue;
            if (normalizedPriority.length > 0 && task.priority != normalizedPriority) continue;
            if (normalizedSearch.length > 0) {
                auto hayTitle = toLower(task.title);
                auto hayDescription = toLower(task.description);
                if (hayTitle.indexOf(normalizedSearch) < 0 && hayDescription.indexOf(normalizedSearch) < 0) continue;
            }
            filtered ~= task;
        }

        sort!((a, b) => compareTasks(a, b, normalizedSortBy, descending))(filtered);

        auto safeOffset = offset > filtered.length ? filtered.length : offset;
        auto safeLimit = limit == 0 ? 100 : limit;
        auto end = safeOffset + safeLimit;
        if (end > filtered.length) end = filtered.length;

        Json tasks = Json.emptyArray;
        foreach (task; filtered[safeOffset .. end]) tasks ~= task.toJson();

        Json payload = Json.emptyObject;
        payload["tenant_id"] = tenantId;
        payload["total"] = cast(long)filtered.length;
        payload["returned"] = cast(long)tasks.length;
        payload["offset"] = cast(long)safeOffset;
        payload["limit"] = cast(long)safeLimit;
        payload["tasks"] = tasks;
        return payload;
    }

    Json getTask(string tenantId, string taskId) {
        validateTenant(tenantId);
        if (taskId.length == 0) throw new TCValidationException("task_id is required");

        auto task = _store.getTask(tenantId, taskId);
        if (task.isNull) throw new TCNotFoundException("Task", taskId);

        Json payload = Json.emptyObject;
        payload["task"] = task.get.toJson();
        return payload;
    }

    Json performTaskAction(string tenantId, string taskId, Json body) {
        validateTenant(tenantId);
        if (taskId.length == 0) throw new TCValidationException("task_id is required");

        auto storedTask = _store.getTask(tenantId, taskId);
        if (storedTask.isNull) throw new TCNotFoundException("Task", taskId);

        auto action = normalizeAction(readRequired(body, "action"));
        auto performedBy = readRequired(body, "performed_by");
        auto comment = readOptional(body, "comment", "");

        auto task = storedTask.get;
        auto now = Clock.currTime();

        TCTaskAction history;
        history.action = action;
        history.performedBy = performedBy;
        history.comment = comment;
        history.performedAt = now;
        task.actionHistory ~= history;

        task.status = applyAction(task.status, action);
        task.updatedAt = now;

        auto saved = _store.upsertTask(task);

        Json payload = Json.emptyObject;
        payload["message"] = "Task action executed";
        payload["task"] = saved.toJson();
        return payload;
    }

    Json navigateToTaskApp(string tenantId, string taskId) {
        validateTenant(tenantId);
        if (taskId.length == 0) throw new TCValidationException("task_id is required");

        auto storedTask = _store.getTask(tenantId, taskId);
        if (storedTask.isNull) throw new TCNotFoundException("Task", taskId);

        auto task = storedTask.get;
        if (task.nativeAppUrl.length == 0) throw new TCValidationException("Task has no native_app_url");

        Json payload = Json.emptyObject;
        payload["task_id"] = task.taskId;
        payload["native_app_url"] = task.nativeAppUrl;
        payload["native_app_name"] = task.nativeAppName;
        payload["message"] = "Open native task application using native_app_url";
        return payload;
    }

    private void validateTenant(string tenantId) const {
        if (tenantId.length == 0) throw new TCValidationException("tenant_id is required");
    }

    private string normalizeStatus(string value) const {
        auto normalized = toLower(value);
        if (normalized == "in-process") normalized = "in_progress";
        if (
            normalized != "open" && normalized != "in_progress" && normalized != "completed" &&
            normalized != "canceled" && normalized != "ready"
        ) {
            throw new TCValidationException("status must be one of open|in_progress|completed|canceled|ready");
        }
        return normalized;
    }

    private string normalizePriority(string value) const {
        auto normalized = toLower(value);
        if (normalized != "low" && normalized != "medium" && normalized != "high" && normalized != "critical") {
            throw new TCValidationException("priority must be one of low|medium|high|critical");
        }
        return normalized;
    }

    private string normalizeSortBy(string value) const {
        auto normalized = toLower(value);
        if (normalized.length == 0) return "updated_at";
        if (
            normalized != "updated_at" && normalized != "created_at" && normalized != "due_at" &&
            normalized != "priority" && normalized != "title" && normalized != "status"
        ) {
            throw new TCValidationException(
                "sort_by must be one of updated_at|created_at|due_at|priority|title|status"
            );
        }
        return normalized;
    }

    private bool compareTasks(TCTask left, TCTask right, string sortBy, bool descending) const {
        if (descending) return compareTasksAscending(right, left, sortBy);
        return compareTasksAscending(left, right, sortBy);
    }

    private bool compareTasksAscending(TCTask left, TCTask right, string sortBy) const {
        bool less;
        final switch (sortBy) {
            case "created_at":
                less = left.createdAt < right.createdAt;
                break;
            case "due_at":
                auto leftDue = left.hasDueAt ? left.dueAt : SysTime.fromISOExtString("9999-12-31T23:59:59Z");
                auto rightDue = right.hasDueAt ? right.dueAt : SysTime.fromISOExtString("9999-12-31T23:59:59Z");
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
            throw new TCValidationException("action must be one of claim|release|approve|reject|complete|reopen");
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

    private string readRequired(Json body, string key) const {
        if (!(key in body) || body[key].type != Json.Type.string || body[key].get!string.length == 0) {
            throw new TCValidationException(key ~ " is required");
        }
        return body[key].get!string;
    }

    private string readOptional(Json body, string key, string fallback) const {
        if (!(key in body) || body[key].type == Json.Type.null_) return fallback;
        if (body[key].type != Json.Type.string) throw new TCValidationException(key ~ " must be a string");
        return body[key].get!string;
    }

    private bool readOptionalBool(Json body, string key, bool fallback) const {
        if (!(key in body) || body[key].type == Json.Type.null_) return fallback;
        if (body[key].type != Json.Type.bool_) throw new TCValidationException(key ~ " must be a boolean");
        return body[key].get!bool;
    }

    private string[] readStringArray(Json body, string key) const {
        string[] values;
        if (!(key in body) || body[key].type == Json.Type.null_) return values;
        if (body[key].type != Json.Type.array) throw new TCValidationException(key ~ " must be an array");
        foreach (item; body[key]) {
            if (item.type != Json.Type.string) throw new TCValidationException(key ~ " must contain strings");
            values ~= item.get!string;
        }
        return values;
    }

    private Json readObject(Json body, string key) const {
        if (!(key in body) || body[key].type == Json.Type.null_) return Json.emptyObject;
        if (body[key].type != Json.Type.object) throw new TCValidationException(key ~ " must be an object");
        return body[key];
    }

    private SysTime parseIsoTime(string value, string key) const {
        try {
            return SysTime.fromISOExtString(value);
        } catch (Exception) {
            throw new TCValidationException(key ~ " must be an ISO-8601 datetime");
        }
    }
}
