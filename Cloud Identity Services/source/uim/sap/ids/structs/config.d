/**
 * Configuration for SAP Cloud Identity Services
 * 
 * Copyright: Copyright © 2018-2026, Ozan Nurettin Süel
 * License: Apache-2.0
 * Authors: Ozan Nurettin Süel
 */
module uim.sap.ids.structs.config;

import uim.sap.ids;
@safe:

/**
 * Configuration for SAP Cloud Identity Services
 */
struct IdentityConfig {
    /// Service type
    IdentityServiceType serviceType = IdentityServiceType.IAS;
    
    /// Tenant host (e.g., "myaccount.accounts.ondemand.com")
    string tenantHost;
    
    /// Port number (default: 443 for HTTPS)
    ushort port = 443;
    
    /// Use HTTPS (recommended)
    bool useSSL = true;
    
    /// OAuth2 client ID
    string clientId;
    
    /// OAuth2 client secret
    string clientSecret;
    
    /// OAuth2 token endpoint
    string tokenEndpoint;
    
    /// API base path
    string apiBasePath = "/service/scim/v2";
    
    /// Connection timeout
    Duration timeout = 30.seconds;
    
    /// Maximum number of retry attempts
    uint maxRetries = 3;
    
    /// Verify SSL certificates
    bool verifySSL = true;
    
    /// Custom headers to include in requests
    string[string] customHeaders;
    
    /// API version
    string apiVersion = "2.0";
    
    /**
     * Validate the configuration
     */
    void validate() const @safe {
        if (tenantHost.length == 0) {
            throw new IdentityConfigurationException("Tenant host cannot be empty");
        }
        
        if (port == 0) {
            throw new IdentityConfigurationException("Invalid port number");
        }
        
        if (clientId.length == 0) {
            throw new IdentityConfigurationException("Client ID cannot be empty");
        }
        
        if (clientSecret.length == 0) {
            throw new IdentityConfigurationException("Client secret cannot be empty");
        }
    }
    
    /**
     * Get the base URL for API requests
     */
    string baseUrl() const pure @safe {
        auto protocol = useSSL ? "https" : "http";
        if ((useSSL && port == 443) || (!useSSL && port == 80)) {
            return format("%s://%s", protocol, tenantHost);
        }
        return format("%s://%s:%d", protocol, tenantHost, port);
    }
    
    /**
     * Get the full API URL
     */
    string apiUrl() const pure @safe {
        return format("%s%s", baseUrl(), apiBasePath);
    }
    
    /**
     * Get token endpoint URL
     */
    string getTokenEndpoint() const pure @safe {
        if (tokenEndpoint.length > 0) {
            return tokenEndpoint;
        }
        return format("%s/oauth/token", baseUrl());
    }
    
    /**
     * Create a default IAS configuration
     */
    static IdentityConfig createIAS(string tenantHost, string clientId, string clientSecret) pure nothrow @safe {
        IdentityConfig config;
        config.serviceType = IdentityServiceType.IAS;
        config.tenantHost = tenantHost;
        config.clientId = clientId;
        config.clientSecret = clientSecret;
        config.apiBasePath = "/service/scim/v2";
        return config;
    }
    
    /**
     * Create a default IPS configuration
     */
    static IdentityConfig createIPS(string tenantHost, string clientId, string clientSecret) pure nothrow @safe {
        IdentityConfig config;
        config.serviceType = IdentityServiceType.IPS;
        config.tenantHost = tenantHost;
        config.clientId = clientId;
        config.clientSecret = clientSecret;
        config.apiBasePath = "/service/scim/v2";
        return config;
    }
}
