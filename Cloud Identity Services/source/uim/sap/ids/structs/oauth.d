/**
 * OAuth2 models for SAP Cloud Identity Services
 * 
 * Copyright: Copyright © 2018-2026, Ozan Nurettin Süel
 * License: Apache-2.0
 * Authors: Ozan Nurettin Süel
 */
module uim.sap.ids.structs.oauth;

import std.datetime : SysTime, Clock;
import core.time : dur;

import uim.sap.ids;
@safe:

/**
 * OAuth2 token response
 */
struct OAuth2Token {
    string accessToken;
    string tokenType = "Bearer";
    long expiresIn;
    string refreshToken;
    string scope_;
    string idToken;
    SysTime obtainedAt;
    
    /**
     * Get token expiration time
     */
    @property SysTime expiresAt() const {
        return obtainedAt + dur!"seconds"(expiresIn);
    }
    
    /**
     * Check if token is expired
     */
    @property bool isExpired() const {
        // Add 60 second buffer
        return Clock.currTime() >= (expiresAt - dur!"seconds"(60));
    }
    
    /**
     * Check if token is valid
     */
    @property bool isValid() const {
        return accessToken.length > 0 && !isExpired;
    }
}

/**
 * OAuth2 client credentials
 */
struct OAuth2Credentials {
    string clientId;
    string clientSecret;
    string[] scopes;
    
    /**
     * Validate credentials
     */
    bool isValid() const pure nothrow @safe @nogc {
        return clientId.length > 0 && clientSecret.length > 0;
    }
}

/**
 * OAuth2 authorization code flow data
 */
struct OAuth2AuthCode {
    string code;
    string redirectUri;
    string codeVerifier;  // For PKCE
    string state;
}
