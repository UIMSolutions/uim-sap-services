module uim.sap.atp.service;

import std.datetime : Clock;
import std.string : toLower;
import std.conv : to;

import vibe.data.json : Json;

import uim.sap.atp.config;
import uim.sap.atp.exceptions;
import uim.sap.atp.models;
import uim.sap.atp.store;

class ATPService {
    private ATPConfig _config;
    private ATPStore _store;

    this(ATPConfig config) {
        config.validate();
        _config = config;
        _store = new ATPStore;
        seedPredefinedCatalogs();
    }

    @property const(ATPConfig) config() const { return _config; }

    Json health() const {
        Json payload = Json.emptyObject;
        payload["status"] = "UP";
        payload["service"] = _config.serviceName;
        payload["version"] = _config.serviceVersion;
        payload["ai_provider"] = _config.aiProvider;
        return payload;
    }

    Json ready() const {
        Json payload = Json.emptyObject;
        payload["status"] = "READY";
        return payload;
    }

    Json listCatalogs(string tenantId) {
        validateTenant(tenantId);
        Json catalogs = Json.emptyArray;
        foreach (catalog; _store.listCatalogs(tenantId)) catalogs ~= catalog.toJson();

        Json payload = Json.emptyObject;
        payload["catalogs"] = catalogs;
        payload["count"] = cast(long)catalogs.length;
        return payload;
    }

    Json upsertCatalog(string tenantId, Json body) {
        validateTenant(tenantId);
        auto now = Clock.currTime();

        ATPCatalog catalog;
        catalog.tenantId = tenantId;
        catalog.catalogId = readRequired(body, "catalog_id");
        catalog.name = readRequired(body, "name");
        catalog.scenario = readOptional(body, "scenario", "custom");
        catalog.predefined = readOptionalBool(body, "predefined", false);
        catalog.commandIds = readStringArray(body, "command_ids");
        catalog.createdAt = now;
        catalog.updatedAt = now;

        auto saved = _store.upsertCatalog(catalog);
        Json payload = Json.emptyObject;
        payload["message"] = "Catalog saved";
        payload["catalog"] = saved.toJson();
        return payload;
    }

    Json listCommands(string tenantId, string catalogId) {
        validateTenant(tenantId);
        Json commands = Json.emptyArray;
        foreach (command; _store.listCommands(tenantId, catalogId)) commands ~= command.toJson();

        Json payload = Json.emptyObject;
        payload["commands"] = commands;
        payload["count"] = cast(long)commands.length;
        return payload;
    }

    Json upsertCommand(string tenantId, string catalogId, Json body) {
        validateTenant(tenantId);
        if (_store.getCatalog(tenantId, catalogId).isNull) throw new ATPNotFoundException("Catalog not found");

        auto now = Clock.currTime();
        ATPCommand command;
        command.tenantId = tenantId;
        command.commandId = readRequired(body, "command_id");
        command.catalogId = catalogId;
        command.name = readRequired(body, "name");
        command.description = readOptional(body, "description", "");
        command.commandType = readOptional(body, "command_type", "script");
        command.steps = readStringArray(body, "steps");
        command.allowPrivateEnvironment = readOptionalBool(body, "allow_private_environment", false);
        command.defaults = readObject(body, "defaults");
        command.createdAt = now;
        command.updatedAt = now;

        auto saved = _store.upsertCommand(command);

        auto catalog = _store.getCatalog(tenantId, catalogId).get;
        if (!contains(catalog.commandIds, saved.commandId)) catalog.commandIds ~= saved.commandId;
        catalog.updatedAt = now;
        _store.upsertCatalog(catalog);

        Json payload = Json.emptyObject;
        payload["message"] = "Command saved";
        payload["command"] = saved.toJson();
        return payload;
    }

    Json runPredefinedCommand(string tenantId, Json body) {
        validateTenant(tenantId);
        auto commandId = readRequired(body, "command_id");
        auto command = requireCommand(tenantId, commandId);

        auto now = Clock.currTime();
        ATPExecution execution;
        execution.tenantId = tenantId;
        execution.executionId = "exec-" ~ to!string(now.stdTime);
        execution.commandId = commandId;
        execution.triggerType = readOptional(body, "trigger_type", "manual");
        execution.status = "SUCCESS";
        execution.input = readObject(body, "input");
        execution.result = Json.emptyObject;
        execution.result["message"] = "Command executed";
        execution.result["steps_executed"] = toJsonArray(command.steps);
        execution.result["private_environment"] = command.allowPrivateEnvironment;
        execution.startedAt = now;
        execution.finishedAt = Clock.currTime();

        auto saved = _store.upsertExecution(execution);

        Json payload = Json.emptyObject;
        payload["message"] = "Execution completed";
        payload["execution"] = saved.toJson();
        return payload;
    }

    Json listExecutions(string tenantId) {
        validateTenant(tenantId);
        Json executions = Json.emptyArray;
        foreach (execution; _store.listExecutions(tenantId)) executions ~= execution.toJson();
        Json payload = Json.emptyObject;
        payload["executions"] = executions;
        payload["count"] = cast(long)executions.length;
        return payload;
    }

    Json backupContent(string tenantId, Json body) {
        validateTenant(tenantId);
        auto now = Clock.currTime();

        ATPBackup backup;
        backup.tenantId = tenantId;
        backup.backupId = readOptional(body, "backup_id", "backup-" ~ to!string(now.stdTime));
        backup.mode = readOptional(body, "mode", "on-demand");
        backup.content = Json.emptyObject;
        backup.content["catalogs"] = toJsonArray(_store.listCatalogs(tenantId));
        backup.content["commands"] = toJsonArray(_store.listCommands(tenantId));
        backup.content["schedules"] = toJsonArray(_store.listSchedules(tenantId));
        backup.createdAt = now;

        auto saved = _store.upsertBackup(backup);
        Json payload = Json.emptyObject;
        payload["message"] = "Backup completed";
        payload["backup"] = saved.toJson();
        return payload;
    }

    Json restoreContent(string tenantId, Json body) {
        validateTenant(tenantId);
        auto backupId = readRequired(body, "backup_id");
        auto backup = _store.getBackup(tenantId, backupId);
        if (backup.isNull) throw new ATPNotFoundException("Backup not found");

        Json payload = Json.emptyObject;
        payload["message"] = "Restore simulated";
        payload["restored_backup_id"] = backupId;
        payload["restored_at"] = Clock.currTime().toISOExtString();
        payload["content"] = backup.get.content;
        return payload;
    }

    Json listBackups(string tenantId) {
        validateTenant(tenantId);
        Json backups = Json.emptyArray;
        foreach (backup; _store.listBackups(tenantId)) backups ~= backup.toJson();

        Json payload = Json.emptyObject;
        payload["backups"] = backups;
        payload["count"] = cast(long)backups.length;
        return payload;
    }

    Json upsertSecretInput(string tenantId, Json body) {
        validateTenant(tenantId);
        auto now = Clock.currTime();

        ATPSecretInput input;
        input.tenantId = tenantId;
        input.key = readRequired(body, "key");
        auto value = readRequired(body, "value");
        input.maskedValue = maskValue(value);
        input.purpose = readOptional(body, "purpose", "command-input");
        input.updatedAt = now;

        auto saved = _store.upsertSecretInput(input);
        Json payload = Json.emptyObject;
        payload["message"] = "Secure input stored";
        payload["secret"] = saved.toJson();
        return payload;
    }

    Json listSecretInputs(string tenantId) {
        validateTenant(tenantId);
        Json secrets = Json.emptyArray;
        foreach (secret; _store.listSecretInputs(tenantId)) secrets ~= secret.toJson();

        Json payload = Json.emptyObject;
        payload["secrets"] = secrets;
        payload["count"] = cast(long)secrets.length;
        return payload;
    }

    Json upsertSchedule(string tenantId, Json body) {
        validateTenant(tenantId);
        auto now = Clock.currTime();

        ATPSchedule schedule;
        schedule.tenantId = tenantId;
        schedule.scheduleId = readRequired(body, "schedule_id");
        schedule.targetType = readOptional(body, "target_type", "execution");
        schedule.targetId = readRequired(body, "target_id");
        schedule.mode = readOptional(body, "mode", "cron");
        schedule.expression = readRequired(body, "expression");
        schedule.active = readOptionalBool(body, "active", true);
        schedule.createdAt = now;
        schedule.updatedAt = now;

        auto saved = _store.upsertSchedule(schedule);
        Json payload = Json.emptyObject;
        payload["message"] = "Schedule saved";
        payload["schedule"] = saved.toJson();
        return payload;
    }

    Json listSchedules(string tenantId) {
        validateTenant(tenantId);
        Json schedules = Json.emptyArray;
        foreach (schedule; _store.listSchedules(tenantId)) schedules ~= schedule.toJson();
        Json payload = Json.emptyObject;
        payload["schedules"] = schedules;
        payload["count"] = cast(long)schedules.length;
        return payload;
    }

    Json upsertEventTrigger(string tenantId, Json body) {
        validateTenant(tenantId);
        auto now = Clock.currTime();

        ATPEventTrigger trigger;
        trigger.tenantId = tenantId;
        trigger.triggerId = readRequired(body, "trigger_id");
        trigger.eventSource = readRequired(body, "event_source");
        trigger.eventType = readRequired(body, "event_type");
        trigger.commandId = readRequired(body, "command_id");
        trigger.active = readOptionalBool(body, "active", true);
        trigger.createdAt = now;

        auto saved = _store.upsertEventTrigger(trigger);
        Json payload = Json.emptyObject;
        payload["message"] = "Event trigger saved";
        payload["trigger"] = saved.toJson();
        return payload;
    }

    Json listEventTriggers(string tenantId) {
        validateTenant(tenantId);
        Json triggers = Json.emptyArray;
        foreach (trigger; _store.listEventTriggers(tenantId)) triggers ~= trigger.toJson();
        Json payload = Json.emptyObject;
        payload["triggers"] = triggers;
        payload["count"] = cast(long)triggers.length;
        return payload;
    }

    Json fireEvent(string tenantId, Json body) {
        validateTenant(tenantId);
        auto source = readRequired(body, "event_source");
        auto eventType = readRequired(body, "event_type");

        Json matched = Json.emptyArray;
        foreach (trigger; _store.listEventTriggers(tenantId)) {
            if (!trigger.active) continue;
            if (trigger.eventSource != source || trigger.eventType != eventType) continue;

            Json runBody = Json.emptyObject;
            runBody["command_id"] = trigger.commandId;
            runBody["trigger_type"] = "event";
            runBody["input"] = readObject(body, "payload");
            auto executed = runPredefinedCommand(tenantId, runBody);
            matched ~= executed["execution"];
        }

        Json payload = Json.emptyObject;
        payload["message"] = "Event processed";
        payload["matched_executions"] = matched;
        payload["count"] = cast(long)matched.length;
        return payload;
    }

    Json generateAiContent(string tenantId, Json body) {
        validateTenant(tenantId);
        auto prompt = readRequired(body, "prompt");
        auto contentType = readOptional(body, "content_type", "runbook");

        Json generated = Json.emptyObject;
        generated["title"] = "AI Generated " ~ contentType;
        generated["summary"] = "Generated by " ~ _config.aiProvider ~ " using provided prompt";
        generated["draft"] = "Prompt: " ~ prompt;
        generated["suggested_steps"] = Json.emptyArray;
        generated["suggested_steps"] ~= "Validate target resource state";
        generated["suggested_steps"] ~= "Execute command sequence safely";
        generated["suggested_steps"] ~= "Record outcome and notify stakeholders";

        Json payload = Json.emptyObject;
        payload["message"] = "AI content generated";
        payload["provider"] = _config.aiProvider;
        payload["generated"] = generated;
        return payload;
    }

    Json executePrivateOperation(string tenantId, Json body) {
        validateTenant(tenantId);
        auto operationType = readOptional(body, "operation_type", "http-request");
        auto endpoint = readRequired(body, "endpoint");

        Json payload = Json.emptyObject;
        payload["message"] = "Private environment operation queued";
        payload["operation_type"] = operationType;
        payload["endpoint"] = endpoint;
        payload["network_zone"] = readOptional(body, "network_zone", "private-onprem");
        payload["status"] = "QUEUED";
        return payload;
    }

    private void seedPredefinedCatalogs() {
        auto tenantId = "global";
        auto now = Clock.currTime();

        ATPCatalog catalog;
        catalog.tenantId = tenantId;
        catalog.catalogId = "btp-devops";
        catalog.name = "BTP DevOps Starter";
        catalog.scenario = "sap-btp-devops";
        catalog.predefined = true;
        catalog.commandIds = ["cf-health-check", "restart-app"]; 
        catalog.createdAt = now;
        catalog.updatedAt = now;
        _store.upsertCatalog(catalog);

        ATPCommand health;
        health.tenantId = tenantId;
        health.commandId = "cf-health-check";
        health.catalogId = catalog.catalogId;
        health.name = "Cloud Foundry App Health Check";
        health.description = "Checks app health in Cloud Foundry.";
        health.commandType = "script";
        health.steps = ["cf login", "cf app <name>", "inspect routes and events"];
        health.allowPrivateEnvironment = false;
        health.defaults = Json.emptyObject;
        health.createdAt = now;
        health.updatedAt = now;
        _store.upsertCommand(health);

        ATPCommand restart;
        restart.tenantId = tenantId;
        restart.commandId = "restart-app";
        restart.catalogId = catalog.catalogId;
        restart.name = "Restart Application";
        restart.description = "Restarts an app and checks health.";
        restart.commandType = "chain";
        restart.steps = ["cf restart <name>", "cf app <name>"];
        restart.allowPrivateEnvironment = true;
        restart.defaults = Json.emptyObject;
        restart.createdAt = now;
        restart.updatedAt = now;
        _store.upsertCommand(restart);
    }

    private ATPCommand requireCommand(string tenantId, string commandId) {
        auto command = _store.getCommand(tenantId, commandId);
        if (!command.isNull) return command.get;

        auto global = _store.getCommand("global", commandId);
        if (!global.isNull) return global.get;

        throw new ATPNotFoundException("Command not found");
    }

    private void validateTenant(string tenantId) const {
        if (tenantId.length == 0) throw new ATPValidationException("tenant_id is required");
    }

    private string readRequired(Json body, string key) const {
        if (!(key in body) || body[key].type != Json.Type.string || body[key].get!string.length == 0) {
            throw new ATPValidationException(key ~ " is required");
        }
        return body[key].get!string;
    }

    private string readOptional(Json body, string key, string fallback) const {
        if (!(key in body) || body[key].type == Json.Type.null_) return fallback;
        if (body[key].type != Json.Type.string) throw new ATPValidationException(key ~ " must be a string");
        return body[key].get!string;
    }

    private bool readOptionalBool(Json body, string key, bool fallback) const {
        if (!(key in body) || body[key].type == Json.Type.null_) return fallback;
        if (body[key].type != Json.Type.bool_) throw new ATPValidationException(key ~ " must be a boolean");
        return body[key].get!bool;
    }

    private string[] readStringArray(Json body, string key) const {
        string[] values;
        if (!(key in body) || body[key].type == Json.Type.null_) return values;
        if (body[key].type != Json.Type.array) throw new ATPValidationException(key ~ " must be an array");
        foreach (item; body[key]) {
            if (item.type != Json.Type.string) throw new ATPValidationException(key ~ " must contain strings");
            values ~= item.get!string;
        }
        return values;
    }

    private Json readObject(Json body, string key) const {
        if (!(key in body) || body[key].type == Json.Type.null_) return Json.emptyObject;
        if (body[key].type != Json.Type.object) throw new ATPValidationException(key ~ " must be an object");
        return body[key];
    }

    private string maskValue(string value) const {
        if (value.length <= 4) return "****";
        return value[0 .. 2] ~ "****" ~ value[$ - 2 .. $];
    }

    private bool contains(string[] values, string value) const {
        foreach (item; values) if (toLower(item) == toLower(value)) return true;
        return false;
    }

    private Json toJsonArray(string[] values) const {
        Json result = Json.emptyArray;
        foreach (value; values) result ~= value;
        return result;
    }

    private Json toJsonArray(T)(T[] values) const {
        Json result = Json.emptyArray;
        foreach (value; values) result ~= value.toJson();
        return result;
    }
}
