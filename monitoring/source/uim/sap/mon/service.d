/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.mon.service;

import uim.sap.mon;

mixin(ShowModule!());

@safe:

class MONService : SAPService {
  private MONStore _store;

  this(MONConfig config) {
    super(config);

    _store = new MONStore;
  }

  Json fetchApplicationMetrics(string appId) {
    auto metrics = buildApplicationMetrics(appId);
    _store.appendApplicationMetrics(appId, metrics);

    return Json.emptyObject
      .set("target_type", "application")
      .set("target_id", appId)
      .set("metrics", toJsonArray(metrics));
  }

  Json fetchDatabaseMetrics(string databaseId) {
    auto metrics = buildDatabaseMetrics(databaseId);
    _store.appendDatabaseMetrics(databaseId, metrics);

    return Json.emptyObject
      .set("target_type", "database")
      .set("target_id", databaseId)
      .set("metrics", toJsonArray(metrics));
  }

  Json metricHistory(string targetType, string targetId) {
    auto normalizedType = toLower(targetType);
    if (normalizedType != "application" && normalizedType != "database") {
      throw new MONValidationException("target_type must be 'application' or 'database'");
    }

    auto history = _store.metricHistory(normalizedType, targetId);

    return Json.emptyObject
      .set("target_type", normalizedType)
      .set("target_id", targetId)
      .set("history", toJsonArray(history))
      .set("total_results", cast(long)history.length);
  }

  Json registerAvailabilityCheck(Json request) {
    auto targetType = getString(request, "target_type", "application");
    auto targetId = getString(request, "target_id");
    auto endpoint = getString(request, "endpoint");

    if (targetId.length == 0) {
      throw new MONValidationException("target_id is required");
    }
    if (endpoint.length == 0) {
      throw new MONValidationException("endpoint is required");
    }

    MONAvailabilityCheck check = new MONAvailabilityCheck();
    check.checkId = newCheckId("avail");
    check.targetType = targetType;
    check.targetId = targetId;
    check.endpoint = endpoint;
    check.intervalSeconds = getInt(request, "interval_seconds", 60);
    check.timeoutSeconds = getInt(request, "timeout_seconds", 5);
    check.expectedStatus = getInt(request, "expected_status", 200);
    check.enabled = getBoolean(request, "enabled", true);
    check.createdAt = Clock.currTime();

    auto saved = _store.saveAvailabilityCheck(check);

    return Json.emptyObject
      .set("success", true)
      .set("availability_check", saved.toJson());
  }

  Json setAlertEmailChannel(Json request) {
    if (!("recipients" in request) || !request["recipients"].isArray) {
      throw new MONValidationException("recipients (array) is required");
    }

    string[] recipients;
    foreach (entry; request["recipients"]) {
      if (entry.isString) {
        recipients ~= entry.getString;
      }
    }
    if (recipients.length == 0) {
      throw new MONValidationException("at least one email recipient is required");
    }

    MONAlertEmailChannel channel = new MONAlertEmailChannel();
    channel.enabled = getBoolean(request, "enabled", true);
    channel.recipients = recipients;
    channel.sender = getString(request, "sender", "noreply@uim.local");
    channel.subjectPrefix = getString(request, "subject_prefix", "[UIM-MON]");
    channel.updatedAt = Clock.currTime();

    auto saved = _store.saveEmailChannel(channel);

    return Json.emptyObject
      .set("success", true)
      .set("channel", saved.toJson());
  }

  Json setAlertWebhookChannel(Json request) {
    auto url = getString(request, "url");
    if (url.length == 0) {
      throw new MONValidationException("url is required");
    }

    MONAlertWebhookChannel channel = new MONAlertWebhookChannel();
    channel.enabled = getBoolean(request, "enabled", true);
    channel.url = url;
    channel.secret = getString(request, "secret", "");
    channel.method = getString(request, "method", "POST");
    channel.updatedAt = Clock.currTime();

    auto saved = _store.saveWebhookChannel(channel);

    return Json.emptyObject
      .set("success", true)
      .set("channel", saved.toJson());
  }

  Json configureJMXCheck(Json request) {
    auto targetId = getString(request, "target_id");
    auto mbean = getString(request, "mbean");
    auto attribute = getString(request, "attribute");

    if (targetId.length == 0) {
      throw new MONValidationException("target_id is required");
    }
    if (mbean.length == 0) {
      throw new MONValidationException("mbean is required");
    }
    if (attribute.length == 0) {
      throw new MONValidationException("attribute is required");
    }

    MONJMXCheck check = new MONJMXCheck();
    check.checkId = newCheckId("jmx");
    check.targetId = targetId;
    check.mbean = mbean;
    check.attribute = attribute;
    check.comparator = getString(request, "comparator", ">=");
    check.threshold = getDouble(request, "threshold", 0);
    check.enabled = getBoolean(request, "enabled", true);
    check.createdAt = Clock.currTime();

    auto saved = _store.saveJMXCheck(check);

    return Json.emptyObject
      .set("success", true)
      .set("jmx_check", saved.toJson());
  }

  Json performJMXOperation(Json request) {
    auto targetId = getString(request, "target_id");
    auto mbean = getString(request, "mbean");
    auto operation = getString(request, "operation");

    if (targetId.length == 0 || mbean.length == 0 || operation.length == 0) {
      throw new MONValidationException("target_id, mbean and operation are required");
    }

    return Json.emptyObject
      .set("success", true)
      .set("target_id", targetId)
      .set("mbean", mbean)
      .set("operation", operation)
      .set("status", "completed")
      .set("invoked_at", Clock.currTime().toISOExtString())
      .set("result", Json.emptyObject
          .set("message", "JMX operation executed")
          .set("return_code", 0)
          .set("simulated", true));
  }

  Json registerCustomCheck(Json request) {
    auto name = getString(request, "name");
    auto targetType = getString(request, "target_type", "application");
    auto targetId = getString(request, "target_id");
    auto endpoint = getString(request, "endpoint");

    if (name.length == 0) {
      throw new MONValidationException("name is required");
    }
    if (targetId.length == 0) {
      throw new MONValidationException("target_id is required");
    }
    if (endpoint.length == 0) {
      throw new MONValidationException("endpoint is required");
    }

    MONCustomCheck check = new MONCustomCheck();
    check.checkId = newCheckId("custom");
    check.name = name;
    check.targetType = targetType;
    check.targetId = targetId;
    check.endpoint = endpoint;
    check.method = getString(request, "method", "GET");
    check.expectedStatus = getInt(request, "expected_status", 200);
    check.createdAt = Clock.currTime();

    auto saved = _store.saveCustomCheck(check);

    return Json.emptyObject
      .set("success", true)
      .set("custom_check", saved.toJson());
  }

  Json overrideDefaultThreshold(string checkName, Json request) {
    if (!("thresholds" in request) || !request["thresholds"].isObject) {
      throw new MONValidationException("thresholds (object) is required");
    }

    auto thresholds = _store.saveThresholdOverride(checkName, request["thresholds"]);

    return Json.emptyObject
      .set("success", true)
      .set("check_name", checkName)
      .set("thresholds", thresholds)
      .set("updated_at", Clock.currTime().toISOExtString());
  }

  Json getAlertChannels() {
    Json payload = Json.emptyObject;
    payload["email"] = _store.hasEmailChannel() ? _store.getEmailChannel().toJson() : Json
      .undefined;
    payload["webhook"] = _store.hasWebhookChannel() ? _store.getWebhookChannel()
      .toJson() : Json.undefined;
    return payload;
  }

  Json getThresholdOverride(string checkName) {
    auto thresholds = _store.getThresholdOverride(checkName);
    if (thresholds.type == Json.Type.undefined) {
      throw new MONNotFoundException("Threshold override", checkName);
    }

    return Json.emptyObject
      .set("check_name", checkName)
      .set("thresholds", thresholds);
  }

  private MONMetricSample[] buildApplicationMetrics(string appId) {
    auto base = pulse(appId);
    return [
      metricSample("application", appId, "cpu.usage", 15 + fmod(base, 70), "%"),
      metricSample("application", appId, "memory.usage", 200 + fmod(base * 2, 3000), "MiB"),
      metricSample("application", appId, "request.latency.p95", 20 + fmod(base * 3, 600), "ms")
    ];
  }

  private MONMetricSample[] buildDatabaseMetrics(string databaseId) {
    auto base = pulse(databaseId);
    return [
      metricSample("database", databaseId, "db.connections.active", 10 + fmod(base, 350), "count"),
      metricSample("database", databaseId, "db.storage.used", 1024 + fmod(base * 4, 20_000), "MiB"),
      metricSample("database", databaseId, "db.response.time", 3 + fmod(base * 2, 250), "ms")
    ];
  }

  private double pulse(string source) {
    auto nowTick = cast(double)(Clock.currTime().stdTime % 1_000_000L);
    return nowTick + cast(double)(source.length * 131);
  }

  private string getString(Json request, string key, string fallback = "") {
    if (key in request && request[key].isString) {
      return request[key].getString;
    }
    return fallback;
  }

  private int getInt(Json request, string key, int fallback = 0) {
    if (key in request && request[key].isInteger) {
      return cast(int)request[key].get!long;
    }
    return fallback;
  }

  private double getDouble(Json request, string key, double fallback = 0) {
    if (key in request && request[key].isDouble) {
      return request[key].get!double;
    }
    if (key in request && request[key].isInteger) {
      return cast(double)request[key].get!long;
    }
    return fallback;
  }
}
