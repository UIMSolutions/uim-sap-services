/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.auditlog.service;

import uim.sap.auditlog;

mixin(ShowModule!());

@safe:

class AuditLogService : SAPService {
  mixin(SAPServiceTemplate!AuditLogService);

  private AuditLogStore _store;

  this(AuditLogConfig config) {
    super(config);

    _store = new AuditLogStore;
  }

  Json listRecommendedEventTypes() {
    Json resources = Json.emptyArray;
    foreach (eventType; AUDIT_LOG_RECOMMENDED_EVENT_TYPES) {
      resources ~= eventType;
    }
    Json result = Json.emptyObject;
    result["resources"] = resources;
    result["total_results"] = cast(long)resources.length;
    return result;
  }

  Json writeEvent(UUID tenantId, Json request) {
    validateId(tenantId, "Tenant ID");

    auto eventItem = eventFromJson(tenantId, request);
    if (eventItem.message.length == 0) {
      throw new AuditLogValidationException("message is required");
    }

    auto policy = ensurePolicy(tenantId);
    _store.purgeExpired(tenantId, policy.retentionDays);

    auto saved = _store.appendEvent(eventItem);

    AuditLogWriteResult writeResult;
    writeResult.success = true;
    writeResult.eventId = saved.eventId;
    writeResult.recommendedType = isRecommendedAuditEventType(saved.eventType);

    Json result = Json.emptyObject;
    result["success"] = true;
    result["write_result"] = writeResult.toJson();
    result["event"] = saved.toJson();
    return result;
  }

  Json listEvents(UUID tenantId) {
    validateId(tenantId, "Tenant ID");
    auto policy = ensurePolicy(tenantId);
    _store.purgeExpired(tenantId, policy.retentionDays);

    Json resources = Json.emptyArray;
    foreach (eventItem; _store.listEvents(tenantId)) {
      resources ~= eventItem.toJson();
    }

    Json result = Json.emptyObject;
    result["tenant_id"] = tenantId;
    result["retention_days"] = policy.retentionDays;
    result["resources"] = resources;
    result["total_results"] = cast(long)resources.length;
    return result;
  }

  Json retrieveEvents(UUID tenantId, Json request) {
    validateId(tenantId, "Tenant ID");

    auto policy = ensurePolicy(tenantId);
    _store.purgeExpired(tenantId, policy.retentionDays);

    int withinDays = policy.retentionDays;
    if ("within_days" in request && request["within_days"].isInteger) {
      auto candidate = cast(int)request["within_days"].get!long;
      if (candidate > 0 && candidate < withinDays) {
        withinDays = candidate;
      }
    }

    int limit = 200;
    if ("limit" in request && request["limit"].isInteger) {
      auto candidate = cast(int)request["limit"].get!long;
      if (candidate > 0 && candidate <= 5000) {
        limit = candidate;
      }
    }

    string eventTypeFilter;
    if ("event_type" in request && request["event_type"].isString) {
      eventTypeFilter = toLower(request["event_type"].get!string);
    }

    auto threshold = Clock.currTime() - dur!"days"(withinDays);
    AuditLogEvent[] filtered;
    foreach (eventItem; _store.listEvents(tenantId)) {
      if (eventItem.createdAt < threshold) {
        continue;
      }
      if (eventTypeFilter.length > 0 && eventItem.eventType != eventTypeFilter) {
        continue;
      }
      filtered ~= eventItem;
    }

    sort!((a, b) => a.createdAt > b.createdAt)(filtered);
    if (filtered.length > cast(size_t)limit) {
      filtered = filtered[0 .. limit];
    }

    Json preview = Json.emptyArray;
    foreach (eventItem; filtered) {
      preview ~= eventItem.toJson();
    }

    bool download = false;
    if ("download" in request && request["download"].isBoolean) {
      download = request["download"].get!bool;
    }

    Json result = Json.emptyObject;
    result["tenant_id"] = tenantId;
    result["within_days"] = withinDays;
    result["retention_days"] = policy.retentionDays;
    result["resources"] = preview;
    result["total_results"] = cast(long)preview.length;
    result["download_ready"] = download;
    if (download) {
      result["download_format"] = "csv";
      result["download_content"] = toCsv(filtered);
    }
    return result;
  }

  Json viewer(UUID tenantId) {
    validateId(tenantId, "Tenant ID");
    auto policy = ensurePolicy(tenantId);
    _store.purgeExpired(tenantId, policy.retentionDays);

    auto events = _store.listEvents(tenantId);
    sort!((a, b) => a.createdAt > b.createdAt)(events);

    Json latest = Json.emptyArray;
    long maxItems = 100;
    long i = 0;
    foreach (eventItem; events) {
      if (i >= maxItems) {
        break;
      }
      latest ~= eventItem.toJson();
      ++i;
    }

    long recommendedCount = 0;
    long customCount = 0;
    foreach (eventItem; events) {
      if (isRecommendedAuditEventType(eventItem.eventType)) {
        ++recommendedCount;
      } else {
        ++customCount;
      }
    }

    Json result = Json.emptyObject;
    result["tenant_id"] = tenantId;
    result["plan"] = policy.plan;
    result["retention_days"] = policy.retentionDays;
    result["total_events"] = cast(long)events.length;
    result["recommended_events"] = recommendedCount;
    result["custom_events"] = customCount;
    result["latest_events"] = latest;
    return result;
  }

  Json getRetentionPolicy(UUID tenantId) {
    validateId(tenantId, "Tenant ID");
    auto policy = ensurePolicy(tenantId);
    Json result = Json.emptyObject;
    result["retention_policy"] = policy.toJson();
    return result;
  }

  Json updateRetentionPolicy(UUID tenantId, Json request) {
    validateId(tenantId, "Tenant ID");
    auto policy = ensurePolicy(tenantId);

    int nextDays = policy.retentionDays;
    if ("retention_days" in request && request["retention_days"].isInteger) {
      nextDays = cast(int)request["retention_days"].get!long;
    }
    if (nextDays <= 0) {
      throw new AuditLogValidationException("retention_days must be greater than zero");
    }

    auto nextPlan = policy.plan;
    if ("plan" in request && request["plan"].isString) {
      nextPlan = toLower(request["plan"].get!string);
    }
    if (nextPlan != "default" && nextPlan != "premium") {
      throw new AuditLogValidationException("plan must be 'default' or 'premium'");
    }

    if (nextPlan == "default" && nextDays > 90) {
      throw new AuditLogValidationException("retention above 90 days requires premium plan");
    }

    policy.plan = nextPlan;
    policy.retentionDays = nextDays;
    policy.updatedAt = Clock.currTime();

    if ("premium_cost_per_1000_events" in request
      && request["premium_cost_per_1000_events"].isFloat) {
      policy.premiumCostPerThousandEvents = request["premium_cost_per_1000_events"].get!double;
    }

    auto saved = _store.upsertPolicy(policy);
    _store.purgeExpired(tenantId, saved.retentionDays);

    Json result = Json.emptyObject;
    result["success"] = true;
    result["retention_policy"] = saved.toJson();
    return result;
  }

  Json usageAndCost(UUID tenantId) {
    validateId(tenantId, "Tenant ID");
    auto policy = ensurePolicy(tenantId);
    _store.purgeExpired(tenantId, policy.retentionDays);

    auto events = _store.listEvents(tenantId);
    long total = cast(long)events.length;
    double estimatedCost = 0.0;
    if (policy.plan == "premium") {
      estimatedCost = (cast(double)total / 1000.0) * policy.premiumCostPerThousandEvents;
    }

    Json result = Json.emptyObject;
    result["tenant_id"] = tenantId;
    result["plan"] = policy.plan;
    result["retention_days"] = policy.retentionDays;
    result["events_in_retention"] = total;
    result["estimated_premium_cost"] = estimatedCost;
    result["cost_currency"] = "USD";
    return result;
  }

  private AuditLogRetentionPolicy ensurePolicy(UUID tenantId) {
    auto cfg = cast(AuditLogConfig)config;

    auto policy = _store.getPolicy(tenantId);
    if (policy.tenantId.length == 0) {
      policy.tenantId = UUID(tenantId);
      policy.retentionDays = cfg.defaultRetentionDays;
      policy.plan = toLower(cfg.defaultPlan);
      policy.premiumCostPerThousandEvents = cfg.premiumCostPerThousandEvents;
      policy.updatedAt = Clock.currTime();
      policy = _store.upsertPolicy(policy);
    }
    return policy;
  }
}