/**
 * OData Service model — OData Provisioning
 *
 * Represents an OData endpoint exposing SAP Business Suite data.
 */
module uim.sap.integrationsuite.models.odata_service;

import uim.sap.integrationsuite;

mixin(ShowModule!());

@safe:

struct ISODataService {
    string tenantId;
    string serviceId;
    string name;
    string description;
    string serviceUrl;
    string odataVersion = "V2";      // V2 | V4
    string backendSystem;             // e.g. ECC, S/4HANA
    string[] entitySets;
    string status = "active";         // active | inactive | error
    long queryCount = 0;
    string createdAt;
    string updatedAt;

    Json toJson() const {
        Json j = Json.emptyObject;
        j["tenant_id"] = tenantId;
        j["service_id"] = serviceId;
        j["name"] = name;
        j["description"] = description;
        j["service_url"] = serviceUrl;
        j["odata_version"] = odataVersion;
        j["backend_system"] = backendSystem;

        Json sets = Json.emptyArray;
        foreach (s; entitySets) sets ~= Json(s);
        j["entity_sets"] = sets;

        j["status"] = status;
        j["query_count"] = queryCount;
        j["created_at"] = createdAt;
        j["updated_at"] = updatedAt;
        return j;
    }
}

ISODataService odataServiceFromJson(string tenantId, Json request) {
    ISODataService svc;
    svc.tenantId = tenantId;
    svc.serviceId = randomUUID().toString();

    if ("name" in request && request["name"].type == Json.Type.string)
        svc.name = request["name"].get!string;
    if ("description" in request && request["description"].type == Json.Type.string)
        svc.description = request["description"].get!string;
    if ("service_url" in request && request["service_url"].type == Json.Type.string)
        svc.serviceUrl = request["service_url"].get!string;
    if ("odata_version" in request && request["odata_version"].type == Json.Type.string)
        svc.odataVersion = request["odata_version"].get!string;
    if ("backend_system" in request && request["backend_system"].type == Json.Type.string)
        svc.backendSystem = request["backend_system"].get!string;
    if ("entity_sets" in request && request["entity_sets"].type == Json.Type.array) {
        foreach (item; request["entity_sets"]) {
            if (item.type == Json.Type.string)
                svc.entitySets ~= item.get!string;
        }
    }

    svc.createdAt = Clock.currTime().toISOExtString();
    svc.updatedAt = svc.createdAt;
    return svc;
}
