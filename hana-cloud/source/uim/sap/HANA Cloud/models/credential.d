/**
 * Authentication credentials model
 * 
 * Copyright: Copyright © 2018-2026, Ozan Nurettin Süel
 * License: Apache-2.0
 * Authors: Ozan Nurettin Süel
 */
module uim.sap.models.credential;

import std.datetime : SysTime, Clock;

/**
 * Authentication types supported by SAP HANA Cloud
 */
enum AuthType {
    BasicAuth,      // Username/Password
    OAuth2,         // OAuth 2.0 token
    JWT,            // JSON Web Token
    Certificate,    // Client certificate
    ApiKey          // API Key authentication
}

/**
 * Credentials for SAP HANA authentication
 */
struct Credential {
    AuthType type;
    string username;
    string password;
    string token;
    string apiKey;
    string clientId;
    string clientSecret;
    string certificatePath;
    string keyPath;
    
    // Token expiration tracking
    SysTime tokenExpiration;
    
    /**
     * Check if the current token (if any) is still valid
     */
    bool isTokenValid() const @safe {
        if (type != AuthType.OAuth2 && type != AuthType.JWT) {
            return true;
        }
        return Clock.currTime() < tokenExpiration;
    }
    
    /**
     * Create basic auth credentials
     */
    static Credential basic(string username, string password) pure nothrow @safe {
        Credential cred;
        cred.type = AuthType.BasicAuth;
        cred.username = username;
        cred.password = password;
        return cred;
    }
    
    /**
     * Create OAuth2 credentials
     */
    static Credential oauth(string clientId, string clientSecret) pure nothrow @safe {
        Credential cred;
        cred.type = AuthType.OAuth2;
        cred.clientId = clientId;
        cred.clientSecret = clientSecret;
        return cred;
    }
    
    /**
     * Create JWT credentials
     */
    static Credential jwt(string token) pure nothrow @safe {
        Credential cred;
        cred.type = AuthType.JWT;
        cred.token = token;
        return cred;
    }
    
    /**
     * Create API key credentials
     */
    static Credential apiKey(string key) pure nothrow @safe {
        Credential cred;
        cred.type = AuthType.ApiKey;
        cred.apiKey = key;
        return cred;
    }
}
