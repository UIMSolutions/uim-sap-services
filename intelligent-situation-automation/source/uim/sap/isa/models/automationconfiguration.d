/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.isa.models.automationconfiguration;
import uim.sap.isa;

mixin(ShowModule!());

@safe:
struct AutomationConfiguration {
  string id;
  UUID tenantId;
  string name;
  string description;
  string situationType;
  bool enabled;
  int avgManualMinutes;
  double autoResolutionRate;
  BusinessRule[] businessRules;
  SysTime createdAt;
  SysTime updatedAt;

  override Json toJson()  {
    Json info = super.toJson;
    Json rules = Json.emptyArray;
    foreach (rule; businessRules) {
      rules ~= rule.toJson();
    }

    payload["id"] = id;
    payload["tenant_id"] = tenantId;
    payload["name"] = name;
    payload["description"] = description;
    payload["situation_type"] = situationType;
    payload["enabled"] = enabled;
    payload["avg_manual_minutes"] = avgManualMinutes;
    payload["auto_resolution_rate"] = autoResolutionRate;
    payload["business_rules"] = rules;
    payload["created_at"] = createdAt.toISOExtString();
    payload["updated_at"] = updatedAt.toISOExtString();
    return payload;
  }
}

AutomationConfiguration configFromJson(Json payload, UUID tenantId) {
  AutomationConfiguration config;
  config.id = randomUUID().toString();
  config.tenantId = UUID(tenantId);
  config.name = getString(payload, "name", "");
  config.description = getString(payload, "description", "");
  config.situationType = getString(payload, "situation_type", "");
  config.enabled = getBool(payload, "enabled", true);
  config.avgManualMinutes = getInt(payload, "avg_manual_minutes", 5);
  config.autoResolutionRate = getDouble(payload, "auto_resolution_rate", 0.75);
  config.businessRules = parseRules(payload);
  config.createdAt = Clock.currTime();
  config.updatedAt = config.createdAt;

  if (config.avgManualMinutes <= 0) {
    config.avgManualMinutes = 1;
  }
  if (config.autoResolutionRate < 0) {
    config.autoResolutionRate = 0;
  }
  if (config.autoResolutionRate > 1) {
    config.autoResolutionRate = 1;
  }

  return config;
}

AutomationConfiguration updateConfigFromJson(AutomationConfiguration current, Json payload) {
  auto updated = current;

  if ("name" in payload) {
    updated.name = getString(payload, "name", current.name);
  }
  if ("description" in payload) {
    updated.description = getString(payload, "description", current.description);
  }
  if ("situation_type" in payload) {
    updated.situationType = getString(payload, "situation_type", current.situationType);
  }
  if ("enabled" in payload) {
    updated.enabled = getBool(payload, "enabled", current.enabled);
  }
  if ("avg_manual_minutes" in payload) {
    updated.avgManualMinutes = max(1, getInt(payload, "avg_manual_minutes", current
        .avgManualMinutes));
  }
  if ("auto_resolution_rate" in payload) {
    auto rate = getDouble(payload, "auto_resolution_rate", current.autoResolutionRate);
    if (rate < 0)
      rate = 0;
    if (rate > 1)
      rate = 1;
    updated.autoResolutionRate = rate;
  }
  if ("business_rules" in payload) {
    updated.businessRules = parseRules(payload);
  }

  updated.updatedAt = Clock.currTime();
  return updated;
}