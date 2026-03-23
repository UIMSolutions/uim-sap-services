module uim.sap.atp.service;

import std.datetime : Clock;
import std.string : toLower;
import std.conv : to;

import vibe.data.json : Json;

import uim.sap.atp.config;
import uim.sap.atp.exceptions;
import uim.sap.atp.models;
import uim.sap.atp.store;

/** 
 * ATPService provides core functionalities for managing catalogs, commands, executions, and related features in the Automation Pilot service.
 * It handles business logic, input validation, and interactions with the underlying data store.
 *
    * The service includes methods for: 
    - Health and readiness checks
    - Catalog management (list, upsert)
    - Command management (list, upsert)
    - Execution of predefined commands
    - Execution management (list)
    - Backup and restore of content
    - Secret input management (list, upsert)
    - Schedule management (list, upsert)
    - Event trigger management (list, upsert)
    - Firing events to trigger commands
    - AI content generation based on prompts
    - Simulated execution of operations in private environments
* Note: The service uses a simple in-memory store (ATPStore) for demonstration purposes. In a production scenario, this would likely be replaced with a persistent database.
 */
class ATPService : SAPService {
  mixin(SAPServiceTemplate!ATPService);

  private ATPStore _store;

  this(ATPConfig config) {
    super(config);

    _store = new ATPStore;
    seedPredefinedCatalogs();
  }

  Json health() const {
    ATPConfig cfg = cast(ATPConfig)_config;

    Json healthInfo = super.health();
    healthInfo["ai_provider"] = cfg.aiProvider;
    return healthInfo;
  }

  Json listCatalogs(UUID tenantId) {
    validateTenant(tenantId);
    Json catalogs = _store.listCatalogs(tenantId).map!(catalog => catalog.toJson()).array.toJson();

    return Json.emptyObject
      .set("catalogs", catalogs)
      .set("count", cast(long)catalogs.length);
  }

  Json upsertCatalog(UUID tenantId, Json data) {
    validateTenant(tenantId);
    auto now = Clock.currTime();

    ATPCatalog catalog = new ATPCatalog(data);

    catalog.tenantId = tenantId;
    catalog.catalogid = requiredUUID(data, "catalog_id");
    catalog.name = requiredString(data, "name");
    catalog.scenario = optionalString(data, "scenario", "custom");
    catalog.predefined = data.getBoolean("predefined", false);
    catalog.commandIds = readStringArray(data, "command_ids");
    catalog.createdAt = now;
    catalog.updatedAt = now;

    auto saved = _store.upsertCatalog(catalog);
    return Json.emptyObject
      .set("message", "Catalog saved")
      .set("catalog", saved.toJson());
  }

  Json listCommands(UUID tenantId, string catalogId) {
    validateTenant(tenantId);
    Json commands = _store.listCommands(tenantId, catalogId)
      .map!(command => command.toJson()).array.toJson();

    return Json.emptyObject
      .set("commands", commands)
      .set("count", cast(long)commands.length);
  }

  Json upsertCommand(UUID tenantId, string catalogId, Json data) {
    validateTenant(tenantId);
    if (_store.getCatalog(tenantId, catalogId).isNull)
      throw new ATPNotFoundException("Catalog not found");

    auto now = Clock.currTime();
    ATPCommand command = new ATPCommand(data);
    command.tenantId = tenantId;
    command.commandid = requiredUUID(data, "command_id");
    command.catalogId = catalogId;
    command.name = requiredString(data, "name");
    command.description = optionalString(data, "description", "");
    command.commandType = optionalString(data, "command_type", "script");
    command.steps = readStringArray(data, "steps");
    command.allowPrivateEnvironment = data.getBoolean("allow_private_environment", false);
    command.defaults = readObject(data, "defaults");
    command.createdAt = now;
    command.updatedAt = now;

    auto saved = _store.upsertCommand(command);

    auto catalog = _store.getCatalog(tenantId, catalogId).get;
    if (!contains(catalog.commandIds, saved.commandId))
      catalog.commandIds ~= saved.commandId;
    catalog.updatedAt = now;
    _store.upsertCatalog(catalog);

    return Json.emptyObject
      .set("message", "Command saved")
      .set("command", saved.toJson());
  }

  Json runPredefinedCommand(UUID tenantId, Json data) {
    validateTenant(tenantId);
    auto commandid = requiredUUID(data, "command_id");
    auto command = requireCommand(tenantId, commandId);

    auto now = Clock.currTime();

    ATPExecution execution = new ATPExecution(data);
    execution.tenantId = tenantId;
    execution.executionId = "exec-" ~ to!string(now.stdTime);
    execution.commandId = commandId;
    execution.triggerType = optionalString(data, "trigger_type", "manual");
    execution.status = "SUCCESS";
    execution.input = readObject(data, "input");
    execution.result = Json.emptyObject;
    execution.result["message"] = "Command executed";
    execution.result["steps_executed"] = toJsonArray(command.steps);
    execution.result["private_environment"] = command.allowPrivateEnvironment;
    execution.startedAt = now;
    execution.finishedAt = Clock.currTime();

    auto saved = _store.upsertExecution(execution);

    return Json.emptyObject
      .set("message", "Execution completed")
      .set("execution", saved.toJson());
  }

  Json listExecutions(UUID tenantId) {
    validateTenant(tenantId);
    Json executions = _store.listExecutions(tenantId)
      .map!(execution => execution.toJson())
      .array.toJson;

    return Json.emptyObject
      .set("executions", executions)
      .set("count", cast(long)executions.length);
  }

  Json backupContent(UUID tenantId, Json data) {
    validateTenant(tenantId);
    auto now = Clock.currTime();

    ATPBackup backup = new ATPBackup(data);
    backup.tenantId = tenantId;
    backup.backupId = optionalString(data, "backup_id", "backup-" ~ to!string(now.stdTime));
    backup.mode = optionalString(data, "mode", "on-demand");
    backup.content = Json.emptyObject
      .set("catalogs", toJsonArray(_store.listCatalogs(tenantId)))
      .set("commands", toJsonArray(_store.listCommands(tenantId)))
      .set("schedules", toJsonArray(_store.listSchedules(tenantId)))
      .set("event_triggers", toJsonArray(_store.listEventTriggers(tenantId)));  
    backup.createdAt = now;

    auto saved = _store.upsertBackup(backup);
    
    return Json.emptyObject
      .set("message", "Backup completed")
      .set("backup", saved.toJson());
  }

  Json restoreContent(UUID tenantId, Json data) {
    validateTenant(tenantId);
    auto backupid = requiredUUID(data, "backup_id");
    auto backup = _store.getBackup(tenantId, backupId);
    if (backup.isNull)
      throw new ATPNotFoundException("Backup not found");

    return Json.emptyObject
      .set("message", "Restore simulated")
      .set("restored_backup_id", backupId)
      .set("restored_at", Clock.currTime().toISOExtString())
      .set("content", backup.get.content);
  }

  Json listBackups(UUID tenantId) {
    validateTenant(tenantId);
    Json backups = _store.listBackups(tenantId)
      .map!(backup => backup.toJson()).array.toJson();

    return Json.emptyObject
      .set("backups", backups)
      .set("count", cast(long)backups.length);
  }

  Json upsertSecretInput(UUID tenantId, Json data) {
    validateTenant(tenantId);
    auto now = Clock.currTime();

    ATPSecretInput input;
    input.tenantId = tenantId;
    input.key = requiredString(data, "key");
    auto value = requiredString(data, "value");
    input.maskedValue = maskValue(value);
    input.purpose = optionalString(data, "purpose", "command-input");
    input.updatedAt = now;

    auto saved = _store.upsertSecretInput(input);

    return Json.emptyObject
      .set("message", "Secure input stored")
      .set("secret", saved.toJson());
  }

  Json listSecretInputs(UUID tenantId) {
    validateTenant(tenantId);
    Json secrets = _store.listSecretInputs(tenantId).map!(secret => secret.toJson()).array.toJson();

    return Json.emptyObject
      .set("secrets", secrets)
      .set("count", cast(long)secrets.length);
  }

  Json upsertSchedule(UUID tenantId, Json data) {
    validateTenant(tenantId);
    auto now = Clock.currTime();

    ATPSchedule schedule = new ATPSchedule(data);
    schedule.tenantId = tenantId;
    schedule.scheduleid = requiredUUID(data, "schedule_id");
    schedule.targetType = optionalString(data, "target_type", "execution");
    schedule.targetid = requiredUUID(data, "target_id");
    schedule.mode = optionalString(data, "mode", "cron");
    schedule.expression = requiredString(data, "expression");
    schedule.active = data.getBoolean("active", true);
    schedule.createdAt = now;
    schedule.updatedAt = now;

    auto saved = _store.upsertSchedule(schedule);

    return Json.emptyObject
      .set("message", "Schedule saved")
      .set("schedule", saved.toJson());
  }

  Json listSchedules(UUID tenantId) {
    validateTenant(tenantId);

    Json schedules = _store.listSchedules(tenantId)
      .map!(schedule => schedule.toJson()).array.toJson();

    return Json.emptyObject
      .set("schedules", schedules)
      .set("count", cast(long)schedules.length);
  }

  Json upsertEventTrigger(UUID tenantId, Json data) {
    validateTenant(tenantId);
    auto now = Clock.currTime();

    ATPEventTrigger trigger = new ATPEventTrigger(data);
    trigger.tenantId = tenantId;
    trigger.triggerid = requiredUUID(data, "trigger_id");
    trigger.eventSource = requiredString(data, "event_source");
    trigger.eventType = requiredString(data, "event_type");
    trigger.commandid = requiredUUID(data, "command_id");
    trigger.active = data.getBoolean("active", true);
    trigger.createdAt = now;
    trigger.updatedAt = now;
    auto saved = _store.upsertEventTrigger(trigger);

    return Json.emptyObject
      .set("message", "Event trigger saved")
      .set("trigger", saved.toJson());
  }

  Json listEventTriggers(UUID tenantId) {
    validateTenant(tenantId);

    Json triggers = _store.listEventTriggers(tenantId)
      .map!(trigger => trigger.toJson()).array.toJson();

    return Json.emptyObject
      .set("triggers", triggers)
      .set("count", cast(long)triggers.length);
  }

  Json fireEvent(UUID tenantId, Json data) {
    validateTenant(tenantId);
    auto source = requiredString(data, "event_source");
    auto eventType = requiredString(data, "event_type");

    Json matched = Json.emptyArray;
    foreach (trigger; _store.listEventTriggers(tenantId)) {
      if (!trigger.active)
        continue;
      if (trigger.eventSource != source || trigger.eventType != eventType)
        continue;

      Json runBody = Json.emptyObject
        .set("command_id", trigger.commandId)
        .set("trigger_type", "event")
        .set("input", readObject(data, "payload"));

      auto executed = runPredefinedCommand(tenantId, runBody);
      matched ~= executed["execution"];
    }

    return Json.emptyObject
      .set("message", "Event processed")
      .set("matched_executions", matched)
      .set("count", cast(long)matched.length);
  }

  Json generateAiContent(UUID tenantId, Json data) {
    validateTenant(tenantId);
    auto prompt = requiredString(data, "prompt");
    auto contentType = optionalString(data, "content_type", "runbook");

    Json generated = Json.emptyObject
      .set("title", "AI Generated " ~ contentType)
      .set("summary", "Generated by " ~ _config.aiProvider ~ " using provided prompt")
      .set("draft", "Prompt: " ~ prompt)
      .set("suggested_steps", [
          "Validate target resource state", "Execute command sequence safely",
          "Record outcome and notify stakeholders"
        ].toJson);

    return Json.emptyObject
      .set("message", "AI content generated")
      .set("provider", _config.aiProvider)
      .set("generated", generated);
  }

  Json executePrivateOperation(UUID tenantId, Json data) {
    validateTenant(tenantId);
    auto operationType = optionalString(data, "operation_type", "http-request");
    auto endpoint = requiredString(data, "endpoint");

    return Json.emptyObject
      .set("message", "Private environment operation queued")
      .set("operation_type", operationType)
      .set("endpoint", endpoint)
      .set("network_zone", optionalString(data, "network_zone", "private-onprem"))
      .set("status", "QUEUED");
  }

  private void seedPredefinedCatalogs() {
    auto tenantId = "global";
    auto now = Clock.currTime();

    ATPCatalog catalog = new ATPCatalog;
    catalog.tenantId = tenantId;
    catalog.catalogId = "btp-devops";
    catalog.name = "BTP DevOps Starter";
    catalog.scenario = "sap-btp-devops";
    catalog.predefined = true;
    catalog.commandIds = ["cf-health-check", "restart-app"];
    catalog.createdAt = now;
    catalog.updatedAt = now;
    _store.upsertCatalog(catalog);

    ATPCommand health = new ATPCommand;
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

    ATPCommand restart = new ATPCommand;
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

  private ATPCommand requireCommand(UUID tenantId, string commandId) {
    auto command = _store.getCommand(tenantId, commandId);
    if (!command.isNull)
      return command.get;

    auto global = _store.getCommand("global", commandId);
    if (!global.isNull)
      return global.get;

    throw new ATPNotFoundException("Command not found");
  }

  private string[] readStringArray(Json data, string key) const {
    string[] values;
    if (!(key in data) || data[key].isNull)
      return values;
    requiredArrayType(data, key);

    foreach (item; data[key]) {
      if (!item.isString)
        throw new ATPValidationException(key ~ " must contain strings");
      values ~= item.get!string;
    }
    return values;
  }

  private string maskValue(string value) const {
    if (value.length <= 4)
      return "****";
    return value[0 .. 2] ~ "****" ~ value[$ - 2 .. $];
  }

  private bool contains(string[] values, string value) const {
    return values.any!(v => toLower(v) == toLower(value));
  }

  private Json toJsonArray(string[] values) const {
    return values.map!(v => v.toJson()).array.toJson;
  }

  private Json toJsonArray(T)(T[] values) const {
    return values.map!(v => v.toJson()).array.toJson;
  }
}
