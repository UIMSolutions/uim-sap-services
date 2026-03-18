/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.rms.models.responsibilityrule;

import uim.sap.rms;

mixin(ShowModule!());

@safe:

class ResponsibilityRule : SAPObject {
	mixin(SAPObjectTemplate!ResponsibilityRule);

    UUID id;
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
  
    override Json toJson()  {
        return super.toJson
        .set("id", id)
        .set("name", name)
        .set("context_type", contextType)
        .set("object_type", objectType)
        .set("mode", modeToString(mode))
        .set("condition_field", conditionField)
        .set("condition_equals", conditionEquals)
        .set("external_api_ref", externalApiRef)
        .set("team_id", teamId)
        .set("function_code", functionCode)
        .set("enabled", enabled)
        .set("priority", priority);
    }
}