module uim.sap.auditlog.service;

import std.algorithm.sorting : sort;
import std.datetime : Clock, dur;
import std.string : toLower;

import vibe.data.json : Json;

import uim.sap.auditlog.config;
import uim.sap.auditlog.exceptions;
import uim.sap.auditlog.models;
import uim.sap.auditlog.store;

class AuditLogService {
    private AuditLogConfig _config;
    private AuditLogStore _store;

    this(AuditLogConfig config) {
        config.validate();
        _config = config;
        _store = new AuditLogStore;
    }

    @property const(AuditLogConfig) config() const {
        return _config;
    }

    Json health() {
        Json result = Json.emptyObject;
        result["ok"] = true;
        result["serviceName"] = _config.serviceName;
        result["serviceVersion"] = _config.serviceVersion;
        return result;
    }

    Json ready() {
        Json result = Json.emptyObject;
        result["ready"] = true;
        result["timestamp"] = Clock.currTime().toISOExtString();
        return result;
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

    Json writeEvent(string tenantId, Json request) {
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

    Json listEvents(string tenantId) {
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

    Json retrieveEvents(string tenantId, Json request) {
        validateId(tenantId, "Tenant ID");

        auto policy = ensurePolicy(tenantId);
        _store.purgeExpired(tenantId, policy.retentionDays);

        int withinDays = policy.retentionDays;
        if ("within_days" in request && request["within_days"].type == Json.Type.int_) {
            auto candidate = cast(int)request["within_days"].get!long;
            if (candidate > 0 && candidate < withinDays) {
                withinDays = candidate;
            }
        }

        int limit = 200;
        if ("limit" in request && request["limit"].type == Json.Type.int_) {
            auto candidate = cast(int)request["limit"].get!long;
            if (candidate > 0 && candidate <= 5000) {
                limit = candidate;
            }
        }

        string eventTypeFilter;
        if ("event_type" in request && request["event_type"].type == Json.Type.string) {
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
        if ("download" in request && request["download"].type == Json.Type.bool_) {
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

    Json viewer(string tenantId) {
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

    Json getRetentionPolicy(string tenantId) {
        validateId(tenantId, "Tenant ID");
        auto policy = ensurePolicy(tenantId);
        Json result = Json.emptyObject;
        result["retention_policy"] = policy.toJson();
        return result;
    }

    Json updateRetentionPolicy(string tenantId, Json request) {
        validateId(tenantId, "Tenant ID");
        auto policy = ensurePolicy(tenantId);

        int nextDays = policy.retentionDays;
        if ("retention_days" in request && request["retention_days"].type == Json.Type.int_) {
            nextDays = cast(int)request["retention_days"].get!long;
        }
        if (nextDays <= 0) {
            throw new AuditLogValidationException("retention_days must be greater than zero");
        }

        auto nextPlan = policy.plan;
        if ("plan" in request && request["plan"].type == Json.Type.string) {
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
            && request["premium_cost_per_1000_events"].type == Json.Type.float_) {
            policy.premiumCostPerThousandEvents = request["premium_cost_per_1000_events"].get!double;
        }

        auto saved = _store.upsertPolicy(policy);
        _store.purgeExpired(tenantId, saved.retentionDays);

        Json result = Json.emptyObject;
        result["success"] = true;
        result["retention_policy"] = saved.toJson();
        return result;
    }

    Json usageAndCost(string tenantId) {
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

    private AuditLogRetentionPolicy ensurePolicy(string tenantId) {
        auto policy = _store.getPolicy(tenantId);
        if (policy.tenantId.length == 0) {
            policy.tenantId = tenantId;
            policy.retentionDays = _config.defaultRetentionDays;
            policy.plan = toLower(_config.defaultPlan);
            policy.premiumCostPerThousandEvents = _config.premiumCostPerThousandEvents;
            policy.updatedAt = Clock.currTime();
            policy = _store.upsertPolicy(policy);
        }
        return policy;
    }

    private void validateId(string value, string fieldName) {
        if (value.length == 0) {
            throw new AuditLogValidationException(fieldName ~ " cannot be empty");
        }
    }
}
