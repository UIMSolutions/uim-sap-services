/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.rms.models.determinationlog;

import uim.sap.rms;

mixin(ShowModule!());

@safe:

class DeterminationLog : SAPTenantObject {
mixin(SAPEntityTemplate!DeterminationLog);

    UUID id;
    string timestamp;
    UUID spaceId;
    string contextType;
    string objectType;
    UUID documentId;
    string[] matchedRuleIds;
    UUID[] teamIds;
    string[] agents;
    string[] notifications;
    long durationMs;

    override Json toJson()  {
        Json rules = Json.emptyArray;
        foreach (item; matchedRuleIds) rules ~= item;

        Json teams = Json.emptyArray;
        foreach (item; teamIds) teams ~= item;

        Json users = Json.emptyArray;
        foreach (item; agents) users ~= item;

        Json noteList = Json.emptyArray;
        foreach (item; notifications) noteList ~= item;

        return super.toJson()
        .set("id", id)
        .set("timestamp", timestamp)
        .set("tenant_id", tenantId)
        .set("space_id", spaceId)
        .set("context_type", contextType)
        .set("object_type", objectType)
        .set("document_id", documentId)
        .set("matched_rule_ids", rules)
        .set("team_ids", teams)
        .set("agents", users)
        .set("notifications", noteList)
        .set("duration_ms", durationMs);
    }
}
