/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.aas.service;

import uim.sap.aas;
@safe:

class AASService {
    private AASConfig _config;
    private AASStore _store;

    this(AASConfig config) {
        config.validate();
        _config = config;
        _store = new AASStore;
    }

    @property const(AASConfig) config() const {
        return _config;
    }

    Json health() {
        Json payload = Json.emptyObject;
        payload["ok"] = true;
        payload["serviceName"] = _config.serviceName;
        payload["serviceVersion"] = _config.serviceVersion;
        payload["apps"] = cast(long)_store.listApps().length;
        return payload;
    }

    Json ready() {
        Json payload = Json.emptyObject;
        payload["ready"] = true;
        return payload;
    }

    Json registerApp(Json request) {
        auto app = appFromJson(request);
        if (app.name.length == 0) {
            throw new AASValidationException("name is required");
        }
        if (app.organization.length == 0) {
            app.organization = _config.cfOrganization.length > 0 ? _config.cfOrganization : "default-org";
        }
        if (app.space.length == 0) {
            app.space = _config.cfSpace.length > 0 ? _config.cfSpace : "default-space";
        }
        if (app.minInstances > app.maxInstances) {
            throw new AASValidationException("min_instances cannot be greater than max_instances");
        }

        auto created = _store.createApp(app);
        return created.toJson();
    }

    Json listApps() {
        Json payload = Json.emptyObject;
        Json resources = Json.emptyArray;
        foreach (app; _store.listApps()) {
            resources ~= app.toJson();
        }
        payload["resources"] = resources;
        payload["total_results"] = cast(long)_store.listApps().length;
        return payload;
    }

    Json getApp(string appId) {
        auto app = _store.getApp(appId);
        if (app.id.length == 0) {
            throw new AASNotFoundException("app", appId);
        }
        return app.toJson();
    }

    Json createPolicy(string appId, Json request) {
        ensureAppExists(appId);
        auto policy = policyFromJson(request, appId);

        if (policy.scaleOutThreshold <= policy.scaleInThreshold) {
            throw new AASValidationException("scale_out_threshold must be greater than scale_in_threshold");
        }

        if (policy.metricType == AASMetricType.custom && policy.customMetricName.length == 0) {
            throw new AASValidationException("custom_metric_name is required for custom metric_type");
        }

        if (policy.maxInstances > 0 && policy.minInstances > policy.maxInstances) {
            throw new AASValidationException("policy min_instances cannot be greater than policy max_instances");
        }

        auto created = _store.createPolicy(policy);
        return created.toJson();
    }

    Json listPolicies(string appId) {
        ensureAppExists(appId);

        Json payload = Json.emptyObject;
        Json resources = Json.emptyArray;
        foreach (policy; _store.listPolicies(appId)) {
            resources ~= policy.toJson();
        }
        payload["resources"] = resources;
        payload["total_results"] = cast(long)_store.listPolicies(appId).length;
        return payload;
    }

    Json evaluate(string appId, Json request, bool applyDecision) {
        auto app = _store.getApp(appId);
        if (app.id.length == 0) {
            throw new AASNotFoundException("app", appId);
        }

        auto policies = _store.listPolicies(appId);
        if (policies.length == 0) {
            throw new AASValidationException("no policies defined for app");
        }

        auto snapshot = metricsFromJson(request);

        uint desiredUp = app.currentInstances;
        uint desiredDown = app.currentInstances;
        string outReasons;
        string inReasons;
        bool anyOut = false;
        bool anyIn = false;

        foreach (policy; policies) {
            auto metric = resolveMetric(policy, snapshot);
            if (isNaN(metric)) {
                continue;
            }

            auto lowerBound = policy.minInstances > 0 ? max(app.minInstances, policy.minInstances) : app.minInstances;
            auto upperBound = policy.maxInstances > 0 ? min(app.maxInstances, policy.maxInstances) : app.maxInstances;

            if (metric >= policy.scaleOutThreshold) {
                anyOut = true;
                auto candidate = min(upperBound, app.currentInstances + policy.scaleOutStep);
                desiredUp = max(desiredUp, candidate);
                if (outReasons.length > 0) {
                    outReasons ~= "; ";
                }
                outReasons ~= metricTypeToString(policy.metricType)
                    ~ "=" ~ metric.to!string
                    ~ " >= " ~ policy.scaleOutThreshold.to!string;
            } else if (metric <= policy.scaleInThreshold) {
                anyIn = true;
                uint candidate = app.currentInstances > policy.scaleInStep
                    ? app.currentInstances - policy.scaleInStep
                    : 0;
                candidate = max(lowerBound, candidate);
                desiredDown = min(desiredDown, candidate);
                if (inReasons.length > 0) {
                    inReasons ~= "; ";
                }
                inReasons ~= metricTypeToString(policy.metricType)
                    ~ "=" ~ metric.to!string
                    ~ " <= " ~ policy.scaleInThreshold.to!string;
            }
        }

        AASScaleDecision decision;
        decision.appId = app.id;
        decision.currentInstances = app.currentInstances;
        decision.evaluatedAt = Clock.currTime();
        decision.currentHourlyCost = app.instanceHourlyCost * app.currentInstances;

        if (anyOut) {
            decision.desiredInstances = desiredUp;
            decision.direction = decision.desiredInstances > app.currentInstances ? "scale_out" : "hold";
            decision.reason = outReasons.length > 0 ? outReasons : "scale out conditions met";
        } else if (anyIn) {
            decision.desiredInstances = desiredDown;
            decision.direction = decision.desiredInstances < app.currentInstances ? "scale_in" : "hold";
            decision.reason = inReasons.length > 0 ? inReasons : "scale in conditions met";
        } else {
            decision.desiredInstances = app.currentInstances;
            decision.direction = "hold";
            decision.reason = "All metrics in target range";
        }

        decision.desiredInstances = min(max(decision.desiredInstances, app.minInstances), app.maxInstances);
        decision.desiredHourlyCost = app.instanceHourlyCost * decision.desiredInstances;

        if (applyDecision && decision.desiredInstances != app.currentInstances) {
            auto updated = _store.updateAppInstances(appId, decision.desiredInstances);
            if (updated.id.length == 0) {
                throw new AASNotFoundException("app", appId);
            }
        }

        Json payload = Json.emptyObject;
        payload["decision"] = decision.toJson();
        payload["applied"] = applyDecision;
        payload["metrics"] = snapshot.toJson();
        payload["cost_savings_per_hour"] = decision.currentHourlyCost - decision.desiredHourlyCost;
        return payload;
    }

    Json triggerCFScale(string appId, Json request) {
        auto app = _store.getApp(appId);
        if (app.id.length == 0) {
            throw new AASNotFoundException("app", appId);
        }

        uint desired = app.currentInstances;
        if ("desired_instances" in request) {
            try {
                desired = cast(uint)request["desired_instances"].get!long;
            } catch (Exception) {
            }
        }

        desired = min(max(desired, app.minInstances), app.maxInstances);
        auto updated = _store.updateAppInstances(appId, desired);

        Json payload = Json.emptyObject;
        payload["success"] = true;
        payload["provider"] = "cloud_foundry";
        payload["cf_api"] = _config.cfApi;
        payload["organization"] = app.organization;
        payload["space"] = app.space;
        payload["message"] = "Scale request accepted (CF adapter placeholder)";
        payload["app"] = updated.toJson();
        return payload;
    }

    private void ensureAppExists(string appId) {
        if (!_store.hasApp(appId)) {
            throw new AASNotFoundException("app", appId);
        }
    }

    private double resolveMetric(AASScalingPolicy policy, AASMetricSnapshot snapshot) {
        final switch (policy.metricType) {
            case AASMetricType.cpu:
                return snapshot.cpuPercent;
            case AASMetricType.memory:
                return snapshot.memoryPercent;
            case AASMetricType.responseTime:
                return snapshot.responseTimeMs;
            case AASMetricType.throughput:
                return snapshot.throughputRps;
            case AASMetricType.custom:
                if (auto ptr = policy.customMetricName in snapshot.custom) {
                    return *ptr;
                }
                return double.nan;
        }
    }
}
