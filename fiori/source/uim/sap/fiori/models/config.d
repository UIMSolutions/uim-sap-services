/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.fiori.models.config;

import uim.sap.fiori;

/**
 * Authentication type for Fiori services
 */
enum FioriAuthType {
    Basic,
    OAuth2,
    SAML,
    Certificate,
    ApiKey
}

/**
 * OData protocol version
 */
enum ODataVersion {
    V2,  // OData 2.0
    V3,  // OData 3.0
    V4   // OData 4.0
}

/**
 * Configuration for Fiori Client
 */
struct FioriConfig : SAPConfig {
    /// Base URL of the Fiori system (e.g., "https://myserver.com")
    string baseUrl;
    
    /// Port (default: 443 for HTTPS)
    ushort port = 443;
    
    /// Use SSL
    bool useSSL = true;
    
    /// client number (e.g., "001")
    string sapClient;
    
    /// language (e.g., "EN")
    string sapLanguage = "EN";
    
    /// Authentication type
    FioriAuthType authType = FioriAuthType.Basic;
    
    /// Username (for Basic auth)
    string username;
    
    /// Password (for Basic auth)
    string password;
    
    /// OAuth2 token
    string oauthToken;
    
    /// API key
    string apiKey;
    
    /// Connection timeout
    Duration timeout = 30.seconds;
    
    /// Maximum retry attempts
    uint maxRetries = 3;
    
    /// Verify SSL certificates
    bool verifySSL = true;
    
    /// Custom headers
    string[string] customHeaders;
    
    /// OData version (default: V2)
    ODataVersion odataVersion = ODataVersion.V2;
    
    /// CSRF token handling
    bool enableCSRF = true;
    
    /**
     * Validate configuration
     */
    void validate() const @safe {
        if (baseUrl.length == 0) {
            throw new FioriConfigurationException("Base URL cannot be empty");
        }
        
        if (authType == FioriAuthType.Basic) {
            if (username.length == 0 || password.length == 0) {
                throw new FioriConfigurationException("Username and password required for Basic auth");
            }
        }
    }
    
    /**
     * Get full base URL with port
     */
    string fullBaseUrl() const pure @safe {
        auto protocol = useSSL ? "https" : "http";
        if ((useSSL && port == 443) || (!useSSL && port == 80)) {
            return format("%s://%s", protocol, getHostFromUrl(baseUrl));
        }
        return format("%s://%s:%d", protocol, getHostFromUrl(baseUrl), port);
    }
    
    /**
     * Get OData service base URL
     */
    string odataBaseUrl() const pure @safe {
        return format("%s/sap/opu/odata/sap", fullBaseUrl());
    }
    
    /**
     * Get Launchpad API base URL
     */
    string launchpadBaseUrl() const pure @safe {
        return format("%s/sap/bc/ui2", fullBaseUrl());
    }
    
    /**
     * Create configuration with basic auth
     */
    static FioriConfig createBasic(string baseUrl, string username, string password, string sapClient = "") pure nothrow @safe {
        FioriConfig config;
        config.baseUrl = baseUrl;
        config.username = username;
        config.password = password;
        config.sapClient = sapClient;
        config.authType = FioriAuthType.Basic;
        return config;
    }
    
    /**
     * Create configuration with OAuth2
     */
    static FioriConfig createOAuth(string baseUrl, string token, string sapClient = "") pure nothrow @safe {
        FioriConfig config;
        config.baseUrl = baseUrl;
        config.oauthToken = token;
        config.sapClient = sapClient;
        config.authType = FioriAuthType.OAuth2;
        return config;
    }
    
    private static string getHostFromUrl(string url) pure @safe {
        import std.string : indexOf, startsWith;
        
        auto withoutProtocol = url;
        if (url.startsWith("https://")) {
            withoutProtocol = url[8..$];
        } else if (url.startsWith("http://")) {
            withoutProtocol = url[7..$];
        }
        
        auto slashIdx = withoutProtocol.indexOf('/');
        if (slashIdx > 0) {
            return withoutProtocol[0..slashIdx];
        }
        return withoutProtocol;
    }
}
