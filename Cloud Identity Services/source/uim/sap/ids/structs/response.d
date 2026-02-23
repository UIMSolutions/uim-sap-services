/**
 * Response models for SAP Cloud Identity Services
 * 
 * Copyright: Copyright © 2018-2026, Ozan Nurettin Süel
 * License: Apache-2.0
 * Authors: Ozan Nurettin Süel
 */
module uim.sap.ids.structs.response;

import vibe.data.json;
import std.datetime : SysTime;
import uim.sap.ids.structs.user;
import uim.sap.ids.structs.group;

/**
 * SCIM List Response (for paginated results)
 */
struct SCIMListResponse(T) {
    string[] schemas = ["urn:ietf:params:scim:api:messages:2.0:ListResponse"];
    long totalResults;
    long startIndex;
    long itemsPerPage;
    T[] resources;
    
    /**
     * Check if there are more results
     */
    @property bool hasMore() const pure nothrow @safe @nogc {
        return startIndex + itemsPerPage < totalResults;
    }
    
    /**
     * Get next page start index
     */
    @property long nextStartIndex() const pure nothrow @safe @nogc {
        return startIndex + itemsPerPage;
    }
}

/// User list response
alias UserListResponse = SCIMListResponse!User;

/// Group list response
alias GroupListResponse = SCIMListResponse!Group;

/**
 * SCIM Error response
 */
struct SCIMError {
    string[] schemas = ["urn:ietf:params:scim:api:messages:2.0:Error"];
    string detail;
    int status;
    string scimType;
    
    /**
     * Create from JSON
     */
    static SCIMError fromJson(Json json) {
        SCIMError error;
        
        if ("detail" in json) {
            error.detail = json["detail"].get!string;
        }
        
        if ("status" in json) {
            if (json["status"].type == Json.Type.string) {
                import std.conv : to;
                error.status = json["status"].get!string.to!int;
            } else {
                error.status = json["status"].get!int;
            }
        }
        
        if ("scimType" in json) {
            error.scimType = json["scimType"].get!string;
        }
        
        return error;
    }
}

/**
 * Identity Service API response
 */
struct IdentityResponse {
    /// HTTP status code
    int statusCode;
    
    /// Success indicator
    bool success;
    
    /// Response body as JSON
    Json data;
    
    /// Error information
    SCIMError error;
    
    /// Response headers
    string[string] headers;
    
    /// Request timestamp
    SysTime timestamp;
    
    /**
     * Check if the response indicates success
     */
    bool isSuccess() const pure nothrow @safe @nogc {
        return success && statusCode >= 200 && statusCode < 300;
    }
    
    /**
     * Check if the response indicates an error
     */
    bool isError() const pure nothrow @safe @nogc {
        return !success || statusCode >= 400;
    }
    
    /**
     * Get error message
     */
    string errorMessage() const @safe {
        if (error.detail.length > 0) {
            return error.detail;
        }
        if ("message" in data) {
            return data["message"].get!string;
        }
        return "Unknown error";
    }
}

/**
 * Pagination parameters
 */
struct PaginationParams {
    long startIndex = 1;
    long count = 100;
    string sortBy;
    string sortOrder = "ascending";  // ascending or descending
    
    /**
     * Convert to query parameters
     */
    string[string] toQueryParams() const pure @safe {
        import std.conv : to;
        
        string[string] params;
        params["startIndex"] = startIndex.to!string;
        params["count"] = count.to!string;
        
        if (sortBy.length > 0) {
            params["sortBy"] = sortBy;
            params["sortOrder"] = sortOrder;
        }
        
        return params;
    }
}

/**
 * Filter for searching users/groups
 */
struct SCIMFilter {
    string attribute;
    string operator = "eq";  // eq, ne, co, sw, ew, pr, gt, ge, lt, le
    string value;
    
    /**
     * Build filter string
     */
    string toString() const pure @safe {
        import std.string : format;
        
        if (operator == "pr") {
            return format("%s pr", attribute);
        }
        
        return format("%s %s \"%s\"", attribute, operator, value);
    }
}
