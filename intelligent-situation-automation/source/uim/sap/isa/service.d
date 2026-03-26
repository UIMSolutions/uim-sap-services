/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.isa.service;

import uim.sap.isa;

mixin(ShowModule!());

@safe:

class ISAService : SAPService {
  private ISAConfig _config;
  private ISAStore _store;

  this(ISAConfig config) {
    super(config);

    _store = new ISAStore;
    _store.seed(config.defaultTenant);
  }

  override Json health() {
    auto cfg = cast(ISAConfig)config;

    Json healthInfo = super.health();
    healthInfo["default_tenant"] = cfg.defaultTenant;
    return healthInfo;
  }

  Json createConfiguration(UUID tenantId, Json request) {
    auto cfg = configFromJson(request, tenantId);
    validateConfiguration(cfg);
    auto created = _store.createConfiguration(cfg);
    return created.toJson();
  }

  Json updateConfiguration(UUID tenantId, string configId, Json request) {
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

  Json deleteConfiguration(UUID tenantId, string configId) {
    auto existing = _store.getConfiguration(configId);
    if (existing.id.length == 0 || existing.tenantId != tenantId) {
      throw new ISANotFoundException("configuration", configId);
    }

    if (!_store.deleteConfiguration(configId)) {
      throw new ISAException("could not delete configuration");
    }

    return Json.emptyObject
      .set("success", true)
      .set("deleted_id", configId);
  }

  Json getConfiguration(UUID tenantId, string configId) {
    auto cfg = _store.getConfiguration(configId);
    if (cfg.id.length == 0 || cfg.tenantId != tenantId) {
      throw new ISANotFoundException("configuration", configId);
    }

    return cfg.toJson();
  }

  Json listConfigurations(UUID tenantId) {
    Json resources = Json.emptyArray;

    auto configs = _store.listConfigurations(tenantId);
    foreach (cfg; configs) {
      resources ~= cfg.toJson();
    }

    Json payload = Json.emptyObject;
    payload["resources"] = resources;
    payload["total_results"] = cast(long)configs.length;
    return payload;
  }

  Json createSituation(UUID tenantId, Json request) {
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

  Json listSituations(UUID tenantId) {
    Json resources = _store.listSituations(tenantId).map!(entry => entry.toJson()).array;

    return Json.emptyObject
      .set("resources", resources)
      .set("total_results", cast(long)resources.length);
  }

  Json dashboard(UUID tenantId) {
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

    return Json.emptyObject
      .set("tenant_id", tenantId)
      .set("total_situations", cast(long)situations.length)
      .set("auto_resolved", autoResolvedCount)
      .set("manual_resolved", manuallyResolvedCount)
      .set("open", openCount)
      .set("time_saved_minutes", timeSavedMinutes)
      .set("time_saved_hours", timeSavedMinutes / 60.0)
      .set("automation_suggestions", suggestions);
  }

  Json analyzeSituations(UUID tenantId, string situationType) {
    auto situations = _store.listSituations(tenantId);

    long[string] byType;
    foreach (entry; situations) {
      byType[entry.situationType] = byType.get(entry.situationType, 0) + 1;
    }

    Json counts = Json.emptyArray;
    foreach (key, value; byType) {
      counts ~= Json.emptyObject
        .set("situation_type", key)
        .set("count", value);
    }

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

      Json details = Json.emptyObject
        .set("situation_type", situationType)
        .set("instances", filtered)
        .set("resolution_flows", flows)
        .set("data_context_example", filtered.length > 0 ? filtered[0]["data_context"]
            : Json.emptyObject);
    }

    return Json.emptyObject
      .set("tenant_id", tenantId)
      .set("counts_by_type", counts)
      .set("details", details);
  }

  Json exploreRelatedSituations(UUID tenantId) {
    auto situations = _store.listSituations(tenantId);
    auto reports = _store.listReports(tenantId);

    long[string] entityTypeCounts;
    string[][string] templatesByEntity;
    Json relationships = Json.emptyArray;

    foreach (entry; situations) {
      entityTypeCounts[entry.entityType] = entityTypeCounts.get(entry.entityType, 0) + 1;
      templatesByEntity[entry.entityType] ~= entry.templateId;

      relationships ~= Json.emptyObject
        .set("entity_type", entry.entityType)
        .set("entity_id", entry.entityId)
        .set("situation_type", entry.situationType)
        .set("template_id", entry.templateId);
    }

    Json topEntityTypes = Json.emptyArray;
    foreach (entityType, count; entityTypeCounts) {
      Json templates = templatesByEntity[entityType].map!(t => Json.emptyObject.set("template_id", t))
        .array;

      topEntityTypes ~= Json.emptyObject
        .set("entity_type", entityType)
        .set("count", count)
        .set("templates", templates);
    }

    Json reportItems = reports.map!(report => report.toJson()).array;

    return Json.emptyObject
      .set("tenant_id", tenantId)
      .set("top_entity_types", topEntityTypes)
      .set("relationships", relationships)
      .set("data_context_reports", reportItems);
  }

  Json contextReports(UUID tenantId) {
    auto resources = _store.listReports(tenantId).map!(report => report.toJson()).array;

    return Json.emptyObject
      .set("resources", resources)
      .set("total_results", cast(long)resources.length);
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

  private Json[] automationSuggestions(UUID tenantId) {
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

      suggestions ~= Json.emptyObject
        .set("situation_type", situationType)
        .set("occurrences", count)
        .set("suggested_flow", "rule_based_auto_resolution")
        .set("potential_time_saved_minutes", cast(double)max(1, cast(int)count * 4));
    }

    return suggestions;
  }
}
