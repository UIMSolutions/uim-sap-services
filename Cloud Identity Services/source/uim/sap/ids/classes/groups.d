/**
 * Group management for SAP Cloud Identity Services
 * 
 * Copyright: Copyright © 2018-2026, Ozan Nurettin Süel
 * License: Apache-2.0
 * Authors: Ozan Nurettin Süel
 */
module uim.sap.ids.groups;

import uim.sap.ids.structs;
import uim.sap.ids.exceptions;
import vibe.http.client;
import vibe.data.json;
import std.string : format;
import std.conv : to;

/**
 * Group management API
 */
class GroupManager {
    private IdentityClient client;
    
    package this(IdentityClient client) {
        this.client = client;
    }
    
    /**
     * Create a new group
     */
    Group create(Group group) {
        auto url = format("%s/Groups", client.configuration.apiUrl());
        auto response = client.makeRequest(HTTPMethod.POST, url, group.toJson());
        
        if (!response.isSuccess()) {
            throw new IdentityGroupException(response.errorMessage(), response.statusCode);
        }
        
        return Group.fromJson(response.data);
    }
    
    /**
     * Create a group with basic information
     */
    Group create(string displayName, string[] memberIds = []) {
        CreateGroupRequest req;
        req.displayName = displayName;
        req.memberIds = memberIds;
        
        return create(req.toGroup());
    }
    
    /**
     * Get a group by ID
     */
    Group get(string groupId) {
        auto url = format("%s/Groups/%s", client.configuration.apiUrl(), groupId);
        auto response = client.makeRequest(HTTPMethod.GET, url);
        
        if (!response.isSuccess()) {
            if (response.statusCode == 404) {
                throw new IdentityNotFoundException(
                    format("Group not found: %s", groupId), "Group", groupId);
            }
            throw new IdentityGroupException(response.errorMessage(), response.statusCode);
        }
        
        return Group.fromJson(response.data);
    }
    
    /**
     * Update a group
     */
    Group update(string groupId, Group group) {
        auto url = format("%s/Groups/%s", client.configuration.apiUrl(), groupId);
        auto response = client.makeRequest(HTTPMethod.PUT, url, group.toJson());
        
        if (!response.isSuccess()) {
            throw new IdentityGroupException(response.errorMessage(), response.statusCode);
        }
        
        return Group.fromJson(response.data);
    }
    
    /**
     * Partially update a group (PATCH)
     */
    Group patch(string groupId, Json patchOperations) {
        auto url = format("%s/Groups/%s", client.configuration.apiUrl(), groupId);
        auto response = client.makeRequest(HTTPMethod.PATCH, url, patchOperations);
        
        if (!response.isSuccess()) {
            throw new IdentityGroupException(response.errorMessage(), response.statusCode);
        }
        
        return Group.fromJson(response.data);
    }
    
    /**
     * Delete a group
     */
    void remove(string groupId) {
        auto url = format("%s/Groups/%s", client.configuration.apiUrl(), groupId);
        auto response = client.makeRequest(HTTPMethod.DELETE, url);
        
        if (!response.isSuccess()) {
            throw new IdentityGroupException(response.errorMessage(), response.statusCode);
        }
    }
    
    /**
     * List groups with pagination
     */
    GroupListResponse list(PaginationParams pagination = PaginationParams.init) {
        auto url = format("%s/Groups", client.configuration.apiUrl());
        auto response = client.makeRequest(HTTPMethod.GET, url, Json.emptyObject, pagination.toQueryParams());
        
        if (!response.isSuccess()) {
            throw new IdentityGroupException(response.errorMessage(), response.statusCode);
        }
        
        return parseGroupListResponse(response.data);
    }
    
    /**
     * Search groups by filter
     */
    GroupListResponse search(string filter, PaginationParams pagination = PaginationParams.init) {
        auto url = format("%s/Groups", client.configuration.apiUrl());
        auto params = pagination.toQueryParams();
        params["filter"] = filter;
        
        auto response = client.makeRequest(HTTPMethod.GET, url, Json.emptyObject, params);
        
        if (!response.isSuccess()) {
            throw new IdentityGroupException(response.errorMessage(), response.statusCode);
        }
        
        return parseGroupListResponse(response.data);
    }
    
    /**
     * Search groups by display name
     */
    GroupListResponse searchByName(string displayName) {
        auto filter = format("displayName eq \"%s\"", displayName);
        return search(filter);
    }
    
    /**
     * Add members to a group
     */
    Group addMembers(string groupId, string[] userIds) {
        auto patchOps = Json.emptyObject;
        patchOps["schemas"] = Json(["urn:ietf:params:scim:api:messages:2.0:PatchOp"]);
        
        Json[] members;
        foreach (userId; userIds) {
            auto member = Json.emptyObject;
            member["value"] = userId;
            members ~= member;
        }
        
        patchOps["Operations"] = Json([
            Json(["op": Json("add"), "path": Json("members"), "value": Json(members)])
        ]);
        
        return patch(groupId, patchOps);
    }
    
    /**
     * Add a single member to a group
     */
    Group addMember(string groupId, string userId) {
        return addMembers(groupId, [userId]);
    }
    
    /**
     * Remove members from a group
     */
    Group removeMembers(string groupId, string[] userIds) {
        auto patchOps = Json.emptyObject;
        patchOps["schemas"] = Json(["urn:ietf:params:scim:api:messages:2.0:PatchOp"]);
        
        Json[] operations;
        foreach (userId; userIds) {
            auto op = Json.emptyObject;
            op["op"] = "remove";
            op["path"] = format("members[value eq \"%s\"]", userId);
            operations ~= op;
        }
        
        patchOps["Operations"] = Json(operations);
        
        return patch(groupId, patchOps);
    }
    
    /**
     * Remove a single member from a group
     */
    Group removeMember(string groupId, string userId) {
        return removeMembers(groupId, [userId]);
    }
    
    /**
     * Get all members of a group
     */
    string[] getMembers(string groupId) {
        auto group = get(groupId);
        string[] memberIds;
        
        foreach (member; group.members) {
            memberIds ~= member.value;
        }
        
        return memberIds;
    }
    
    /**
     * Check if a user is a member of a group
     */
    bool isMember(string groupId, string userId) {
        auto group = get(groupId);
        return group.hasMember(userId);
    }
    
    // Private helper methods
    
    private GroupListResponse parseGroupListResponse(Json data) {
        GroupListResponse listResponse;
        
        if ("totalResults" in data) {
            listResponse.totalResults = data["totalResults"].get!long;
        }
        
        if ("startIndex" in data) {
            listResponse.startIndex = data["startIndex"].get!long;
        }
        
        if ("itemsPerPage" in data) {
            listResponse.itemsPerPage = data["itemsPerPage"].get!long;
        }
        
        if ("Resources" in data && data["Resources"].type == Json.Type.array) {
            foreach (groupJson; data["Resources"]) {
                listResponse.resources ~= Group.fromJson(groupJson);
            }
        }
        
        return listResponse;
    }
}

