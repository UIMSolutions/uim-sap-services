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

    Json payload = Json.emptyObject;
    payload["target_type"] = "application";
    payload["target_id"] = appId;
    payload["metrics"] = toJsonArray(metrics);
    return payload;
  }

  Json fetchDatabaseMetrics(string databaseId) {
    auto metrics = buildDatabaseMetrics(databaseId);
    _store.appendDatabaseMetrics(databaseId, metrics);

    Json payload = Json.emptyObject;
    payload["target_type"] = "database";
    payload["target_id"] = databaseId;
    payload["metrics"] = toJsonArray(metrics);
    return payload;
  }

  Json metricHistory(string targetType, string targetId) {
    auto normalizedType = toLower(targetType);
    if (normalizedType != "application" && normalizedType != "database") {
      throw new MONValidationException("target_type must be 'application' or 'database'");
    }

    auto history = _store.metricHistory(normalizedType, targetId);

    Json payload = Json.emptyObject;
    payload["target_type"] = normalizedType;
    payload["target_id"] = targetId;
    payload["history"] = toJsonArray(history);
    payload["total_results"] = cast(long)history.length;
    return payload;
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

    MONAvailabilityCheck check;
    check.checkId = newCheckId("avail");
    check.targetType = targetType;
    check.targetId = targetId;
    check.endpoint = endpoint;
    check.intervalSeconds = getInt(request, "interval_seconds", 60);
    check.timeoutSeconds = getInt(request, "timeout_seconds", 5);
    check.expectedStatus = getInt(request, "expected_status", 200);
    check.enabled = getBool(request, "enabled", true);
    check.createdAt = Clock.currTime();

    auto saved = _store.saveAvailabilityCheck(check);

    Json payload = Json.emptyObject;
    payload["success"] = true;
    payload["availability_check"] = saved.toJson();
    return payload;
  }

  Json setAlertEmailChannel(Json request) {
    if (!("recipients" in request) || !request["recipients"].isArray) {
      throw new MONValidationException("recipients (array) is required");
    }

    string[] recipients;
    foreach (entry; request["recipients"]) {
      if (entry.isString) {
        recipients ~= entry.get!string;
      }
    }
    if (recipients.length == 0) {
      throw new MONValidationException("at least one email recipient is required");
    }

    MONAlertEmailChannel channel;
    channel.enabled = getBool(request, "enabled", true);
    channel.recipients = recipients;
    channel.sender = getString(request, "sender", "noreply@uim.local");
    channel.subjectPrefix = getString(request, "subject_prefix", "[UIM-MON]");
    channel.updatedAt = Clock.currTime();

    auto saved = _store.saveEmailChannel(channel);

    Json payload = Json.emptyObject;
    payload["success"] = true;
    payload["channel"] = saved.toJson();
    return payload;
  }

  Json setAlertWebhookChannel(Json request) {
    auto url = getString(request, "url");
    if (url.length == 0) {
      throw new MONValidationException("url is required");
    }

    MONAlertWebhookChannel channel;
    channel.enabled = getBool(request, "enabled", true);
    channel.url = url;
    channel.secret = getString(request, "secret", "");
    channel.method = getString(request, "method", "POST");
    channel.updatedAt = Clock.currTime();

    auto saved = _store.saveWebhookChannel(channel);

    Json payload = Json.emptyObject;
    payload["success"] = true;
    payload["channel"] = saved.toJson();
    return payload;
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

    MONJMXCheck check;
    check.checkId = newCheckId("jmx");
    check.targetId = targetId;
    check.mbean = mbean;
    check.attribute = attribute;
    check.comparator = getString(request, "comparator", ">=");
    check.threshold = getDouble(request, "threshold", 0);
    check.enabled = getBool(request, "enabled", true);
    check.createdAt = Clock.currTime();

    auto saved = _store.saveJMXCheck(check);

    Json payload = Json.emptyObject;
    payload["success"] = true;
    payload["jmx_check"] = saved.toJson();
    return payload;
  }

  Json performJMXOperation(Json request) {
    auto targetId = getString(request, "target_id");
    auto mbean = getString(request, "mbean");
    auto operation = getString(request, "operation");

    if (targetId.length == 0 || mbean.length == 0 || operation.length == 0) {
      throw new MONValidationException("target_id, mbean and operation are required");
    }

    Json payload = Json.emptyObject;
    payload["success"] = true;
    payload["target_id"] = targetId;
    payload["mbean"] = mbean;
    payload["operation"] = operation;
    payload["status"] = "completed";
    payload["invoked_at"] = Clock.currTime().toISOExtString();

    Json result = Json.emptyObject;
    result["message"] = "JMX operation executed";
    result["return_code"] = 0;
    result["simulated"] = true;
    payload["result"] = result;
    return payload;
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

    MONCustomCheck check;
    check.checkId = newCheckId("custom");
    check.name = name;
    check.targetType = targetType;
    check.targetId = targetId;
    check.endpoint = endpoint;
    check.method = getString(request, "method", "GET");
    check.expectedStatus = getInt(request, "expected_status", 200);
    check.createdAt = Clock.currTime();

    auto saved = _store.saveCustomCheck(check);

    Json payload = Json.emptyObject;
    payload["success"] = true;
    payload["custom_check"] = saved.toJson();
    return payload;
  }

  Json overrideDefaultThreshold(string checkName, Json request) {
    if (!("thresholds" in request) || !request["thresholds"].isObject) {
      throw new MONValidationException("thresholds (object) is required");
    }

    auto thresholds = _store.saveThresholdOverride(checkName, request["thresholds"]);

    Json payload = Json.emptyObject;
    payload["success"] = true;
    payload["check_name"] = checkName;
    payload["thresholds"] = thresholds;
    payload["updated_at"] = Clock.currTime().toISOExtString();
    return payload;
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

    Json payload = Json.emptyObject;
    payload["check_name"] = checkName;
    payload["thresholds"] = thresholds;
    return payload;
  }

  private Json toJsonArray(MONMetricSample[] metrics) {
    Json payload = Json.emptyArray;
    foreach (item; metrics) {
      payload ~= item.toJson();
    }
    return payload;
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
      return request[key].get!string;
    }
    return fallback;
  }

  private int getInt(Json request, string key, int fallback = 0) {
    if (key in request && request[key].isInteger) {
      return cast(int)request[key].get!long;
    }
    return fallback;
  }

  private bool getBool(Json request, string key, bool fallback = false) {
    if (key in request && request[key].isBoolean) {
      return request[key].get!bool;
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
