module uim.sap.mon.store;

import core.sync.mutex : Mutex;

import vibe.data.json : Json;

import uim.sap.mon.models;

class MONStore : SAPStore {
    private MONMetricSample[][string] _applicationMetricHistory;
    private MONMetricSample[][string] _databaseMetricHistory;
    private MONAvailabilityCheck[string] _availabilityChecks;
    private MONJMXCheck[string] _jmxChecks;
    private MONCustomCheck[string] _customChecks;
    private Json[string] _thresholdOverrides;

    private MONAlertEmailChannel _emailChannel;
    private MONAlertWebhookChannel _webhookChannel;
    private bool _hasEmailChannel = false;
    private bool _hasWebhookChannel = false;

    private Mutex _lock;

    this() {
        _lock = new Mutex;
    }

    MONMetricSample[] appendApplicationMetrics(string appId, MONMetricSample[] metrics) {
        synchronized (_lock) {
            foreach (item; metrics) {
                _applicationMetricHistory[appId] ~= item;
            }
            trimHistory(_applicationMetricHistory[appId]);
            return metrics;
        }
    }

    MONMetricSample[] appendDatabaseMetrics(string databaseId, MONMetricSample[] metrics) {
        synchronized (_lock) {
            foreach (item; metrics) {
                _databaseMetricHistory[databaseId] ~= item;
            }
            trimHistory(_databaseMetricHistory[databaseId]);
            return metrics;
        }
    }

    MONMetricSample[] metricHistory(string targetType, string targetId) {
        synchronized (_lock) {
            if (targetType == "application") {
                if (auto history = targetId in _applicationMetricHistory) {
                    return *history;
                }
            }
            if (targetType == "database") {
                if (auto history = targetId in _databaseMetricHistory) {
                    return *history;
                }
            }
            return [];
        }
    }

    MONAvailabilityCheck saveAvailabilityCheck(MONAvailabilityCheck check) {
        synchronized (_lock) {
            _availabilityChecks[check.checkId] = check;
            return check;
        }
    }

    MONJMXCheck saveJMXCheck(MONJMXCheck check) {
        synchronized (_lock) {
            _jmxChecks[check.checkId] = check;
            return check;
        }
    }

    MONCustomCheck saveCustomCheck(MONCustomCheck check) {
        synchronized (_lock) {
            _customChecks[check.checkId] = check;
            return check;
        }
    }

    MONAlertEmailChannel saveEmailChannel(MONAlertEmailChannel channel) {
        synchronized (_lock) {
            _emailChannel = channel;
            _hasEmailChannel = true;
            return _emailChannel;
        }
    }

    MONAlertWebhookChannel saveWebhookChannel(MONAlertWebhookChannel channel) {
        synchronized (_lock) {
            _webhookChannel = channel;
            _hasWebhookChannel = true;
            return _webhookChannel;
        }
    }

    bool hasEmailChannel() {
        synchronized (_lock) {
            return _hasEmailChannel;
        }
    }

    bool hasWebhookChannel() {
        synchronized (_lock) {
            return _hasWebhookChannel;
        }
    }

    MONAlertEmailChannel getEmailChannel() {
        synchronized (_lock) {
            return _emailChannel;
        }
    }

    MONAlertWebhookChannel getWebhookChannel() {
        synchronized (_lock) {
            return _webhookChannel;
        }
    }

    Json saveThresholdOverride(string checkName, Json thresholdConfig) {
        synchronized (_lock) {
            _thresholdOverrides[checkName] = thresholdConfig;
            return _thresholdOverrides[checkName];
        }
    }

    Json getThresholdOverride(string checkName) {
        synchronized (_lock) {
            if (auto threshold = checkName in _thresholdOverrides) {
                return *threshold;
            }
        }
        return Json.undefined;
    }

    private void trimHistory(ref MONMetricSample[] history) {
        enum maxHistory = 200;
        if (history.length <= maxHistory) {
            return;
        }
        auto offset = history.length - maxHistory;
        history = history[offset .. $];
    }
}
