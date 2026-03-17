/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.clf.models.org;

import uim.sap.clf;

mixin(ShowModule!());

@safe:
struct CLFOrg {
    string guid;
    string name;
    SysTime createdAt;

    override Json toJson()  {
        Json payload = Json.emptyObject;
        payload["guid"] = guid;
        payload["name"] = name;
        payload["created_at"] = createdAt.toISOExtString();
        return payload;
    }
}

CLFOrg orgFromJson(Json payload) {
    CLFOrg org;
    org.guid = randomUUID().toString();
    org.createdAt = Clock.currTime();
    if ("name" in payload && payload["name"].isString) {
        org.name = payload["name"].get!string;
    }
    return org;
}