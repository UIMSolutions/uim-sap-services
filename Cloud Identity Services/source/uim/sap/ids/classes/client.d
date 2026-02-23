/**
 * Main client for SAP Cloud Identity Services
 * 
 * Copyright: Copyright © 2018-2026, Ozan Nurettin Süel
 * License: Apache-2.0
 * Authors: Ozan Nurettin Süel
 */
module uim.sap.ids.client;

import uim.sap.ids.structs;
import uim.sap.ids.auth;
import uim.sap.ids.exceptions;
import uim.sap.ids.users;
import uim.sap.ids.groups;

import vibe.http.client;
import vibe.data.json;
import vibe.stream.operations;
import std.datetime : Clock;
import std.string : format;
import std.conv : to;

/**
 * Main SAP Cloud Identity Services Client
 */
class IdentityClient {
    private IdentityConfig config;
    private IdentityAuthManager authManager;
    private UserManager userManager;
    private GroupManager groupManager;
    
    /**
     * Constructor
     */
    this(IdentityConfig config) {
        this.config = config;
        config.validate();
        
        OAuth2Credentials creds;
        creds.clientId = config.clientId;
        creds.clientSecret = config.clientSecret;
        
        this.authManager = new IdentityAuthManager(creds, config.getTokenEndpoint());
        this.userManager = new UserManager(this);
        this.groupManager = new GroupManager(this);
    }
    
    /**
     * Create a client with IAS configuration
     */
    static IdentityClient createIAS(string tenantHost, string clientId, string clientSecret) {
        auto config = IdentityConfig.createIAS(tenantHost, clientId, clientSecret);
        return new IdentityClient(config);
    }
    
    /**
     * Create a client with IPS configuration
     */
    static IdentityClient createIPS(string tenantHost, string clientId, string clientSecret) {
        auto config = IdentityConfig.createIPS(tenantHost, clientId, clientSecret);
        return new IdentityClient(config);
    }
    
    /**
     * Get user manager
     */
    @property UserManager users() {
        return userManager;
    }
    
    /**
     * Get group manager
     */
    @property GroupManager groups() {
        return groupManager;
    }
    
    /**
     * Test connection and authentication
     */
    bool testConnection() {
        try {
            // Try to get users with count=1 to test connection
            auto url = format("%s/Users?count=1", config.apiUrl());
            auto response = makeRequest(HTTPMethod.GET, url);
            return response.isSuccess();
        } catch (Exception) {
            return false;
        }
    }
    
    /**
     * Make an HTTP request to the Identity API
     */
    package IdentityResponse makeRequest(
        HTTPMethod method,
        string url,
        Json payload = Json.emptyObject,
        string[string] queryParams = null
    ) {
        IdentityResponse response;
        response.timestamp = Clock.currTime();
        
        // Build URL with query parameters
        if (queryParams !is null && queryParams.length > 0) {
            import std.array : array, join;
            import std.algorithm : map;
            import vibe.textfilter.urlencode : urlEncode;
            
            auto paramStrings = queryParams.byKeyValue
                .map!(kv => format("%s=%s", urlEncode(kv.key), urlEncode(kv.value)))
                .array;
            
            if (paramStrings.length > 0) {
                url ~= (url.indexOf('?') >= 0 ? "&" : "?") ~ paramStrings.join("&");
            }
        }
        
        uint retries = 0;
        while (retries <= config.maxRetries) {
            try {
                requestHTTP(url,
                    (scope req) {
                        req.method = method;
                        authManager.addAuthHeaders(req);
                        req.headers["Content-Type"] = "application/scim+json";
                        req.headers["Accept"] = "application/scim+json";
                        
                        // Add custom headers
                        foreach (key, value; config.customHeaders) {
                            req.headers[key] = value;
                        }
                        
                        if (method == HTTPMethod.POST || method == HTTPMethod.PUT || method == HTTPMethod.PATCH) {
                            if (payload.type != Json.Type.undefined && payload.type != Json.Type.null_) {
                                req.writeJsonBody(payload);
                            }
                        }
                    },
                    (scope res) {
                        response.statusCode = res.statusCode;
                        response.success = res.statusCode >= 200 && res.statusCode < 300;
                        
                        // Read response headers
                        foreach (key, value; res.headers) {
                            response.headers[key] = value;
                        }
                        
                        // Read response body
                        if (res.bodyReader.empty) {
                            response.data = Json.emptyObject;
                        } else {
                            try {
                                response.data = res.readJson();
                                
                                // Parse SCIM error if present
                                if (!response.success && "schemas" in response.data) {
                                    response.error = SCIMError.fromJson(response.data);
                                }
                            } catch (Exception e) {
                                response.data = Json(res.bodyReader.readAllUTF8());
                            }
                        }
                        
                        // Handle rate limiting
                        if (res.statusCode == 429) {
                            if ("Retry-After" in res.headers) {
                                import std.conv : to;
                                auto retryAfter = res.headers["Retry-After"].to!long;
                                throw new IdentityRateLimitException("Rate limit exceeded", retryAfter);
                            }
                        }
                    }
                );
                break;
            } catch (IdentityRateLimitException e) {
                throw e;
            } catch (Exception e) {
                retries++;
                if (retries > config.maxRetries) {
                    throw new IdentityConnectionException(
                        format("Request failed after %d retries: %s", retries, e.msg));
                }
            }
        }
        
        return response;
    }
    
    /**
     * Get configuration
     */
    @property const(IdentityConfig) configuration() const pure nothrow @safe @nogc {
        return config;
    }
    
    /**
     * Check if authenticated
     */
    bool isAuthenticated() const pure nothrow @safe @nogc {
        return authManager.isAuthenticated();
    }
}
