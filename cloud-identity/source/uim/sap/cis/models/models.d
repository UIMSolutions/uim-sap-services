module uim.sap.cis.models;

import std.datetime : Clock, SysTime;
import std.string : toLower;
import std.uuid : randomUUID;

import vibe.data.json : Json;

enum string[] CIS_AUTH_METHODS = ["form", "spnego", "social", "2fa"];
enum string[] CIS_SSO_PROTOCOLS = ["openid-connect", "saml2"];

string createId() {
    return randomUUID().toString();
}






struct CISRiskPolicy {
    string tenantId;
    string policyId;
    Json ipRanges;
    Json groups;
    string userType;
    string authenticationMethod;
    bool requireTwoFactor = true;
    SysTime updatedAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["policy_id"] = policyId;
        payload["tenant_id"] = tenantId;
        payload["ip_ranges"] = ipRanges;
        payload["groups"] = groups;
        payload["user_type"] = userType;
        payload["authentication_method"] = authenticationMethod;
        payload["require_two_factor"] = requireTwoFactor;
        payload["updated_at"] = updatedAt.toISOExtString();
        return payload;
    }
}

struct CISProvisioningJob {
    string tenantId;
    string jobId;
    string sourceSystem;
    string targetSystem;
    string mode;
    string status;
    Json filters;
    SysTime createdAt;
    SysTime updatedAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["job_id"] = jobId;
        payload["tenant_id"] = tenantId;
        payload["source_system"] = sourceSystem;
        payload["target_system"] = targetSystem;
        payload["mode"] = mode;
        payload["status"] = status;
        payload["filters"] = filters;
        payload["created_at"] = createdAt.toISOExtString();
        payload["updated_at"] = updatedAt.toISOExtString();
        return payload;
    }
}



struct CISNotificationSubscription {
    string tenantId;
    string subscriptionId;
    string sourceSystem;
    string callbackUrl;
    SysTime updatedAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["subscription_id"] = subscriptionId;
        payload["tenant_id"] = tenantId;
        payload["source_system"] = sourceSystem;
        payload["callback_url"] = callbackUrl;
        payload["updated_at"] = updatedAt.toISOExtString();
        return payload;
    }
}

CISUser userFromJson(string tenantId, Json request) {
    CISUser user;
    user.tenantId = tenantId;
    user.userId = createId();
    user.createdAt = Clock.currTime();
    user.updatedAt = user.createdAt;
    user.groups = Json.emptyArray;
    user.attributes = Json.emptyObject;

    if ("id" in request && request["id"].type == Json.Type.string) user.userId = request["id"].get!string;
    if ("userName" in request && request["userName"].type == Json.Type.string) user.userName = request["userName"].get!string;
    if ("email" in request && request["email"].type == Json.Type.string) user.email = request["email"].get!string;
    if ("user_type" in request && request["user_type"].type == Json.Type.string) user.userType = request["user_type"].get!string;
    if ("active" in request && request["active"].type == Json.Type.bool_) user.active = request["active"].get!bool;
    if ("groups" in request && request["groups"].type == Json.Type.array) user.groups = request["groups"];
    if ("attributes" in request && request["attributes"].type == Json.Type.object) user.attributes = request["attributes"];

    return user;
}

CISGroup groupFromJson(string tenantId, Json request) {
    CISGroup group;
    group.tenantId = tenantId;
    group.groupId = createId();
    group.updatedAt = Clock.currTime();
    group.members = Json.emptyArray;

    if ("id" in request && request["id"].type == Json.Type.string) group.groupId = request["id"].get!string;
    if ("displayName" in request && request["displayName"].type == Json.Type.string) group.displayName = request["displayName"].get!string;
    if ("members" in request && request["members"].type == Json.Type.array) group.members = request["members"];

    return group;
}

string normalizeMode(string mode) {
    auto value = toLower(mode);
    return (value == "delta") ? "delta" : "full";
}
