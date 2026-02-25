module uim.sap.atp.store;

import core.sync.mutex : Mutex;
import std.typecons : Nullable;

import uim.sap.atp.models;

class ATPStore {
    private ATPCatalog[string] _catalogs;
    private ATPCommand[string] _commands;
    private ATPExecution[string] _executions;
    private ATPSchedule[string] _schedules;
    private ATPEventTrigger[string] _eventTriggers;
    private ATPSecretInput[string] _secretInputs;
    private ATPBackup[string] _backups;
    private Mutex _lock;

    this() { _lock = new Mutex; }

    ATPCatalog upsertCatalog(ATPCatalog catalog) {
        synchronized (_lock) {
            auto key = scoped("catalog", catalog.tenantId, catalog.catalogId);
            if (auto existing = key in _catalogs) catalog.createdAt = existing.createdAt;
            _catalogs[key] = catalog;
            return catalog;
        }
    }

    ATPCatalog[] listCatalogs(string tenantId) {
        ATPCatalog[] values;
        synchronized (_lock) foreach (key, value; _catalogs) if (belongs(key, tenantId, "catalog")) values ~= value;
        return values;
    }

    Nullable!ATPCatalog getCatalog(string tenantId, string catalogId) {
        synchronized (_lock) {
            auto key = scoped("catalog", tenantId, catalogId);
            if (auto value = key in _catalogs) return Nullable!ATPCatalog(*value);
            return Nullable!ATPCatalog.init;
        }
    }

    ATPCommand upsertCommand(ATPCommand command) {
        synchronized (_lock) {
            auto key = scoped("command", command.tenantId, command.commandId);
            if (auto existing = key in _commands) command.createdAt = existing.createdAt;
            _commands[key] = command;
            return command;
        }
    }

    Nullable!ATPCommand getCommand(string tenantId, string commandId) {
        synchronized (_lock) {
            auto key = scoped("command", tenantId, commandId);
            if (auto value = key in _commands) return Nullable!ATPCommand(*value);
            return Nullable!ATPCommand.init;
        }
    }

    ATPCommand[] listCommands(string tenantId, string catalogId = "") {
        ATPCommand[] values;
        synchronized (_lock) {
            foreach (key, value; _commands) {
                if (!belongs(key, tenantId, "command")) continue;
                if (catalogId.length > 0 && value.catalogId != catalogId) continue;
                values ~= value;
            }
        }
        return values;
    }

    ATPExecution upsertExecution(ATPExecution execution) {
        synchronized (_lock) {
            _executions[scoped("execution", execution.tenantId, execution.executionId)] = execution;
            return execution;
        }
    }

    ATPExecution[] listExecutions(string tenantId) {
        ATPExecution[] values;
        synchronized (_lock) foreach (key, value; _executions) if (belongs(key, tenantId, "execution")) values ~= value;
        return values;
    }

    ATPSchedule upsertSchedule(ATPSchedule schedule) {
        synchronized (_lock) {
            auto key = scoped("schedule", schedule.tenantId, schedule.scheduleId);
            if (auto existing = key in _schedules) schedule.createdAt = existing.createdAt;
            _schedules[key] = schedule;
            return schedule;
        }
    }

    ATPSchedule[] listSchedules(string tenantId) {
        ATPSchedule[] values;
        synchronized (_lock) foreach (key, value; _schedules) if (belongs(key, tenantId, "schedule")) values ~= value;
        return values;
    }

    ATPEventTrigger upsertEventTrigger(ATPEventTrigger trigger) {
        synchronized (_lock) {
            _eventTriggers[scoped("event-trigger", trigger.tenantId, trigger.triggerId)] = trigger;
            return trigger;
        }
    }

    ATPEventTrigger[] listEventTriggers(string tenantId) {
        ATPEventTrigger[] values;
        synchronized (_lock) foreach (key, value; _eventTriggers) if (belongs(key, tenantId, "event-trigger")) values ~= value;
        return values;
    }

    ATPSecretInput upsertSecretInput(ATPSecretInput secret) {
        synchronized (_lock) {
            _secretInputs[scoped("secret", secret.tenantId, secret.key)] = secret;
            return secret;
        }
    }

    ATPSecretInput[] listSecretInputs(string tenantId) {
        ATPSecretInput[] values;
        synchronized (_lock) foreach (key, value; _secretInputs) if (belongs(key, tenantId, "secret")) values ~= value;
        return values;
    }

    ATPBackup upsertBackup(ATPBackup backup) {
        synchronized (_lock) {
            _backups[scoped("backup", backup.tenantId, backup.backupId)] = backup;
            return backup;
        }
    }

    Nullable!ATPBackup getBackup(string tenantId, string backupId) {
        synchronized (_lock) {
            auto key = scoped("backup", tenantId, backupId);
            if (auto value = key in _backups) return Nullable!ATPBackup(*value);
            return Nullable!ATPBackup.init;
        }
    }

    ATPBackup[] listBackups(string tenantId) {
        ATPBackup[] values;
        synchronized (_lock) foreach (key, value; _backups) if (belongs(key, tenantId, "backup")) values ~= value;
        return values;
    }

    private string scoped(string kind, string tenantId, string id) {
        return tenantId ~ ":" ~ kind ~ ":" ~ id;
    }

    private bool belongs(string key, string tenantId, string kind) {
        auto prefix = tenantId ~ ":" ~ kind ~ ":";
        return key.length >= prefix.length && key[0 .. prefix.length] == prefix;
    }
}
