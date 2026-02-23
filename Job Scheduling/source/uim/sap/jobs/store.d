module uim.sap.jobs.store;

import core.sync.mutex : Mutex;
import std.datetime : SysTime;

import uim.sap.jobs.models;

class JobSchedulingStore {
    private Job[string] _jobs;
    private Schedule[string] _schedules;
    private RunLog[string] _runs;
    private AlertEvent[string] _alerts;
    private CFTaskRun[string] _cfTaskRuns;

    private long _counter;
    private Mutex _lock;

    this() {
        _lock = new Mutex;
    }

    string nextId(string prefix) {
        synchronized (_lock) {
            ++_counter;
            return prefix ~ "-" ~ _counter.to!string;
        }
    }

    Job upsertJob(Job item) {
        synchronized (_lock) {
            _jobs[scopedKey(item.tenantId, "job", item.jobId)] = item;
            return item;
        }
    }

    bool getJob(string tenantId, string jobId, out Job item) {
        synchronized (_lock) {
            auto key = scopedKey(tenantId, "job", jobId);
            if (auto existing = key in _jobs) {
                item = *existing;
                return true;
            }
        }
        return false;
    }

    Job[] listJobs(string tenantId) {
        Job[] values;
        synchronized (_lock) {
            foreach (key, value; _jobs) {
                if (belongsTo(key, tenantId)) values ~= value;
            }
        }
        return values;
    }

    bool deleteJob(string tenantId, string jobId) {
        synchronized (_lock) {
            auto key = scopedKey(tenantId, "job", jobId);
            if (key in _jobs) {
                _jobs.remove(key);
                return true;
            }
        }
        return false;
    }

    Schedule upsertSchedule(Schedule item) {
        synchronized (_lock) {
            _schedules[scopedKey(item.tenantId, "schedule", item.scheduleId)] = item;
            return item;
        }
    }

    bool getSchedule(string tenantId, string scheduleId, out Schedule item) {
        synchronized (_lock) {
            auto key = scopedKey(tenantId, "schedule", scheduleId);
            if (auto existing = key in _schedules) {
                item = *existing;
                return true;
            }
        }
        return false;
    }

    Schedule[] listSchedules(string tenantId) {
        Schedule[] values;
        synchronized (_lock) {
            foreach (key, value; _schedules) {
                if (belongsTo(key, tenantId)) values ~= value;
            }
        }
        return values;
    }

    Schedule[] listDueSchedules(SysTime now) {
        Schedule[] values;
        synchronized (_lock) {
            foreach (_, value; _schedules) {
                if (value.active && value.nextRunAt <= now) values ~= value;
            }
        }
        return values;
    }

    bool deleteSchedule(string tenantId, string scheduleId) {
        synchronized (_lock) {
            auto key = scopedKey(tenantId, "schedule", scheduleId);
            if (key in _schedules) {
                _schedules.remove(key);
                return true;
            }
        }
        return false;
    }

    RunLog upsertRun(RunLog item) {
        synchronized (_lock) {
            _runs[scopedKey(item.tenantId, "run", item.runId)] = item;
            return item;
        }
    }

    RunLog[] listRuns(string tenantId) {
        RunLog[] values;
        synchronized (_lock) {
            foreach (key, value; _runs) {
                if (belongsTo(key, tenantId)) values ~= value;
            }
        }
        return values;
    }

    AlertEvent upsertAlert(AlertEvent item) {
        synchronized (_lock) {
            _alerts[scopedKey(item.tenantId, "alert", item.alertId)] = item;
            return item;
        }
    }

    AlertEvent[] listAlerts(string tenantId) {
        AlertEvent[] values;
        synchronized (_lock) {
            foreach (key, value; _alerts) {
                if (belongsTo(key, tenantId)) values ~= value;
            }
        }
        return values;
    }

    CFTaskRun upsertCFTaskRun(CFTaskRun item) {
        synchronized (_lock) {
            _cfTaskRuns[scopedKey(item.tenantId, "cftask", item.taskRunId)] = item;
            return item;
        }
    }

    CFTaskRun[] listCFTaskRuns(string tenantId) {
        CFTaskRun[] values;
        synchronized (_lock) {
            foreach (key, value; _cfTaskRuns) {
                if (belongsTo(key, tenantId)) values ~= value;
            }
        }
        return values;
    }

    private string scopedKey(string tenantId, string scope, string id) {
        return tenantId ~ ":" ~ scope ~ ":" ~ id;
    }

    private bool belongsTo(string key, string tenantId) {
        return key.length > tenantId.length + 1 &&
            key[0 .. tenantId.length] == tenantId &&
            key[tenantId.length] == ':';
    }
}
