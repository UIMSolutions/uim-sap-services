/**
 * Models for CLF service
 */
module uim.sap.clf.models;

import uim.sap.clf;

mixin(ShowModule!());

@safe:









CLFOrg orgFromJson(Json payload) {
    CLFOrg org;
    org.guid = randomUUID().toString();
    org.createdAt = Clock.currTime();
    if ("name" in payload && payload["name"].type == Json.Type.string) {
        org.name = payload["name"].get!string;
    }
    return org;
}

CLFSpace spaceFromJson(Json payload) {
    CLFSpace space;
    space.guid = randomUUID().toString();
    space.createdAt = Clock.currTime();
    if ("name" in payload && payload["name"].type == Json.Type.string) {
        space.name = payload["name"].get!string;
    }
    if ("organization_guid" in payload && payload["organization_guid"].type == Json.Type.string) {
        space.organizationGuid = payload["organization_guid"].get!string;
    }
    return space;
}

CLFApp appFromJson(Json payload) {
    CLFApp app;
    app.guid = randomUUID().toString();
    app.createdAt = Clock.currTime();
    if ("name" in payload && payload["name"].type == Json.Type.string) {
        app.name = payload["name"].get!string;
    }
    if ("space_guid" in payload && payload["space_guid"].type == Json.Type.string) {
        app.spaceGuid = payload["space_guid"].get!string;
    }
    if ("state" in payload && payload["state"].type == Json.Type.string) {
        app.state = payload["state"].get!string;
    }
    if ("instances" in payload && payload["instances"].type == Json.Type.int_) {
        auto parsed = payload["instances"].get!long;
        if (parsed > 0) {
            app.instances = cast(uint)parsed;
        }
    }
    if ("memory_mb" in payload && payload["memory_mb"].type == Json.Type.int_) {
        auto parsed = payload["memory_mb"].get!long;
        if (parsed > 0) {
            app.memoryMb = cast(uint)parsed;
        }
    }
    return app;
}

CLFServiceInstance serviceInstanceFromJson(Json payload) {
    CLFServiceInstance instance;
    instance.guid = randomUUID().toString();
    instance.createdAt = Clock.currTime();
    if ("name" in payload && payload["name"].type == Json.Type.string) {
        instance.name = payload["name"].get!string;
    }
    if ("service_guid" in payload && payload["service_guid"].type == Json.Type.string) {
        instance.serviceGuid = payload["service_guid"].get!string;
    }
    if ("space_guid" in payload && payload["space_guid"].type == Json.Type.string) {
        instance.spaceGuid = payload["space_guid"].get!string;
    }
    return instance;
}
