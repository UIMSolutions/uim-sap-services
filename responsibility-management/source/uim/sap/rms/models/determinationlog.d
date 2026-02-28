/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.rms.models.determinationlog;

struct DeterminationLog {
    string id;
    string timestamp;
    string tenantId;
    string spaceId;
    string contextType;
    string objectType;
    string documentId;
    string[] matchedRuleIds;
    string[] teamIds;
    string[] agents;
    string[] notifications;
    long durationMs;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["id"] = id;
        payload["timestamp"] = timestamp;
        payload["tenant_id"] = tenantId;
        payload["space_id"] = spaceId;
        payload["context_type"] = contextType;
        payload["object_type"] = objectType;
        payload["document_id"] = documentId;

        Json rules = Json.emptyArray;
        foreach (item; matchedRuleIds) rules ~= item;
        payload["matched_rule_ids"] = rules;

        Json teams = Json.emptyArray;
        foreach (item; teamIds) teams ~= item;
        payload["team_ids"] = teams;

        Json users = Json.emptyArray;
        foreach (item; agents) users ~= item;
        payload["agents"] = users;

        Json noteList = Json.emptyArray;
        foreach (item; notifications) noteList ~= item;
        payload["notifications"] = noteList;

        payload["duration_ms"] = durationMs;
        return payload;
    }
}
