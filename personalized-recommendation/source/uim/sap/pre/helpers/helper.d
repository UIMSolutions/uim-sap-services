/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.pre.helpers.helper;

import uim.sap.pre;

mixin(ShowModule!());

@safe:

string generateItemId() {
    return "itm-" ~ randomUUID().toString();
}

string generateUserId() {
    return "usr-" ~ randomUUID().toString();
}

string generateInteractionId() {
    return "int-" ~ randomUUID().toString();
}

string generateModelId() {
    return "mdl-" ~ randomUUID().toString();
}

string generateScenarioId() {
    return "scn-" ~ randomUUID().toString();
}

string generateRecommendationId() {
    return "rec-" ~ randomUUID().toString();
}

string generateTrainingJobId() {
    return "trj-" ~ randomUUID().toString();
}

string generateTenantId() {
    return "tnt-" ~ randomUUID().toString();
}

string tenantKey(string tenantId, string resourceId) {
    return tenantId ~ "/" ~ resourceId;
}

