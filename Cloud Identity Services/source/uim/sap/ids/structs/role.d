/**
 * Role models for SAP Cloud Identity Services
 * 
 * Copyright: Copyright © 2018-2026, Ozan Nurettin Süel
 * License: Apache-2.0
 * Authors: Ozan Nurettin Süel
 */
module uim.sap.ids.structs.role;

import vibe.data.json;
import std.datetime : SysTime;

/**
 * Role assignment
 */
struct RoleAssignment {
    string roleId;
    string roleName;
    string userId;
    string userName;
    SysTime assignedAt;
    string assignedBy;
}

/**
 * Role definition
 */
struct Role {
    string id;
    string name;
    string description;
    string[] permissions;
    bool isSystemRole;
    SysTime createdAt;
    SysTime modifiedAt;
    
    /**
     * Convert to JSON
     */
    Json toJson() const {
        Json json = Json.emptyObject;
        
        if (id.length > 0) {
            json["id"] = id;
        }
        
        json["name"] = name;
        
        if (description.length > 0) {
            json["description"] = description;
        }
        
        if (permissions.length > 0) {
            json["permissions"] = Json(permissions);
        }
        
        json["isSystemRole"] = isSystemRole;
        
        return json;
    }
    
    /**
     * Create from JSON
     */
    static Role fromJson(Json json) {
        Role role;
        
        if ("id" in json) {
            role.id = json["id"].get!string;
        }
        
        if ("name" in json) {
            role.name = json["name"].get!string;
        }
        
        if ("description" in json) {
            role.description = json["description"].get!string;
        }
        
        if ("isSystemRole" in json) {
            role.isSystemRole = json["isSystemRole"].get!bool;
        }
        
        if ("permissions" in json && json["permissions"].type == Json.Type.array) {
            foreach (perm; json["permissions"]) {
                role.permissions ~= perm.get!string;
            }
        }
        
        return role;
    }
}
