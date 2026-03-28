/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.pdm.models.tenant;

import uim.sap.pdm;

mixin(ShowModule!());

@safe:

/// Tenant in a multitenant deployment
class PDMTenant : SAPTenantObject {
  mixin(SAPTenantObjectTemplate!PDMTenant);

    string name;
    string description;
    string contactEmail;
    bool active = true;

    size_t subjectCount;     // tracked subjects
    size_t requestCount;     // active requests

    string[string] metadata;

    override Json toJson()  {
        Json json = super.toJson
        .set("name", name)
        .set("description", description)
        .set("contact_email", contactEmail)
        .set("active", active)
        .set("subject_count", subjectCount.to!long)
        .set("request_count", requestCount.to!long);

        if (metadata.length > 0) {
            Json m = Json.emptyObject;
            foreach (k, v; metadata) m[k] = v;
            json["metadata"] = m;
        }

        return json;
    }

    static PDMTenant opCall(UUID tenantId, Json req) {
    PDMTenant t = new PDMTenant(req);
    t.tenantId = tenantId;
    t.createdAt = Clock.currTime();
    t.updatedAt = t.createdAt;

    t.name = "name" in req && req["name"].isString 
      ? req["name"].get!string : tenantId.toString;
    if ("description" in req && req["description"].isString)
        t.description = req["description"].getString;
    if ("contact_email" in req && req["contact_email"].isString)
        t.contactEmail = req["contact_email"].getString;
    if ("metadata" in req && req["metadata"].type == Json.Type.object) {
        foreach (string k, v; req["metadata"].toMap)
            if (v.isString) t.metadata[k] = v.getString;
    }

    return t;
}

}

