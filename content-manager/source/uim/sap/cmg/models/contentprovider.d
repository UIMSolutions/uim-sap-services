/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.cmg.models.contentprovider;

import uim.sap.cmg;

mixin(ShowModule!());

@safe:

struct CMGContentProvider {
    string tenantId;
    string providerId;
    string name;
    string providerType;
    string endpoint;
    string[] exposedTypes;
    bool active;
    SysTime createdAt;
    SysTime updatedAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["tenant_id"] = tenantId;
        payload["provider_id"] = providerId;
        payload["name"] = name;
        payload["provider_type"] = providerType;
        payload["endpoint"] = endpoint;

        Json typeValues = Json.emptyArray;
        foreach (t; exposedTypes) typeValues ~= t;
        payload["exposed_types"] = typeValues;

        payload["active"] = active;
        payload["created_at"] = createdAt.toISOExtString();
        payload["updated_at"] = updatedAt.toISOExtString();
        return payload;
    }
}
