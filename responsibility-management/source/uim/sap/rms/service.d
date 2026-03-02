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
    private RMSConfig _config;
    private RMSStore _store;

    this(RMSConfig config) {
        config.validate();
        _config = config;
        _store = new RMSStore(_config.dataDirectory, _config.logRetention);
    }

    @property const(RMSConfig) config() const {
        return _config;
    }

    Json health() {
        Json payload = Json.emptyObject;
        payload["ok"] = true;
        payload["service_name"] = _config.serviceName;
        payload["service_version"] = _config.serviceVersion;
        return payload;
    }

    Json ready() {
        Json payload = Json.emptyObject;
        payload["ready"] = true;
        return payload;
    }

    Json sapDeliveredCategories() {
        Json list = Json.emptyArray;
        foreach (item; _store.sapDeliveredTeamCategories()) {
            list ~= item;
        }

        Json payload = Json.emptyObject;
        payload["categories"] = list;
        payload["total"] = cast(long)list.length;
        return payload;
    }

    Json listTeamTypes(TenantContext tenant) {
        Json list = Json.emptyArray;
        foreach (item; _store.listTeamTypes(tenant)) list ~= item.toJson();

        Json payload = Json.emptyObject;
        payload["team_types"] = list;
        payload["total"] = cast(long)list.length;
        return payload;
    }

    Json upsertTeamType(TenantContext tenant, string code, Json request) {
        auto item = _store.upsertTeamType(tenant, code, request);
        Json payload = Json.emptyObject;
        payload["team_type"] = item.toJson();
        return payload;
    }

    Json deleteTeamType(TenantContext tenant, string code) {
        _store.deleteTeamType(tenant, code);
        Json payload = Json.emptyObject;
        payload["deleted"] = true;
        payload["code"] = code;
        return payload;
    }

    Json listFunctions(TenantContext tenant) {
        Json list = Json.emptyArray;
        foreach (item; _store.listFunctions(tenant)) list ~= item.toJson();

        Json payload = Json.emptyObject;
        payload["functions"] = list;
        payload["total"] = cast(long)list.length;
        return payload;
    }

    Json upsertFunction(TenantContext tenant, string code, Json request) {
        auto item = _store.upsertFunction(tenant, code, request);
        Json payload = Json.emptyObject;
        payload["function"] = item.toJson();
        return payload;
    }

    Json deleteFunction(TenantContext tenant, string code) {
        _store.deleteFunction(tenant, code);
        Json payload = Json.emptyObject;
        payload["deleted"] = true;
        payload["code"] = code;
        return payload;
    }

    Json listTeams(TenantContext tenant) {
        Json list = Json.emptyArray;
        foreach (item; _store.listTeams(tenant)) list ~= item.toJson();

        Json payload = Json.emptyObject;
        payload["teams"] = list;
        payload["total"] = cast(long)list.length;
        return payload;
    }

    Json createTeam(TenantContext tenant, Json request) {
        auto item = _store.createTeam(tenant, request);
        Json payload = Json.emptyObject;
        payload["team"] = item.toJson();
        return payload;
    }

    Json getTeam(TenantContext tenant, string teamId) {
        auto item = _store.getTeam(tenant, teamId);
        Json payload = Json.emptyObject;
        payload["team"] = item.toJson();
        return payload;
    }

    Json updateTeam(TenantContext tenant, string teamId, Json request) {
        auto item = _store.updateTeam(tenant, teamId, request);
        Json payload = Json.emptyObject;
        payload["team"] = item.toJson();
        return payload;
    }

    Json deleteTeam(TenantContext tenant, string teamId) {
        _store.deleteTeam(tenant, teamId);
        Json payload = Json.emptyObject;
        payload["deleted"] = true;
        payload["team_id"] = teamId;
        return payload;
    }

    Json copyTeam(TenantContext tenant, string teamId, Json request) {
        auto copied = _store.copyTeam(tenant, teamId, getString(request, "name", ""));
        Json payload = Json.emptyObject;
        payload["team"] = copied.toJson();
        return payload;
    }

    Json listRules(TenantContext tenant) {
        Json list = Json.emptyArray;
        foreach (item; _store.listRules(tenant)) list ~= item.toJson();

        Json payload = Json.emptyObject;
        payload["rules"] = list;
        payload["total"] = cast(long)list.length;
        return payload;
    }

    Json createRule(TenantContext tenant, Json request) {
        auto item = _store.createRule(tenant, request);
        Json payload = Json.emptyObject;
        payload["rule"] = item.toJson();
        return payload;
    }

    Json getRule(TenantContext tenant, string ruleId) {
        auto item = _store.getRule(tenant, ruleId);
        Json payload = Json.emptyObject;
        payload["rule"] = item.toJson();
        return payload;
    }

    Json updateRule(TenantContext tenant, string ruleId, Json request) {
        auto item = _store.updateRule(tenant, ruleId, request);
        Json payload = Json.emptyObject;
        payload["rule"] = item.toJson();
        return payload;
    }

    Json deleteRule(TenantContext tenant, string ruleId) {
        _store.deleteRule(tenant, ruleId);
        Json payload = Json.emptyObject;
        payload["deleted"] = true;
        payload["rule_id"] = ruleId;
        return payload;
    }

    Json determine(TenantContext tenant, Json request) {
        return _store.determineAgents(tenant, request);
    }

    Json listLogs(TenantContext tenant, size_t limit = 100) {
        Json list = Json.emptyArray;
        foreach (item; _store.listLogs(tenant, limit)) list ~= item.toJson();

        Json payload = Json.emptyObject;
        payload["logs"] = list;
        payload["total"] = cast(long)list.length;
        return payload;
    }

    Json exportData(TenantContext tenant) {
        return _store.exportData(tenant);
    }

    private string getString(Json payload, string key, string fallback) {
        if (key in payload && payload[key].isString) {
            return payload[key].get!string;
        }
        return fallback;
    }
}
