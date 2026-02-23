/**
 * Group models for SAP Cloud Identity Services
 * 
 * Copyright: Copyright © 2018-2026, Ozan Nurettin Süel
 * License: Apache-2.0
 * Authors: Ozan Nurettin Süel
 */
module uim.sap.ids.structs.group;

import uim.sap.ids;
@safe:

/**
 * Group member reference
 */
struct GroupMember {
    string value;      // User ID
    string display;    // Display name
    string type = "User";
    string ref_;       // Reference URL
}

/**
 * Group metadata
 */
struct GroupMeta {
    SysTime created;
    SysTime lastModified;
    string location;
    string resourceType = "Group";
    string version_;
}

/**
 * Group representation in SAP Cloud Identity Services (SCIM 2.0 compliant)
 */
struct Group {
    /// Unique identifier
    string id;
    
    /// External identifier
    string externalId;
    
    /// Display name (required)
    string displayName;
    
    /// Members of the group
    GroupMember[] members;
    
    /// Metadata
    GroupMeta meta;
    
    /**
     * Convert group to JSON for API requests
     */
    Json toJson() const {
        Json json = Json.emptyObject;
        
        json["schemas"] = Json(["urn:ietf:params:scim:schemas:core:2.0:Group"]);
        
        if (id.length > 0) {
            json["id"] = id;
        }
        
        if (externalId.length > 0) {
            json["externalId"] = externalId;
        }
        
        json["displayName"] = displayName;
        
        if (members.length > 0) {
            Json[] membersJson;
            foreach (member; members) {
                auto memberJson = Json.emptyObject;
                memberJson["value"] = member.value;
                if (member.display.length > 0) {
                    memberJson["display"] = member.display;
                }
                memberJson["type"] = member.type;
                membersJson ~= memberJson;
            }
            json["members"] = Json(membersJson);
        }
        
        return json;
    }
    
    /**
     * Create group from JSON response
     */
    static Group fromJson(Json json) {
        Group group;
        
        if ("id" in json) {
            group.id = json["id"].get!string;
        }
        
        if ("externalId" in json) {
            group.externalId = json["externalId"].get!string;
        }
        
        if ("displayName" in json) {
            group.displayName = json["displayName"].get!string;
        }
        
        if ("members" in json && json["members"].type == Json.Type.array) {
            foreach (memberJson; json["members"]) {
                GroupMember member;
                if ("value" in memberJson) member.value = memberJson["value"].get!string;
                if ("display" in memberJson) member.display = memberJson["display"].get!string;
                if ("type" in memberJson) member.type = memberJson["type"].get!string;
                if ("$ref" in memberJson) member.ref_ = memberJson["$ref"].get!string;
                group.members ~= member;
            }
        }
        
        return group;
    }
    
    /**
     * Add a member to the group
     */
    void addMember(string userId, string displayName = "") pure @safe {
        GroupMember member;
        member.value = userId;
        member.display = displayName;
        member.type = "User";
        members ~= member;
    }
    
    /**
     * Remove a member from the group
     */
    void removeMember(string userId) pure @safe {
        import std.algorithm : remove;
        import std.array : array;
        
        members = members.remove!(m => m.value == userId).array;
    }
    
    /**
     * Check if user is a member
     */
    bool hasMember(string userId) const pure @safe {
        import std.algorithm : any;
        return members.any!(m => m.value == userId);
    }
}

/**
 * Group creation request
 */
struct CreateGroupRequest {
    string displayName;
    string[] memberIds;
    
    Group toGroup() const pure @safe {
        Group group;
        group.displayName = displayName;
        
        foreach (memberId; memberIds) {
            GroupMember member;
            member.value = memberId;
            member.type = "User";
            group.members ~= member;
        }
        
        return group;
    }
}
