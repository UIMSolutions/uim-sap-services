module uim.sap.isa.service;

import std.algorithm.comparison : max;
import std.conv : to;
import std.datetime : Clock;
import std.uuid : randomUUID;

import vibe.data.json : Json;

import uim.sap.isa.config;
import uim.sap.isa.exceptions;
import uim.sap.isa.models;
import uim.sap.isa.store;

class ISAService : SAPService {
    private ISAConfig _config;
    private ISAStore _store;

    this(ISAConfig config) {
        config.validate();
        _config = config;
        _store = new ISAStore;
        _store.seed(_config.defaultTenant);
    }

    @property const(ISAConfig) config() const {
        return _config;
    }

    Json health() {
        Json payload = Json.emptyObject;
        payload["ok"] = true;
        payload["service_name"] = _config.serviceName;
        payload["service_version"] = _config.serviceVersion;
        payload["default_tenant"] = _config.defaultTenant;
        return payload;
    }

    Json ready() {
        Json payload = Json.emptyObject;
        payload["ready"] = true;
        return payload;
    }

    Json createConfiguration(string tenantId, Json request) {
        auto cfg = configFromJson(request, tenantId);
        validateConfiguration(cfg);
        auto created = _store.createConfiguration(cfg);
        return created.toJson();
    }

    Json updateConfiguration(string tenantId, string configId, Json request) {
        auto existing = _store.getConfiguration(configId);
        if (existing.id.length == 0 || existing.tenantId != tenantId) {
            throw new ISANotFoundException("configuration", configId);
        }

        auto updated = updateConfigFromJson(existing, request);
        validateConfiguration(updated);

        auto saved = _store.updateConfiguration(configId, updated);
        if (saved.id.length == 0) {
            throw new ISANotFoundException("configuration", configId);
        }

        return saved.toJson();
    }

    Json deleteConfiguration(string tenantId, string configId) {
        auto existing = _store.getConfiguration(configId);
        if (existing.id.length == 0 || existing.tenantId != tenantId) {
            throw new ISANotFoundException("configuration", configId);
        }

        if (!_store.deleteConfiguration(configId)) {
            throw new ISAException("could not delete configuration");
        }

        Json payload = Json.emptyObject;
        payload["success"] = true;
        payload["deleted_id"] = configId;
        return payload;
    }

    Json getConfiguration(string tenantId, string configId) {
        auto cfg = _store.getConfiguration(configId);
        if (cfg.id.length == 0 || cfg.tenantId != tenantId) {
            throw new ISANotFoundException("configuration", configId);
        }
        return cfg.toJson();
    }

    Json listConfigurations(string tenantId) {
        Json payload = Json.emptyObject;
        Json resources = Json.emptyArray;

        auto configs = _store.listConfigurations(tenantId);
        foreach (cfg; configs) {
            resources ~= cfg.toJson();
        }

        payload["resources"] = resources;
        payload["total_results"] = cast(long)configs.length;
        return payload;
    }

    Json createSituation(string tenantId, Json request) {
        auto instance = situationFromJson(request, tenantId);

        if (instance.situationType.length == 0) {
            throw new ISAValidationException("situation_type is required");
        }
        if (instance.templateId.length == 0) {
            throw new ISAValidationException("template_id is required");
        }

        auto created = _store.createSituation(instance);
        return created.toJson();
    }

    Json listSituations(string tenantId) {
        Json payload = Json.emptyObject;
        Json resources = Json.emptyArray;

        auto situations = _store.listSituations(tenantId);
        foreach (entry; situations) {
            resources ~= entry.toJson();
        }

        payload["resources"] = resources;
        payload["total_results"] = cast(long)situations.length;
        return payload;
    }

    Json dashboard(string tenantId) {
        auto situations = _store.listSituations(tenantId);
        auto configs = _store.listConfigurations(tenantId);

        long autoResolvedCount = 0;
        long manuallyResolvedCount = 0;
        long openCount = 0;
        double timeSavedMinutes = 0;

        foreach (entry; situations) {
            final switch (entry.status) {
                case SituationStatus.autoResolved:
                    autoResolvedCount++;
                    timeSavedMinutes += estimatedSavedMinutes(configs, entry.situationType);
                    break;
                case SituationStatus.resolved:
                    manuallyResolvedCount++;
                    break;
                case SituationStatus.open:
                    openCount++;
                    break;
            }
        }

        Json suggestions = Json.emptyArray;
        foreach (suggestion; automationSuggestions(tenantId)) {
            suggestions ~= suggestion;
        }

        Json payload = Json.emptyObject;
        payload["tenant_id"] = tenantId;
        payload["total_situations"] = cast(long)situations.length;
        payload["auto_resolved"] = autoResolvedCount;
        payload["manual_resolved"] = manuallyResolvedCount;
        payload["open"] = openCount;
        payload["time_saved_minutes"] = timeSavedMinutes;
        payload["time_saved_hours"] = timeSavedMinutes / 60.0;
        payload["automation_suggestions"] = suggestions;
        return payload;
    }

    Json analyzeSituations(string tenantId, string situationType) {
        auto situations = _store.listSituations(tenantId);

        long[string] byType;
        foreach (entry; situations) {
            byType[entry.situationType] = byType.get(entry.situationType, 0) + 1;
        }

        Json counts = Json.emptyArray;
        foreach (key, value; byType) {
            Json item = Json.emptyObject;
            item["situation_type"] = key;
            item["count"] = value;
            counts ~= item;
        }

        Json details = Json.emptyObject;
        if (situationType.length > 0) {
            Json filtered = Json.emptyArray;
            Json flows = Json.emptyObject;

            foreach (entry; situations) {
                if (entry.situationType != situationType) {
                    continue;
                }
                filtered ~= entry.toJson();
                long current = 0;
                if (entry.resolutionFlow in flows) {
                    current = flows[entry.resolutionFlow].get!long;
                }
                flows[entry.resolutionFlow] = current + 1;
            }

            details["situation_type"] = situationType;
            details["instances"] = filtered;
            details["resolution_flows"] = flows;
            details["data_context_example"] = filtered.length > 0 ? filtered[0]["data_context"] : Json.emptyObject;
        }

        Json payload = Json.emptyObject;
        payload["tenant_id"] = tenantId;
        payload["counts_by_type"] = counts;
        payload["details"] = details;
        return payload;
    }

    Json exploreRelatedSituations(string tenantId) {
        auto situations = _store.listSituations(tenantId);
        auto reports = _store.listReports(tenantId);

        long[string] entityTypeCounts;
        string[][string] templatesByEntity;
        Json relationships = Json.emptyArray;

        foreach (entry; situations) {
            entityTypeCounts[entry.entityType] = entityTypeCounts.get(entry.entityType, 0) + 1;
            templatesByEntity[entry.entityType] ~= entry.templateId;

            Json edge = Json.emptyObject;
            edge["entity_type"] = entry.entityType;
            edge["entity_id"] = entry.entityId;
            edge["situation_type"] = entry.situationType;
            edge["template_id"] = entry.templateId;
            relationships ~= edge;
        }

        Json topEntityTypes = Json.emptyArray;
        foreach (entityType, count; entityTypeCounts) {
            Json item = Json.emptyObject;
            item["entity_type"] = entityType;
            item["count"] = count;

            Json templates = Json.emptyArray;
            foreach (templateId; templatesByEntity[entityType]) {
                templates ~= templateId;
            }
            item["templates"] = templates;
            topEntityTypes ~= item;
        }

        Json reportItems = Json.emptyArray;
        foreach (report; reports) {
            reportItems ~= report.toJson();
        }

        Json payload = Json.emptyObject;
        payload["tenant_id"] = tenantId;
        payload["top_entity_types"] = topEntityTypes;
        payload["relationships"] = relationships;
        payload["data_context_reports"] = reportItems;
        return payload;
    }

    Json contextReports(string tenantId) {
        Json payload = Json.emptyObject;
        Json resources = Json.emptyArray;

        foreach (report; _store.listReports(tenantId)) {
            resources ~= report.toJson();
        }

        payload["resources"] = resources;
        payload["total_results"] = cast(long)resources.length;
        return payload;
    }

    private void validateConfiguration(AutomationConfiguration cfg) {
        if (cfg.name.length == 0) {
            throw new ISAValidationException("name is required");
        }
        if (cfg.situationType.length == 0) {
            throw new ISAValidationException("situation_type is required");
        }
        if (cfg.businessRules.length == 0) {
            throw new ISAValidationException("at least one business rule is required");
        }
    }

    private double estimatedSavedMinutes(AutomationConfiguration[] configs, string situationType) {
        foreach (cfg; configs) {
            if (cfg.situationType == situationType && cfg.enabled) {
                return cfg.avgManualMinutes * cfg.autoResolutionRate;
            }
        }
        return 3.0;
    }

    private Json[] automationSuggestions(string tenantId) {
        auto situations = _store.listSituations(tenantId);
        auto configs = _store.listConfigurations(tenantId);

        long[string] frequency;
        foreach (entry; situations) {
            if (entry.status == SituationStatus.autoResolved) {
                continue;
            }
            frequency[entry.situationType] = frequency.get(entry.situationType, 0) + 1;
        }

        Json[] suggestions;
        foreach (situationType, count; frequency) {
            if (count < 1) {
                continue;
            }

            bool covered = false;
            foreach (cfg; configs) {
                if (cfg.situationType == situationType && cfg.enabled) {
                    covered = true;
                    break;
                }
            }

            if (covered) {
                continue;
            }

            Json suggestion = Json.emptyObject;
            suggestion["situation_type"] = situationType;
            suggestion["occurrences"] = count;
            suggestion["suggested_flow"] = "rule_based_auto_resolution";
            suggestion["potential_time_saved_minutes"] = cast(double)max(1, cast(int)count * 4);
            suggestions ~= suggestion;
        }

        return suggestions;
    }
}
