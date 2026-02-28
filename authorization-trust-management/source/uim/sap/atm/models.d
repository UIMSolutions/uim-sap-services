module uim.sap.atm.models;

import std.datetime : Clock, SysTime;
import std.uuid : randomUUID;

import vibe.data.json : Json;

struct ATMIdentityProvider {
    string tenantId;
    string idpId;
    string name;
    string providerType = "oidc";
    string issuer;
    string audience;
    string description;
    bool enabled = true;
    bool isDefault = false;
    string[] trustedAlgorithms;
    SysTime updatedAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        Json trusted = Json.emptyArray;
        foreach (algorithm; trustedAlgorithms) {
            trusted ~= algorithm;
        }

        payload["tenant_id"] = tenantId;
        payload["idp_id"] = idpId;
        payload["name"] = name;
        payload["provider_type"] = providerType;
        payload["issuer"] = issuer;
        payload["audience"] = audience;
        payload["description"] = description;
        payload["enabled"] = enabled;
        payload["is_default"] = isDefault;
        payload["trusted_algorithms"] = trusted;
        payload["updated_at"] = updatedAt.toISOExtString();
        return payload;
    }
}

struct ATMTechnicalRole {
    string tenantId;
    string roleId;
    string name;
    string description;
    string[] permissions;
    SysTime updatedAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        Json perms = Json.emptyArray;
        foreach (permission; permissions) {
            perms ~= permission;
        }

        payload["tenant_id"] = tenantId;
        payload["role_id"] = roleId;
        payload["name"] = name;
        payload["description"] = description;
        payload["permissions"] = perms;
        payload["updated_at"] = updatedAt.toISOExtString();
        return payload;
    }
}

struct ATMRoleCollection {
    string tenantId;
    string collectionId;
    string name;
    string description;
    string[] technicalRoleIds;
    SysTime updatedAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        Json roleRefs = Json.emptyArray;
        foreach (roleId; technicalRoleIds) {
            roleRefs ~= roleId;
        }

        payload["tenant_id"] = tenantId;
        payload["collection_id"] = collectionId;
        payload["name"] = name;
        payload["description"] = description;
        payload["technical_role_ids"] = roleRefs;
        payload["updated_at"] = updatedAt.toISOExtString();
        return payload;
    }
}

struct ATMUserAssignment {
    string tenantId;
    string userId;
    string idpId;
    string[] roleCollectionIds;
    SysTime updatedAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        Json refs = Json.emptyArray;
        foreach (roleCollectionId; roleCollectionIds) {
            refs ~= roleCollectionId;
        }

        payload["tenant_id"] = tenantId;
        payload["user_id"] = userId;
        payload["idp_id"] = idpId;
        payload["role_collection_ids"] = refs;
        payload["updated_at"] = updatedAt.toISOExtString();
        return payload;
    }
}

struct ATMSessionContext {
    string tenantId;
    string userId;
    string idpId;
    string issuer;
    string audience;
    string email;
    string[] groups;
    string[] scopes;
    string[] roleCollections;
    string[] technicalRoles;
    string[] permissions;
    bool bootstrap;
    SysTime authenticatedAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["tenant_id"] = tenantId;
        payload["user_id"] = userId;
        payload["idp_id"] = idpId;
        payload["issuer"] = issuer;
        payload["audience"] = audience;
        payload["email"] = email;
        payload["bootstrap"] = bootstrap;
        payload["authenticated_at"] = authenticatedAt.toISOExtString();
        payload["groups"] = asJsonArray(groups);
        payload["scopes"] = asJsonArray(scopes);
        payload["role_collections"] = asJsonArray(roleCollections);
        payload["technical_roles"] = asJsonArray(technicalRoles);
        payload["permissions"] = asJsonArray(permissions);
        return payload;
    }
}

ATMIdentityProvider idpFromJson(string tenantId, string idpId, Json request) {
    ATMIdentityProvider idp;
    idp.tenantId = tenantId;
    idp.idpId = idpId.length > 0 ? idpId : randomUUID().toString();
    idp.name = idp.idpId;
    idp.trustedAlgorithms = ["RS256", "ES256", "HS256", "none"];
    idp.updatedAt = Clock.currTime();

    if ("name" in request && request["name"].isString) {
        idp.name = request["name"].get!string;
    }
    if ("provider_type" in request && request["provider_type"].isString) {
        idp.providerType = request["provider_type"].get!string;
    }
    if ("issuer" in request && request["issuer"].isString) {
        idp.issuer = request["issuer"].get!string;
    }
    if ("audience" in request && request["audience"].isString) {
        idp.audience = request["audience"].get!string;
    }
    if ("description" in request && request["description"].isString) {
        idp.description = request["description"].get!string;
    }
    if ("enabled" in request && request["enabled"].isBoolean) {
        idp.enabled = request["enabled"].get!bool;
    }
    if ("is_default" in request && request["is_default"].isBoolean) {
        idp.isDefault = request["is_default"].get!bool;
    }
    if ("trusted_algorithms" in request && request["trusted_algorithms"].type == Json.Type.array) {
        idp.trustedAlgorithms = stringArrayFromJson(request["trusted_algorithms"]);
    }

    return idp;
}

ATMTechnicalRole technicalRoleFromJson(string tenantId, string roleId, Json request) {
    ATMTechnicalRole role;
    role.tenantId = tenantId;
    role.roleId = roleId.length > 0 ? roleId : randomUUID().toString();
    role.name = role.roleId;
    role.updatedAt = Clock.currTime();

    if ("name" in request && request["name"].isString) {
        role.name = request["name"].get!string;
    }
    if ("description" in request && request["description"].isString) {
        role.description = request["description"].get!string;
    }
    if ("permissions" in request && request["permissions"].type == Json.Type.array) {
        role.permissions = stringArrayFromJson(request["permissions"]);
    }

    return role;
}

ATMRoleCollection roleCollectionFromJson(string tenantId, string collectionId, Json request) {
    ATMRoleCollection collection;
    collection.tenantId = tenantId;
    collection.collectionId = collectionId.length > 0 ? collectionId : randomUUID().toString();
    collection.name = collection.collectionId;
    collection.updatedAt = Clock.currTime();

    if ("name" in request && request["name"].isString) {
        collection.name = request["name"].get!string;
    }
    if ("description" in request && request["description"].isString) {
        collection.description = request["description"].get!string;
    }
    if ("technical_role_ids" in request && request["technical_role_ids"].type == Json.Type.array) {
        collection.technicalRoleIds = stringArrayFromJson(request["technical_role_ids"]);
    }

    return collection;
}

ATMUserAssignment userAssignmentFromJson(string tenantId, string userId, Json request) {
    ATMUserAssignment assignment;
    assignment.tenantId = tenantId;
    assignment.userId = userId;
    assignment.updatedAt = Clock.currTime();

    if ("idp_id" in request && request["idp_id"].isString) {
        assignment.idpId = request["idp_id"].get!string;
    }
    if ("role_collection_ids" in request && request["role_collection_ids"].type == Json.Type.array) {
        assignment.roleCollectionIds = stringArrayFromJson(request["role_collection_ids"]);
    }

    return assignment;
}

string[] stringArrayFromJson(Json values) {
    string[] result;
    if (values.type != Json.Type.array) {
        return result;
    }

    foreach (item; values.get!(Json[])) {
        if (item.isString) {
            result ~= item.get!string;
        }
    }
    return result;
}

Json asJsonArray(const(string)[] items) {
    Json result = Json.emptyArray;
    foreach (item; items) {
        result ~= item;
    }
    return result;
}
