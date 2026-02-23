/**
 * User management for SAP Cloud Identity Services
 * 
 * Copyright: Copyright © 2018-2026, Ozan Nurettin Süel
 * License: Apache-2.0
 * Authors: Ozan Nurettin Süel
 */
module uim.sap.ids.users;

import uim.sap.ids.structs;
import uim.sap.ids.exceptions;
import vibe.http.client;
import vibe.data.json;
import std.string : format;
import std.conv : to;

/**
 * User management API
 */
class UserManager {
    private IdentityClient client;
    
    package this(IdentityClient client) {
        this.client = client;
    }
    
    /**
     * Create a new user
     */
    User create(User user) {
        auto url = format("%s/Users", client.configuration.apiUrl());
        auto response = client.makeRequest(HTTPMethod.POST, url, user.toJson());
        
        if (!response.isSuccess()) {
            throw new IdentityUserException(response.errorMessage(), response.statusCode);
        }
        
        return User.fromJson(response.data);
    }
    
    /**
     * Create a user with basic information
     */
    User create(string userName, string password, string givenName, string familyName, string email) {
        CreateUserRequest req;
        req.userName = userName;
        req.password = password;
        req.givenName = givenName;
        req.familyName = familyName;
        req.email = email;
        
        return create(req.toUser());
    }
    
    /**
     * Get a user by ID
     */
    User get(string userId) {
        auto url = format("%s/Users/%s", client.configuration.apiUrl(), userId);
        auto response = client.makeRequest(HTTPMethod.GET, url);
        
        if (!response.isSuccess()) {
            if (response.statusCode == 404) {
                throw new IdentityNotFoundException(
                    format("User not found: %s", userId), "User", userId);
            }
            throw new IdentityUserException(response.errorMessage(), response.statusCode);
        }
        
        return User.fromJson(response.data);
    }
    
    /**
     * Update a user
     */
    User update(string userId, User user) {
        auto url = format("%s/Users/%s", client.configuration.apiUrl(), userId);
        auto response = client.makeRequest(HTTPMethod.PUT, url, user.toJson());
        
        if (!response.isSuccess()) {
            throw new IdentityUserException(response.errorMessage(), response.statusCode);
        }
        
        return User.fromJson(response.data);
    }
    
    /**
     * Partially update a user (PATCH)
     */
    User patch(string userId, Json patchOperations) {
        auto url = format("%s/Users/%s", client.configuration.apiUrl(), userId);
        auto response = client.makeRequest(HTTPMethod.PATCH, url, patchOperations);
        
        if (!response.isSuccess()) {
            throw new IdentityUserException(response.errorMessage(), response.statusCode);
        }
        
        return User.fromJson(response.data);
    }
    
    /**
     * Delete a user
     */
    void remove(string userId) {
        auto url = format("%s/Users/%s", client.configuration.apiUrl(), userId);
        auto response = client.makeRequest(HTTPMethod.DELETE, url);
        
        if (!response.isSuccess()) {
            throw new IdentityUserException(response.errorMessage(), response.statusCode);
        }
    }
    
    /**
     * List users with pagination
     */
    UserListResponse list(PaginationParams pagination = PaginationParams.init) {
        auto url = format("%s/Users", client.configuration.apiUrl());
        auto response = client.makeRequest(HTTPMethod.GET, url, Json.emptyObject, pagination.toQueryParams());
        
        if (!response.isSuccess()) {
            throw new IdentityUserException(response.errorMessage(), response.statusCode);
        }
        
        return parseUserListResponse(response.data);
    }
    
    /**
     * Search users by filter
     */
    UserListResponse search(string filter, PaginationParams pagination = PaginationParams.init) {
        auto url = format("%s/Users", client.configuration.apiUrl());
        auto params = pagination.toQueryParams();
        params["filter"] = filter;
        
        auto response = client.makeRequest(HTTPMethod.GET, url, Json.emptyObject, params);
        
        if (!response.isSuccess()) {
            throw new IdentityUserException(response.errorMessage(), response.statusCode);
        }
        
        return parseUserListResponse(response.data);
    }
    
    /**
     * Search users by username
     */
    UserListResponse searchByUserName(string userName) {
        auto filter = format("userName eq \"%s\"", userName);
        return search(filter);
    }
    
    /**
     * Search users by email
     */
    UserListResponse searchByEmail(string email) {
        auto filter = format("emails.value eq \"%s\"", email);
        return search(filter);
    }
    
    /**
     * Get active users
     */
    UserListResponse getActive(PaginationParams pagination = PaginationParams.init) {
        return search("active eq true", pagination);
    }
    
    /**
     * Get inactive users
     */
    UserListResponse getInactive(PaginationParams pagination = PaginationParams.init) {
        return search("active eq false", pagination);
    }
    
    /**
     * Activate a user
     */
    User activate(string userId) {
        auto patchOps = Json.emptyObject;
        patchOps["schemas"] = Json(["urn:ietf:params:scim:api:messages:2.0:PatchOp"]);
        patchOps["Operations"] = Json([
            Json(["op": Json("replace"), "path": Json("active"), "value": Json(true)])
        ]);
        
        return patch(userId, patchOps);
    }
    
    /**
     * Deactivate a user
     */
    User deactivate(string userId) {
        auto patchOps = Json.emptyObject;
        patchOps["schemas"] = Json(["urn:ietf:params:scim:api:messages:2.0:PatchOp"]);
        patchOps["Operations"] = Json([
            Json(["op": Json("replace"), "path": Json("active"), "value": Json(false)])
        ]);
        
        return patch(userId, patchOps);
    }
    
    /**
     * Change user password
     */
    void changePassword(string userId, string newPassword) {
        auto patchOps = Json.emptyObject;
        patchOps["schemas"] = Json(["urn:ietf:params:scim:api:messages:2.0:PatchOp"]);
        patchOps["Operations"] = Json([
            Json(["op": Json("replace"), "path": Json("password"), "value": Json(newPassword)])
        ]);
        
        patch(userId, patchOps);
    }
    
    /**
     * Add user to group
     */
    void addToGroup(string userId, string groupId) {
        auto patchOps = Json.emptyObject;
        patchOps["schemas"] = Json(["urn:ietf:params:scim:api:messages:2.0:PatchOp"]);
        
        auto groupValue = Json.emptyObject;
        groupValue["value"] = groupId;
        
        patchOps["Operations"] = Json([
            Json(["op": Json("add"), "path": Json("groups"), "value": Json([groupValue])])
        ]);
        
        patch(userId, patchOps);
    }
    
    /**
     * Remove user from group
     */
    void removeFromGroup(string userId, string groupId) {
        auto patchOps = Json.emptyObject;
        patchOps["schemas"] = Json(["urn:ietf:params:scim:api:messages:2.0:PatchOp"]);
        patchOps["Operations"] = Json([
            Json([
                "op": Json("remove"),
                "path": Json(format("groups[value eq \"%s\"]", groupId))
            ])
        ]);
        
        patch(userId, patchOps);
    }
    
    // Private helper methods
    
    private UserListResponse parseUserListResponse(Json data) {
        UserListResponse listResponse;
        
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
            foreach (userJson; data["Resources"]) {
                listResponse.resources ~= User.fromJson(userJson);
            }
        }
        
        return listResponse;
    }
}

