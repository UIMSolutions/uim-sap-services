module uim.sap.pdm.models.tenant;

import uim.sap.pdm;

mixin(ShowModule!());

@safe:

/// Tenant in a multitenant deployment
struct PDMTenant {
    string tenantId;
    string name;
    string description;
    string contactEmail;
    bool active = true;

    size_t subjectCount;     // tracked subjects
    size_t requestCount;     // active requests

    string[string] metadata;
    SysTime createdAt;
    SysTime updatedAt;

    Json toJson() const {
        Json j = Json.emptyObject;
        j["tenant_id"] = tenantId;
        j["name"] = name;
        j["description"] = description;
        j["contact_email"] = contactEmail;
        j["active"] = active;

        import std.conv : to;
        j["subject_count"] = subjectCount.to!long;
        j["request_count"] = requestCount.to!long;

        if (metadata.length > 0) {
            Json m = Json.emptyObject;
            foreach (k, v; metadata) m[k] = v;
            j["metadata"] = m;
        }
        j["created_at"] = createdAt.toISOExtString();
        j["updated_at"] = updatedAt.toISOExtString();
        return j;
    }
}

PDMTenant tenantFromJson(string tenantId, Json req) {
    PDMTenant t;
    t.tenantId = tenantId;
    t.createdAt = Clock.currTime();
    t.updatedAt = t.createdAt;

    if ("name" in req && req["name"].isString)
        t.name = req["name"].get!string;
    else
        t.name = tenantId;
    if ("description" in req && req["description"].isString)
        t.description = req["description"].get!string;
    if ("contact_email" in req && req["contact_email"].isString)
        t.contactEmail = req["contact_email"].get!string;
    if ("metadata" in req && req["metadata"].type == Json.Type.object) {
        foreach (string k, v; req["metadata"])
            if (v.isString) t.metadata[k] = v.get!string;
    }
    return t;
}
