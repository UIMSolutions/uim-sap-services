/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.aas.models.scaledecision;

import uim.sap.aas;
@safe:

struct AASScaleDecision {
    string appId;
    uint currentInstances;
    uint desiredInstances;
    string direction;
    string reason;
    double currentHourlyCost;
    double desiredHourlyCost;
    SysTime evaluatedAt;

    override Json toJson()  {
        Json payload = Json.emptyObject;
        payload["app_id"] = appId;
        payload["current_instances"] = cast(long)currentInstances;
        payload["desired_instances"] = cast(long)desiredInstances;
        payload["direction"] = direction;
        payload["reason"] = reason;
        payload["current_hourly_cost"] = currentHourlyCost;
        payload["desired_hourly_cost"] = desiredHourlyCost;
        payload["evaluated_at"] = evaluatedAt.toISOExtString();
        return payload;
    }
}
