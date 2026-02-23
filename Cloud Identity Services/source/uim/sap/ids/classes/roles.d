/**
 * Role management for SAP Cloud Identity Services
 * 
 * Copyright: Copyright © 2018-2026, Ozan Nurettin Süel
 * License: Apache-2.0
 * Authors: Ozan Nurettin Süel
 */
module uim.sap.ids.roles;

import uim.sap.ids.structs;
import uim.sap.ids.exceptions;
import vibe.http.client;
import vibe.data.json;
import std.string : format;

/**
 * Role management API
 */
class RoleManager {
    private IdentityClient client;
    
    package this(IdentityClient client) {
        this.client = client;
    }
    
    /**
     * Get a role by ID
     */
    Role get(string roleId) {
        auto url = format("%s/Roles/%s", client.configuration.apiUrl(), roleId);
        auto response = client.makeRequest(HTTPMethod.GET, url);
        
        if (!response.isSuccess()) {
            throw new IdentityException(response.errorMessage());
        }
        
        return Role.fromJson(response.data);
    }
    
    /**
     * List all roles
     */
    Role[] list() {
        auto url = format("%s/Roles", client.configuration.apiUrl());
        auto response = client.makeRequest(HTTPMethod.GET, url);
        
        if (!response.isSuccess()) {
            throw new IdentityException(response.errorMessage());
        }
        
        Role[] roles;
        if ("Resources" in response.data && response.data["Resources"].type == Json.Type.array) {
            foreach (roleJson; response.data["Resources"]) {
                roles ~= Role.fromJson(roleJson);
            }
        }
        
        return roles;
    }
    
    /**
     * Assign a role to a user
     */
    void assignToUser(string roleId, string userId) {
        auto url = format("%s/RoleAssignments", client.configuration.apiUrl());
        
        auto payload = Json.emptyObject;
        payload["roleId"] = roleId;
        payload["userId"] = userId;
        
        auto response = client.makeRequest(HTTPMethod.POST, url, payload);
        
        if (!response.isSuccess()) {
            throw new IdentityAuthorizationException(response.errorMessage());
        }
    }
    
    /**
     * Remove a role from a user
     */
    void removeFromUser(string roleId, string userId) {
        auto url = format("%s/RoleAssignments/%s/users/%s", client.configuration.apiUrl(), roleId, userId);
        auto response = client.makeRequest(HTTPMethod.DELETE, url);
        
        if (!response.isSuccess()) {
            throw new IdentityAuthorizationException(response.errorMessage());
        }
    }
    
    /**
     * Get roles assigned to a user
     */
    Role[] getUserRoles(string userId) {
        auto url = format("%s/Users/%s/roles", client.configuration.apiUrl(), userId);
        auto response = client.makeRequest(HTTPMethod.GET, url);
        
        if (!response.isSuccess()) {
            throw new IdentityException(response.errorMessage());
        }
        
        Role[] roles;
        if ("Resources" in response.data && response.data["Resources"].type == Json.Type.array) {
            foreach (roleJson; response.data["Resources"]) {
                roles ~= Role.fromJson(roleJson);
            }
        }
        
        return roles;
    }
}

// Forward declaration
class IdentityClient;
