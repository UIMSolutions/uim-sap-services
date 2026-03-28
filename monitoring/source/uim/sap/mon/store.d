/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.mon.store;

import core.sync.mutex : Mutex;

import uim.sap.mon;

mixin(ShowModule!());

@safe:

class MONStore : SAPStore {
  mixin(SAPStore!MONStore);

  protected MONMetricSample[][UUID] _applicationMetricHistory;
  protected MONMetricSample[][UUID] _databaseMetricHistory;
  protected MONAvailabilityCheck[UUID] _availabilityChecks;
  protected MONJMXCheck[UUID] _jmxChecks;
  protected MONCustomCheck[UUID] _customChecks;
  protected Json[UUID] _thresholdOverrides;
  protected MONAlertEmailChannel _emailChannel;
  protected MONAlertWebhookChannel _webhookChannel;
  protected bool _hasEmailChannel = false;
  protected bool _hasWebhookChannel = false;

  // Application Metrics
  // Database Metrics
  // Availability Checks
  // JMX Checks
  // Custom Checks
  // Alert Channels
  // Threshold Overrides  

  /**
    * Appends a new metric sample for a specific application.
    * @param appId The unique identifier of the application.
    * @param metric The metric sample to append.
    * @return The appended metric sample.
    *
    * This method ensures thread-safe access to the application metric history by synchronizing on a mutex.
    * It adds the new metric sample to the history for the specified application and trims the history to maintain a maximum size.
    *
    * Example usage:
    * MONMetricSample sample = new MONMetricSample(...);
    * store.appendApplicationMetric(appId, sample);
    */
  MONMetricSample appendApplicationMetric(UUID appId, MONMetricSample metric) {
    synchronized (_lock) {
      _applicationMetricHistory[appId] ~= metric;
      trimHistory(_applicationMetricHistory[appId]);
      return metric;
    }
  }

  /** 
    * Appends multiple metric samples for a specific application.
    * @param appId The unique identifier of the application.
    * @param metrics The array of metric samples to append.
    * @return The appended metric samples.
    *
    * This method ensures thread-safe access to the application metric history by synchronizing on a mutex.
    * It adds the new metric samples to the history for the specified application and trims the history to maintain a maximum size.
    *
    * Example usage:
    * MONMetricSample[] samples = [new MONMetricSample(...), new MONMetricSample(...)];
    * store.appendApplicationMetrics(appId, samples);
    */
  MONMetricSample[] appendApplicationMetrics(UUID appId, MONMetricSample[] metrics) {
    synchronized (_lock) {
      foreach (item; metrics) {
        _applicationMetricHistory[appId] ~= item;
      }
      trimHistory(_applicationMetricHistory[appId]);
      return metrics;
    }
  }

  /**
    * Appends a new metric sample for a specific database.
    * @param databaseId The unique identifier of the database.
    * @param metric The metric sample to append.
    * @return The appended metric sample.
    *
    * This method ensures thread-safe access to the database metric history by synchronizing on a mutex.
    * It adds the new metric sample to the history for the specified database and trims the history to maintain a maximum size.
    *
    * Example usage:
    * MONMetricSample sample = new MONMetricSample(...);
    * store.appendDatabaseMetric(databaseId, sample);
    */
  MONMetricSample appendDatabaseMetric(UUID databaseId, MONMetricSample metric) {
    synchronized (_lock) {
      _databaseMetricHistory[databaseId] ~= metric;
      trimHistory(_databaseMetricHistory[databaseId]);
      return metric;
    }
  }

  MONMetricSample[] appendDatabaseMetrics(UUID databaseId, MONMetricSample[] metrics) {
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
        if (targetId in _applicationMetricHistory) {
          return _applicationMetricHistory[targetId];
        }
      }
      if (targetType == "database") {
        if (targetId in _databaseMetricHistory) {
          return _databaseMetricHistory[targetId];
        }
      }
      return null;
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
      if (checkName in _thresholdOverrides) {
        return _thresholdOverrides[checkName];
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
