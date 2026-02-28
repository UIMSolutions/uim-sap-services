module uim.sap.aem.models.eventmesh;

import uim.sap.aem;

mixin(ShowModule!());

@safe:


struct AEMEventMesh {
    string tenantId;
    string meshId;
    string brokerServiceId;
    string name;
    string[] topics;
    SysTime createdAt;
    SysTime updatedAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        Json topicsJson = Json.emptyArray;
        foreach (topic; topics) {
            topicsJson ~= topic;
        }

        payload["tenant_id"] = tenantId;
        payload["mesh_id"] = meshId;
        payload["broker_service_id"] = brokerServiceId;
        payload["name"] = name;
        payload["topics"] = topicsJson;
        payload["created_at"] = createdAt.toISOExtString();
        payload["updated_at"] = updatedAt.toISOExtString();
        return payload;
    }
}

AEMEventMesh meshFromJson(string tenantId, string brokerServiceId, Json request) {
    AEMEventMesh mesh;
    mesh.tenantId = tenantId;
    mesh.meshId = randomUUID().toString();
    mesh.brokerServiceId = brokerServiceId;
    mesh.createdAt = Clock.currTime();
    mesh.updatedAt = mesh.createdAt;

    if ("mesh_id" in request && request["mesh_id"].type == Json.Type.string) {
        mesh.meshId = request["mesh_id"].get!string;
    }
    if ("name" in request && request["name"].type == Json.Type.string) {
        mesh.name = request["name"].get!string;
    }
    if ("topics" in request && request["topics"].type == Json.Type.array) {
        foreach (topicJson; request["topics"].get!(Json[])) {
            if (topicJson.type == Json.Type.string) {
                mesh.topics ~= topicJson.get!string;
            }
        }
    }

    return mesh;
}