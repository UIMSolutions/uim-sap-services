module uim.sap.mob.models.application;


import uim.sap.mob;

mixin(ShowModule!());

@safe:


/// Mobile application definition
struct MOBApplication {
    string appId;
    string name;
    string description;
    MOBAppType appType = MOBAppType.NATIVE;
    MOBPlatform platform = MOBPlatform.IOS;
    MOBAppStatus status = MOBAppStatus.DRAFT;
    MOBSdkType sdkType = MOBSdkType.MDK;
    string bundleId;          // e.g. com.sap.myapp
    string backendUrl;        // OData/REST backend endpoint
    string activeVersion;
    string[string] metadata;
    SysTime createdAt;
    SysTime updatedAt;

    override Json toJson()  {
        Json j = Json.emptyObject;
        j["app_id"] = appId;
        j["name"] = name;
        j["description"] = description;
        j["app_type"] = cast(string) appType;
        j["platform"] = cast(string) platform;
        j["status"] = cast(string) status;
        j["sdk_type"] = cast(string) sdkType;
        j["bundle_id"] = bundleId;
        j["backend_url"] = backendUrl;
        j["active_version"] = activeVersion;
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

MOBApplication applicationFromJson(string appId, Json req) {
    MOBApplication app;
    app.appId = appId;
    app.createdAt = Clock.currTime();
    app.updatedAt = app.createdAt;

    if ("name" in req && req["name"].isString)
        app.name = req["name"].get!string;
    else
        app.name = appId;
    if ("description" in req && req["description"].isString)
        app.description = req["description"].get!string;
    if ("app_type" in req && req["app_type"].isString)
        app.appType = parseAppType(req["app_type"].get!string);
    if ("platform" in req && req["platform"].isString)
        app.platform = parsePlatform(req["platform"].get!string);
    if ("sdk_type" in req && req["sdk_type"].isString)
        app.sdkType = parseSdkType(req["sdk_type"].get!string);
    if ("bundle_id" in req && req["bundle_id"].isString)
        app.bundleId = req["bundle_id"].get!string;
    if ("backend_url" in req && req["backend_url"].isString)
        app.backendUrl = req["backend_url"].get!string;
    if ("metadata" in req && req["metadata"].type == Json.Type.object) {
        foreach (string k, v; req["metadata"])
            if (v.isString) app.metadata[k] = v.get!string;
    }
    return app;
}

private MOBSdkType parseSdkType(string s) {
    switch (s) {
        case "mdk": return MOBSdkType.MDK;
        case "ios": return MOBSdkType.IOS;
        case "android": return MOBSdkType.ANDROID;
        default: return MOBSdkType.MDK;
    }
}
