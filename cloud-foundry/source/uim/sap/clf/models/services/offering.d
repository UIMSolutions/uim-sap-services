/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.clf.models.services.offering;

import uim.sap.clf;

mixin(ShowModule!());

@safe:

struct CLFServiceOffering {
    string guid;
    string label;
    string provider;
    string description;

    override Json toJson()  {
        Json payload = Json.emptyObject;
        payload["guid"] = guid;
        payload["label"] = label;
        payload["provider"] = provider;
        payload["description"] = description;
        return payload;
    }
}
