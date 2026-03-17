/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.rms.service;

import uim.sap.rms;

mixin(ShowModule!());

@safe:

class RMSService : SAPService {
  private RMSStore _store;

  this(RMSConfig config) {
    super(config);
    _store = new RMSStore(config.dataDirectory, config.logRetention);
  }

  Json sapDeliveredCategories() {
    Json categories = _store.sapDeliveredTeamCategories().map!(item => item.toJson).array.toJson;

    return Json.emptyObject
      .set("categories", categories)
      .set("total", cast(long)categories.length);
  }

  Json listTeamTypes(TenantContext tenant) {
    Json types = _store.listTeamTypes(tenant).map!(item => item.toJson).array.toJson;

    return Json.emptyObject
      .set("team_types", types)
      .set("total", cast(long)types.length);
  }

  Json upsertTeamType(TenantContext tenant, string code, Json request) {
    auto item = _store.upsertTeamType(tenant, code, request);
    
    return Json.emptyObject
      .set("team_type", item.toJson());
  }

  Json deleteTeamType(TenantContext tenant, string code) {
    _store.deleteTeamType(tenant, code);
    
    return Json.emptyObject
      .set("deleted", true)
      .set("code", code);
  }

  Json listFunctions(TenantContext tenant) {
    Json functions = _store.listFunctions(tenant).map!(item => item.toJson).array.toJson;

    return Json.emptyObject
      .set("functions", functions)
      .set("total", cast(long)functions.length);
  }

  Json upsertFunction(TenantContext tenant, string code, Json request) {
    auto item = _store.upsertFunction(tenant, code, request);
    return Json.emptyObject
      .set("function", item.toJson());
  }

  Json deleteFunction(TenantContext tenant, string code) {
    _store.deleteFunction(tenant, code);
    return Json.emptyObject
      .set("deleted", true)
      .set("code", code);
  }

  Json listTeams(TenantContext tenant) {
    Json list = Json.emptyArray;
    foreach (item; _store.listTeams(tenant))
      list ~= item.toJson();

    return Json.emptyObject
      .set("teams", list)
      .set("total", cast(long)list.length);
  }

  Json createTeam(TenantContext tenant, Json request) {
    auto item = _store.createTeam(tenant, request);

    return Json.emptyObject
      .set("team", item.toJson());
  }

  Json getTeam(TenantContext tenant, string teamId) {
    auto item = _store.getTeam(tenant, teamId);

    return Json.emptyObject
      .set("team", item.toJson());
  }

  Json updateTeam(TenantContext tenant, string teamId, Json request) {
    auto item = _store.updateTeam(tenant, teamId, request);
    
    return Json.emptyObject
      .set("team", item.toJson());
  }

  Json deleteTeam(TenantContext tenant, string teamId) {
    _store.deleteTeam(tenant, teamId);

    return Json.emptyObject
      .set("deleted", true)
      .set("team_id", teamId);
  }

  Json copyTeam(TenantContext tenant, string teamId, Json request) {
    auto copied = _store.copyTeam(tenant, teamId, getString(request, "name", ""));

    return Json.emptyObject
      .set("team", copied.toJson());
  }

  Json listRules(TenantContext tenant) {
    Json list = _store.listRules(tenant).map!(rule => rule.toJson();

    return Json.emptyObject
      .set("rules", list)
      .set("total", cast(long)list.length);
  }

  Json createRule(TenantContext tenant, Json request) {
    auto item = _store.createRule(tenant, request);

    return Json.emptyObject
      .set("rule", item.toJson());
  }

  Json getRule(TenantContext tenant, string ruleId) {
    auto item = _store.getRule(tenant, ruleId);

    return Json.emptyObject
      .set("rule", item.toJson());
  }

  Json updateRule(TenantContext tenant, string ruleId, Json request) {
    auto item = _store.updateRule(tenant, ruleId, request);
    return Json.emptyObject
      .set("rule", item.toJson());
  }

  Json deleteRule(TenantContext tenant, string ruleId) {
    _store.deleteRule(tenant, ruleId);

    return Json.emptyObject
      .set("deleted", true)
      .set("rule_id", ruleId);
  }

  Json determine(TenantContext tenant, Json request) {
    return _store.determineAgents(tenant, request);
  }

  Json listLogs(TenantContext tenant, size_t limit = 100) {
    Json list = _store.listLogs(tenant, limit).map!(item => item.toJson).array.toJson;  

    return Json.emptyObject
      .set("logs", list)
      .set("total", cast(long)list.length);
  }

  Json exportData(TenantContext tenant) {
    return _store.exportData(tenant);
  }
}
