module uim.sap.identityprovisioning.models.user;

import uim.sap.identityprovisioning;

mixin(ShowModule!());

@safe:

/** A user identity that is provisioned between systems. */
struct IPUser {
    string tenantId;
    string userId;
    string externalId;        // ID in the external system
    string userName;
    string email;
    string firstName;
    string lastName;
    string displayName;
    bool active = true;
    string[] groupIds;        // groups this user belongs to
    string sourceSystemId;    // which system this user was read from
    string status = "synced"; // "synced" | "pending" | "error" | "skipped"
    string lastModifiedAt;
    string createdAt;
    string updatedAt;

    Json toJson() const {
        Json j = Json.emptyObject;
        j["tenant_id"] = tenantId;
        j["user_id"] = userId;
        j["external_id"] = externalId;
        j["user_name"] = userName;
        j["email"] = email;
        j["first_name"] = firstName;
        j["last_name"] = lastName;
        j["display_name"] = displayName;
        j["active"] = active;

        Json gids = Json.emptyArray;
        foreach (gid; groupIds) {
            gids ~= Json(gid);
        }
        j["group_ids"] = gids;

        j["source_system_id"] = sourceSystemId;
        j["status"] = status;
        j["last_modified_at"] = lastModifiedAt;
        j["created_at"] = createdAt;
        j["updated_at"] = updatedAt;
        return j;
    }
}

IPUser userFromJson(string tenantId, Json request) {
    IPUser u;
    u.tenantId = tenantId;
    u.userId = randomUUID().toString();

    if ("user_name" in request && request["user_name"].type == Json.Type.string)
        u.userName = request["user_name"].get!string;
    if ("external_id" in request && request["external_id"].type == Json.Type.string)
        u.externalId = request["external_id"].get!string;
    if ("email" in request && request["email"].type == Json.Type.string)
        u.email = request["email"].get!string;
    if ("first_name" in request && request["first_name"].type == Json.Type.string)
        u.firstName = request["first_name"].get!string;
    if ("last_name" in request && request["last_name"].type == Json.Type.string)
        u.lastName = request["last_name"].get!string;
    if ("display_name" in request && request["display_name"].type == Json.Type.string)
        u.displayName = request["display_name"].get!string;
    if ("active" in request && request["active"].type == Json.Type.bool_)
        u.active = request["active"].get!bool;
    if ("source_system_id" in request && request["source_system_id"].type == Json.Type.string)
        u.sourceSystemId = request["source_system_id"].get!string;
    if ("status" in request && request["status"].type == Json.Type.string)
        u.status = request["status"].get!string;
    if ("user_id" in request && request["user_id"].type == Json.Type.string)
        u.userId = request["user_id"].get!string;

    if ("group_ids" in request && request["group_ids"].type == Json.Type.array) {
        () @trusted {
            foreach (item; request["group_ids"]) {
                if (item.type == Json.Type.string)
                    u.groupIds ~= item.get!string;
            }
        }();
    }

    u.createdAt = Clock.currTime().toISOExtString();
    u.updatedAt = u.createdAt;
    u.lastModifiedAt = u.createdAt;
    return u;
}
