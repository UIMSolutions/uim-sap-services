/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.rms.models.responsibilityrule;

import uim.sap.rms;

mixin(ShowModule!());

@safe:

struct ResponsibilityRule {
    string id;
    string name;
    string contextType;
    string objectType;
    RuleMode mode;
    string conditionField;
    string conditionEquals;
    string externalApiRef;
    string teamId;
    string functionCode;
    bool enabled;
    int priority;
    string createdAt;
    string updatedAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["id"] = id;
        payload["name"] = name;
        payload["context_type"] = contextType;
        payload["object_type"] = objectType;
        payload["mode"] = modeToString(mode);
        payload["condition_field"] = conditionField;
        payload["condition_equals"] = conditionEquals;
        payload["external_api_ref"] = externalApiRef;
        payload["team_id"] = teamId;
        payload["function_code"] = functionCode;
        payload["enabled"] = enabled;
        payload["priority"] = priority;
        payload["created_at"] = createdAt;
        payload["updated_at"] = updatedAt;
        return payload;
    }
}