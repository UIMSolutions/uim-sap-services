module uim.sap.obs.models.bucketpolicy;

import std.datetime : Clock, SysTime;

import vibe.data.json : Json;

@safe:

/// Access policy for a bucket
struct OBSBucketPolicy {
    string policyId;
    string bucketId;
    string name;
    string[] allowedActions;   // e.g. ["GetObject", "PutObject", "DeleteObject"]
    string[] allowedPrefixes;  // key prefixes this policy applies to
    string[] principals;       // user/service IDs granted access
    bool allowPublicRead;
    SysTime createdAt;
    SysTime updatedAt;

    Json toJson() const {
        Json j = Json.emptyObject;
        j["policy_id"] = policyId;
        j["bucket_id"] = bucketId;
        j["name"] = name;

        Json actions = Json.emptyArray;
        foreach (a; allowedActions) actions ~= Json(a);
        j["allowed_actions"] = actions;

        Json prefixes = Json.emptyArray;
        foreach (p; allowedPrefixes) prefixes ~= Json(p);
        j["allowed_prefixes"] = prefixes;

        Json prins = Json.emptyArray;
        foreach (p; principals) prins ~= Json(p);
        j["principals"] = prins;

        j["allow_public_read"] = allowPublicRead;
        j["created_at"] = createdAt.toISOExtString();
        j["updated_at"] = updatedAt.toISOExtString();
        return j;
    }
}

OBSBucketPolicy policyFromJson(string policyId, string bucketId, Json req) {
    OBSBucketPolicy p;
    p.policyId = policyId;
    p.bucketId = bucketId;
    p.createdAt = Clock.currTime();
    p.updatedAt = p.createdAt;

    if ("name" in req && req["name"].isString)
        p.name = req["name"].get!string;
    if ("allowed_actions" in req && req["allowed_actions"].type == Json.Type.array) {
        foreach (v; req["allowed_actions"])
            if (v.isString) p.allowedActions ~= v.get!string;
    }
    if ("allowed_prefixes" in req && req["allowed_prefixes"].type == Json.Type.array) {
        foreach (v; req["allowed_prefixes"])
            if (v.isString) p.allowedPrefixes ~= v.get!string;
    }
    if ("principals" in req && req["principals"].type == Json.Type.array) {
        foreach (v; req["principals"])
            if (v.isString) p.principals ~= v.get!string;
    }
    if ("allow_public_read" in req && req["allow_public_read"].type == Json.Type.bool_)
        p.allowPublicRead = req["allow_public_read"].get!bool;
    return p;
}
