/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.rms.store;

import uim.sap.rms;

mixin(ShowModule!());

@safe:

class RMSStore : SAPStore {
  private struct TenantState {
    TeamTypeDef[string] teamTypes;
    FunctionDef[string] functions;
    Team[string] teams;
    ResponsibilityRule[string] rules;
    DeterminationLog[] logs;
  }

  private string _root;
  private int _logRetention;
  private TenantState[string] _states;

  this(string rootPath, int logRetention) {
    _root = rootPath;
    _logRetention = logRetention;
    mkdirRecurse(_root);
  }

  Json[] sapDeliveredTeamCategories() {
    string[] values = [
      "FINANCE",
      "PROCUREMENT",
      "SALES",
      "OPERATIONS",
      "COMPLIANCE",
      "WORKFLOW"
    ];

    Json[] categories;
    foreach (item; values) {
      Json entry = Json.emptyObject;
      entry["code"] = item;
      entry["name"] = item;
      categories ~= entry;
    }
    return categories;
  }

  TeamTypeDef[] listTeamTypes(TenantContext tenant) {
    auto state = stateFor(tenant);
    TeamTypeDef[] list;
    foreach (item; state.teamTypes.byValue)
      list ~= item;
    return list;
  }

  TeamTypeDef upsertTeamType(TenantContext tenant, string code, Json request) {
    validateKey(code, "team type code");
    auto state = stateFor(tenant);

    TeamTypeDef item;
    item.code = code;
    item.name = getString(request, "name", code);
    item.description = getString(request, "description", "");

    state.teamTypes[code] = item;
    saveState(tenant, state);
    return item;
  }

  void deleteTeamType(TenantContext tenant, string code) {
    auto state = stateFor(tenant);
    if (!(code in state.teamTypes)) {
      throw new RMSNotFoundException("TeamType", code);
    }
    state.teamTypes.remove(code);
    saveState(tenant, state);
  }

  FunctionDef[] listFunctions(TenantContext tenant) {
    auto state = stateFor(tenant);
    FunctionDef[] list;
    foreach (item; state.functions.byValue)
      list ~= item;
    return list;
  }

  FunctionDef upsertFunction(TenantContext tenant, string code, Json request) {
    validateKey(code, "function code");
    auto state = stateFor(tenant);

    FunctionDef item;
    item.code = code;
    item.name = getString(request, "name", code);
    item.description = getString(request, "description", "");

    state.functions[code] = item;
    saveState(tenant, state);
    return item;
  }

  void deleteFunction(TenantContext tenant, string code) {
    auto state = stateFor(tenant);
    if (!(code in state.functions)) {
      throw new RMSNotFoundException("Function", code);
    }

    foreach (teamKey, teamItem; state.teams) {
      auto team = teamItem;
      foreach (index, member; team.members) {
        string[] filtered;
        foreach (fn; member.functions) {
          if (fn != code)
            filtered ~= fn;
        }
        team.members[index].functions = filtered;
      }
      state.teams[teamKey] = team;
    }

    state.functions.remove(code);
    saveState(tenant, state);
  }

  Team[] listTeams(TenantContext tenant) {
    auto state = stateFor(tenant);
    Team[] list;
    foreach (item; state.teams.byValue)
      list ~= item;
    return list;
  }

  Team createTeam(TenantContext tenant, Json request) {
    auto state = stateFor(tenant);

    Team team;
    team.id = getString(request, "id", randomUUID().toString());
    validateKey(team.id, "team id");

    if (team.id in state.teams) {
      throw new RMSValidationException("Team already exists: " ~ team.id);
    }

    team.name = getString(request, "name", "");
    team.typeCode = getString(request, "type_code", "");
    team.categoryCode = getString(request, "category_code", "WORKFLOW");
    team.description = getString(request, "description", "");
    team.members = parseMembers(request);

    if (team.name.length == 0) {
      throw new RMSValidationException("team.name is required");
    }

    state.teams[team.id] = team;
    saveState(tenant, state);
    return team;
  }

  Team getTeam(TenantContext tenant, string teamId) {
    auto state = stateFor(tenant);
    if (!(teamId in state.teams)) {
      throw new RMSNotFoundException("Team", teamId);
    }
    return state.teams[teamId];
  }

  Team updateTeam(TenantContext tenant, string teamId, Json request) {
    auto state = stateFor(tenant);
    if (!(teamId in state.teams)) {
      throw new RMSNotFoundException("Team", teamId);
    }

    auto team = state.teams[teamId];
    team.name = getString(request, "name", team.name);
    team.typeCode = getString(request, "type_code", team.typeCode);
    team.categoryCode = getString(request, "category_code", team.categoryCode);
    team.description = getString(request, "description", team.description);

    if ("members" in request && request["members"].isArray) {
      team.members = parseMembers(request);
    }

    state.teams[teamId] = team;
    saveState(tenant, state);
    return team;
  }

  void deleteTeam(TenantContext tenant, string teamId) {
    auto state = stateFor(tenant);
    if (!(teamId in state.teams)) {
      throw new RMSNotFoundException("Team", teamId);
    }
    state.teams.remove(teamId);

    foreach (ruleKey, ruleItem; state.rules) {
      if (ruleItem.teamId == teamId) {
        auto rule = ruleItem;
        rule.teamId = "";
        state.rules[ruleKey] = rule;
      }
    }

    saveState(tenant, state);
  }

  Team copyTeam(TenantContext tenant, string teamId, string newName) {
    auto state = stateFor(tenant);
    if (!(teamId in state.teams)) {
      throw new RMSNotFoundException("Team", teamId);
    }

    auto team = state.teams[teamId];
    auto copy = team;
    copy.id = randomUUID().toString();
    copy.name = newName.length > 0 ? newName : team.name ~ " (Copy)";

    state.teams[copy.id] = copy;
    saveState(tenant, state);
    return copy;
  }

  ResponsibilityRule[] listRules(TenantContext tenant) {
    auto state = stateFor(tenant);
    ResponsibilityRule[] list;
    foreach (item; state.rules.byValue)
      list ~= item;
    return list;
  }

  ResponsibilityRule createRule(TenantContext tenant, Json request) {
    auto state = stateFor(tenant);

    ResponsibilityRule rule;
    rule.id = getString(request, "id", randomUUID().toString());
    validateKey(rule.id, "rule id");
    if (rule.id in state.rules) {
      throw new RMSValidationException("Rule already exists: " ~ rule.id);
    }

    fillRule(rule, request);

    if (rule.name.length == 0 || rule.contextType.length == 0 || rule.objectType.length == 0) {
      throw new RMSValidationException(
        "rule.name, rule.context_type and rule.object_type are required");
    }

    rule.createdAt = nowIso();
    rule.updatedAt = rule.createdAt;

    state.rules[rule.id] = rule;
    saveState(tenant, state);
    return rule;
  }

  ResponsibilityRule getRule(TenantContext tenant, string ruleId) {
    auto state = stateFor(tenant);
    if (!(ruleId in state.rules)) {
      throw new RMSNotFoundException("Rule", ruleId);
    }
    return state.rules[ruleId];
  }

  ResponsibilityRule updateRule(TenantContext tenant, string ruleId, Json request) {
    auto state = stateFor(tenant);
    if (!(ruleId in state.rules)) {
      throw new RMSNotFoundException("Rule", ruleId);
    }

    auto rule = state.rules[ruleId];
    fillRule(rule, request, false);
    rule.updatedAt = nowIso();

    state.rules[ruleId] = rule;
    saveState(tenant, state);
    return rule;
  }

  void deleteRule(TenantContext tenant, string ruleId) {
    auto state = stateFor(tenant);
    if (!(ruleId in state.rules)) {
      throw new RMSNotFoundException("Rule", ruleId);
    }
    state.rules.remove(ruleId);
    saveState(tenant, state);
  }

  Json determineAgents(TenantContext tenant, Json request) {
    auto started = Clock.currTime();
    auto state = stateFor(tenant);

    auto contextType = getString(request, "context_type", "");
    auto objectType = getString(request, "object_type", "");
    auto documentId = getString(request, "document_id", randomUUID().toString());

    if (contextType.length == 0 || objectType.length == 0) {
      throw new RMSValidationException("context_type and object_type are required");
    }

    Json payload = Json.emptyObject;
    if ("payload" in request && request["payload"].isObject) {
      payload = request["payload"];
    }

    bool notifyAgents = true;
    if ("notify" in request && request["notify"].isBoolean) {
      notifyAgents = request["notify"].get!bool;
    }

    auto sorted = listRules(tenant);
    sortRulesByPriority(sorted);

    string[] matchedRuleIds;
    string[] matchedTeamIds;

    bool[string] agentSet;
    bool[string] teamSet;
    string[] notifications;

    foreach (rule; sorted) {
      if (!rule.enabled)
        continue;
      if (rule.contextType != contextType || rule.objectType != objectType)
        continue;

      if (!ruleMatches(rule, payload))
        continue;
      matchedRuleIds ~= rule.id;

      auto resolvedTeams = resolveTeamsForRule(state, rule);
      foreach (team; resolvedTeams) {
        if (!(team.id in teamSet)) {
          teamSet[team.id] = true;
          matchedTeamIds ~= team.id;
        }

        foreach (member; team.members) {
          if (!memberMatchesRule(member, rule))
            continue;
          if (!(member.userId in agentSet)) {
            agentSet[member.userId] = true;
          }

          if (notifyAgents && member.notificationsEnabled) {
            notifications ~= "Notify " ~ member.userId ~
              " about document " ~ documentId ~
              " in context " ~ contextType;
          }
        }
      }
    }

    string[] agents;
    foreach (userId, present; agentSet) {
      if (present)
        agents ~= userId;
    }

    DeterminationLog logEntry;
    logEntry.id = randomUUID().toString();
    logEntry.timestamp = nowIso();
    logEntry.tenantId = tenant.tenantId;
    logEntry.spaceId = tenant.spaceId;
    logEntry.contextType = contextType;
    logEntry.objectType = objectType;
    logEntry.documentId = documentId;
    logEntry.matchedRuleIds = matchedRuleIds;
    logEntry.teamIds = matchedTeamIds;
    logEntry.agents = agents;
    logEntry.notifications = notifications;
    logEntry.durationMs = cast(long)((Clock.currTime() - started).total!"msecs");

    state.logs ~= logEntry;
    trimLogs(state);
    saveState(tenant, state);

    Json result = Json.emptyObject;
    result["document_id"] = documentId;
    result["context_type"] = contextType;
    result["object_type"] = objectType;

    Json rulesJson = Json.emptyArray;
    foreach (id; matchedRuleIds)
      rulesJson ~= id;
    result["matched_rules"] = rulesJson;

    Json teamsJson = Json.emptyArray;
    foreach (id; matchedTeamIds)
      teamsJson ~= id;
    result["matched_teams"] = teamsJson;

    Json agentsJson = Json.emptyArray;
    foreach (item; agents)
      agentsJson ~= item;
    result["agents"] = agentsJson;

    Json noteJson = Json.emptyArray;
    foreach (item; notifications)
      noteJson ~= item;
    result["notifications"] = noteJson;

    result["log_id"] = logEntry.id;
    result["duration_ms"] = logEntry.durationMs;
    return result;
  }

  DeterminationLog[] listLogs(TenantContext tenant, size_t limit = 100) {
    auto state = stateFor(tenant);
    auto logs = state.logs;
    if (logs.length > limit) {
      return logs[$ - limit .. $];
    }
    return logs;
  }

  Json exportData(TenantContext tenant) {
    auto state = stateFor(tenant);

    Json payload = Json.emptyObject;
    payload["tenant_id"] = tenant.tenantId;
    payload["space_id"] = tenant.spaceId;
    payload["exported_at"] = nowIso();

    Json teamTypes = Json.emptyArray;
    foreach (item; state.teamTypes.byValue)
      teamTypes ~= item.toJson();
    payload["team_types"] = teamTypes;

    Json functions = Json.emptyArray;
    foreach (item; state.functions.byValue)
      functions ~= item.toJson();
    payload["functions"] = functions;

    Json teams = Json.emptyArray;
    foreach (item; state.teams.byValue)
      teams ~= item.toJson();
    payload["teams"] = teams;

    Json rules = Json.emptyArray;
    foreach (item; state.rules.byValue)
      rules ~= item.toJson();
    payload["rules"] = rules;

    Json logs = Json.emptyArray;
    foreach (item; state.logs)
      logs ~= item.toJson();
    payload["logs"] = logs;

    return payload;
  }

  private bool ruleMatches(ResponsibilityRule rule, Json payload) {
    if (rule.mode == RuleMode.externalApi) {
      return true;
    }

    if (rule.conditionField.length == 0) {
      return true;
    }

    if (!(rule.conditionField in payload)) {
      return false;
    }

    auto value = jsonToString(payload[rule.conditionField]);
    return toLower(value) == toLower(rule.conditionEquals);
  }

  private Team[] resolveTeamsForRule(TenantState state, ResponsibilityRule rule) {
    Team[] teams;

    if (rule.teamId.length > 0 && rule.teamId in state.teams) {
      teams ~= state.teams[rule.teamId];
    }

    if (rule.mode == RuleMode.externalApi && rule.externalApiRef.length > 0) {
      auto externalRef = rule.externalApiRef;
      if (externalRef.startsWith("TEAM:")) {
        auto teamId = externalRef[5 .. $].strip();
        if (teamId in state.teams) {
          teams ~= state.teams[teamId];
        }
      } else if (externalRef.startsWith("TEAM_BY_CATEGORY:")) {
        auto category = externalRef[17 .. $].strip();
        foreach (team; state.teams.byValue) {
          if (toLower(team.categoryCode) == toLower(category)) {
            teams ~= team;
          }
        }
      } else if (externalRef.startsWith("FUNCTION:")) {
        auto fn = externalRef[9 .. $].strip();
        foreach (team; state.teams.byValue) {
          foreach (member; team.members) {
            if (hasFunction(member.functions, fn)) {
              teams ~= team;
              break;
            }
          }
        }
      }
    }

    return dedupeTeams(teams);
  }

  private Team[] dedupeTeams(Team[] list) {
    bool[string] seen;
    Team[] deduped;
    foreach (team; list) {
      if (!(team.id in seen)) {
        seen[team.id] = true;
        deduped ~= team;
      }
    }
    return deduped;
  }

  private bool memberMatchesRule(TeamMember member, ResponsibilityRule rule) {
    if (rule.functionCode.length == 0) {
      return true;
    }
    return hasFunction(member.functions, rule.functionCode);
  }

  private bool hasFunction(string[] list, string value) {
    foreach (item; list) {
      if (toLower(item) == toLower(value)) {
        return true;
      }
    }
    return false;
  }

  private void sortRulesByPriority(ResponsibilityRule[] rules) {
    foreach (i; 0 .. rules.length) {
      foreach (j; i + 1 .. rules.length) {
        if (rules[j].priority > rules[i].priority) {
          auto temp = rules[i];
          rules[i] = rules[j];
          rules[j] = temp;
        }
      }
    }
  }

  private void trimLogs(ref TenantState state) {
    if (state.logs.length <= _logRetention) {
      return;
    }
    state.logs = state.logs[$ - _logRetention .. $];
  }

  private TeamMember[] parseMembers(Json request) {
    TeamMember[] members;
    if (!("members" in request) || request["members"].type != Json.Type.array) {
      return members;
    }

    foreach (item; request["members"]) {
      if (item.type != Json.Type.object)
        continue;

      TeamMember member;
      member.userId = getString(item, "user_id", "");
      member.displayName = getString(item, "display_name", member.userId);
      member.isOwner = getBool(item, "is_owner", false);
      member.notificationsEnabled = getBool(item, "notifications_enabled", true);

      if ("functions" in item && item["functions"].isArray) {
        foreach (fn; item["functions"]) {
          if (fn.isString) {
            member.functions ~= fn.get!string;
          }
        }
      }

      if (member.userId.length > 0) {
        members ~= member;
      }
    }

    return members;
  }

  private void fillRule(ref ResponsibilityRule rule, Json request, bool full = true) {
    if (full || "name" in request)
      rule.name = getString(request, "name", rule.name);
    if (full || "context_type" in request) {
      rule.contextType = getString(request, "context_type", rule.contextType);
    }
    if (full || "object_type" in request) {
      rule.objectType = getString(request, "object_type", rule.objectType);
    }
    if (full || "mode" in request) {
      rule.mode = modeFromString(getString(request, "mode", modeToString(rule.mode)));
    }
    if (full || "condition_field" in request) {
      rule.conditionField = getString(request, "condition_field", rule.conditionField);
    }
    if (full || "condition_equals" in request) {
      rule.conditionEquals = getString(request, "condition_equals", rule.conditionEquals);
    }
    if (full || "external_api_ref" in request) {
      rule.externalApiRef = getString(request, "external_api_ref", rule.externalApiRef);
    }
    if (full || "team_id" in request) {
      rule.teamId = getString(request, "team_id", rule.teamId);
    }
    if (full || "function_code" in request) {
      rule.functionCode = getString(request, "function_code", rule.functionCode);
    }
    if (full || "enabled" in request) {
      rule.enabled = getBool(request, "enabled", true);
    }
    if (full || "priority" in request) {
      rule.priority = getInt(request, "priority", 100);
    }
  }

  private TenantState stateFor(TenantContext tenant) {
    auto key = stateKey(tenant);
    if (!(key in _states)) {
      _states[key] = loadState(tenant);
    }
    return _states[key];
  }

  private void saveState(TenantContext tenant, TenantState state) {
    auto key = stateKey(tenant);
    _states[key] = state;

    Json payload = Json.emptyObject;

    Json teamTypes = Json.emptyArray;
    foreach (item; state.teamTypes.byValue)
      teamTypes ~= item.toJson();
    payload["team_types"] = teamTypes;

    Json functions = Json.emptyArray;
    foreach (item; state.functions.byValue)
      functions ~= item.toJson();
    payload["functions"] = functions;

    Json teams = Json.emptyArray;
    foreach (item; state.teams.byValue)
      teams ~= item.toJson();
    payload["teams"] = teams;

    Json rules = Json.emptyArray;
    foreach (item; state.rules.byValue)
      rules ~= item.toJson();
    payload["rules"] = rules;

    Json logs = Json.emptyArray;
    foreach (item; state.logs)
      logs ~= item.toJson();
    payload["logs"] = logs;

    auto file = stateFile(tenant);
    mkdirRecurse(fileDirectory(tenant));
    write(file, payload.toString());
  }

  private TenantState loadState(TenantContext tenant) {
    TenantState state;

    auto file = stateFile(tenant);
    if (!exists(file)) {
      return state;
    }

    try {
      auto payload = parseJsonString(readText(file));

      if ("team_types" in payload && payload["team_types"].isArray) {
        foreach (item; payload["team_types"]) {
          if (item.type != Json.Type.object)
            continue;
          TeamTypeDef def;
          def.code = getString(item, "code", "");
          def.name = getString(item, "name", def.code);
          def.description = getString(item, "description", "");
          if (def.code.length > 0)
            state.teamTypes[def.code] = def;
        }
      }

      if ("functions" in payload && payload["functions"].isArray) {
        foreach (item; payload["functions"]) {
          if (item.type != Json.Type.object)
            continue;
          FunctionDef def;
          def.code = getString(item, "code", "");
          def.name = getString(item, "name", def.code);
          def.description = getString(item, "description", "");
          if (def.code.length > 0)
            state.functions[def.code] = def;
        }
      }

      if ("teams" in payload && payload["teams"].isArray) {
        foreach (item; payload["teams"]) {
          if (item.type != Json.Type.object)
            continue;
          Team team;
          team.id = getString(item, "id", "");
          team.name = getString(item, "name", "");
          team.typeCode = getString(item, "type_code", "");
          team.categoryCode = getString(item, "category_code", "WORKFLOW");
          team.description = getString(item, "description", "");
          team.members = parseMembers(item);
          if (team.id.length > 0)
            state.teams[team.id] = team;
        }
      }

      if ("rules" in payload && payload["rules"].isArray) {
        foreach (item; payload["rules"]) {
          if (!item.isObject)
            continue;
          ResponsibilityRule rule;
          rule.id = getString(item, "id", "");
          rule.name = getString(item, "name", "");
          rule.contextType = getString(item, "context_type", "");
          rule.objectType = getString(item, "object_type", "");
          rule.mode = modeFromString(getString(item, "mode", "condition"));
          rule.conditionField = getString(item, "condition_field", "");
          rule.conditionEquals = getString(item, "condition_equals", "");
          rule.externalApiRef = getString(item, "external_api_ref", "");
          rule.teamId = getString(item, "team_id", "");
          rule.functionCode = getString(item, "function_code", "");
          rule.enabled = getBool(item, "enabled", true);
          rule.priority = getInt(item, "priority", 100);
          rule.createdAt = getString(item, "created_at", nowIso());
          rule.updatedAt = getString(item, "updated_at", nowIso());
          if (rule.id.length > 0)
            state.rules[rule.id] = rule;
        }
      }

      if ("logs" in payload && payload["logs"].isArray) {
        foreach (item; payload["logs"]) {
          if (!item.isObject)
            continue;
          DeterminationLog log;
          log.id = getString(item, "id", "");
          log.timestamp = getString(item, "timestamp", nowIso());
          log.tenantId = getString(item, "tenant_id", tenant.tenantId);
          log.spaceId = getString(item, "space_id", tenant.spaceId);
          log.contextType = getString(item, "context_type", "");
          log.objectType = getString(item, "object_type", "");
          log.documentId = getString(item, "document_id", "");
          log.matchedRuleIds = getStringArray(item, "matched_rule_ids");
          log.teamIds = getStringArray(item, "team_ids");
          log.agents = getStringArray(item, "agents");
          log.notifications = getStringArray(item, "notifications");
          log.durationMs = getLong(item, "duration_ms", 0);
          if (log.id.length > 0)
            state.logs ~= log;
        }
      }

      trimLogs(state);
    } catch (Exception) {
    }

    return state;
  }

  private string stateKey(TenantContext tenant) {
    return tenant.tenantId ~ "|" ~ tenant.spaceId;
  }

  private string fileDirectory(TenantContext tenant) {
    return buildPath(_root, "tenants", safe(tenant.tenantId), "spaces", safe(tenant.spaceId));
  }

  private string stateFile(TenantContext tenant) {
    return buildPath(fileDirectory(tenant), "state.json");
  }

  private string safe(string value) {
    string safeValue;
    foreach (ch; value) {
      if (
        (ch >= 'a' && ch <= 'z') ||
        (ch >= 'A' && ch <= 'Z') ||
        (ch >= '0' && ch <= '9') ||
        ch == '-' ||
        ch == '_' ||
        ch == '.'
        ) {
        safeValue ~= ch;
      } else {
        safeValue ~= '_';
      }
    }
    return safeValue;
  }

  private void validateKey(string value, string label) {
    if (value.strip().length == 0) {
      throw new RMSValidationException(label ~ " is required");
    }
  }

  private string jsonToString(Json value) {
    if (value.isString)
      return value.get!string;
    if (value.isInteger)
      return to!string(value.get!long);
    if (value.isFloat)
      return to!string(value.get!double);
    if (value.isBoolean)
      return value.get!bool ? "true" : "false";
    return "";
  }

  private string getString(Json payload, string key, string fallback) {
    if (key in payload && payload[key].isString) {
      return payload[key].get!string;
    }
    return fallback;
  }

  private bool getBool(Json payload, string key, bool fallback) {
    if (key in payload && payload[key].isBoolean) {
      return payload[key].get!bool;
    }
    return fallback;
  }

  private int getInt(Json payload, string key, int fallback) {
    if (key in payload && payload[key].isInteger) {
      return cast(int)payload[key].get!long;
    }
    return fallback;
  }

  private long getLong(Json payload, string key, long fallback) {
    if (key in payload && payload[key].isInteger) {
      return payload[key].get!long;
    }
    return fallback;
  }

  private string[] getStringArray(Json payload, string key) {
    string[] values;
    if (!(key in payload) || payload[key].type != Json.Type.array) {
      return values;
    }
    foreach (item; payload[key]) {
      if (item.isString) {
        values ~= item.get!string;
      }
    }
    return values;
  }
}
