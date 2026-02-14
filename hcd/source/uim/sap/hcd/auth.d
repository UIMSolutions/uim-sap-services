/**
 * Authentication manager for SAP HANA Cloud
 * 
 * Copyright: Copyright © 2018-2026, Ozan Nurettin Süel
 * License: Apache-2.0
 * Authors: Ozan Nurettin Süel
 */
module uim.sap.auth;

import uim.sap.models;
import uim.sap.exceptions;
import vibe.http.client;
import vibe.data.json;
import vibe.stream.operations;
import std.datetime : Clock, SysTime, seconds;
import std.base64 : Base64;
import std.string : format;
import std.array : Appender;

/**
 * OAuth2 token response
 */
struct OAuth2Token {
    string accessToken;
    string tokenType;
    long expiresIn;
    string refreshToken;
    string scope_;
    SysTime obtainedAt;
    
    @property SysTime expiresAt() const {
        import core.time : dur;
        return obtainedAt + dur!"seconds"(expiresIn);
    }
    
    @property bool isExpired() const {
        return Clock.currTime() >= expiresAt;
    }
}

/**
 * Authentication manager for SAP HANA
 */
class AuthManager {
    private Credential credential;
    private OAuth2Token currentToken;
    private string tokenEndpoint;
    
    /**
     * Constructor
     */
    this(Credential credential, string tokenEndpoint = "") {
        this.credential = credential;
        this.tokenEndpoint = tokenEndpoint;
    }
    
    /**
     * Get authorization header value
     */
    string getAuthorizationHeader() {
        final switch (credential.type) {
            case AuthType.BasicAuth:
                return getBasicAuthHeader();
            case AuthType.OAuth2:
                return getOAuth2Header();
            case AuthType.JWT:
                return getJWTHeader();
            case AuthType.ApiKey:
                return getApiKeyHeader();
            case AuthType.Certificate:
                // Certificate auth is handled at connection level
                return "";
        }
    }
    
    /**
     * Generate Basic Auth header
     */
    private string getBasicAuthHeader() {
        auto credentials = format("%s:%s", credential.username, credential.password);
        auto encoded = Base64.encode(cast(ubyte[])credentials);
        return format("Basic %s", encoded);
    }
    
    /**
     * Generate OAuth2 header
     */
    private string getOAuth2Header() {
        // Refresh token if expired
        if (currentToken.accessToken.length == 0 || currentToken.isExpired) {
            refreshOAuth2Token();
        }
        return format("Bearer %s", currentToken.accessToken);
    }
    
    /**
     * Generate JWT header
     */
    private string getJWTHeader() {
        return format("Bearer %s", credential.token);
    }
    
    /**
     * Generate API Key header
     */
    private string getApiKeyHeader() {
        return format("APIKey %s", credential.apiKey);
    }
    
    /**
     * Refresh OAuth2 token
     */
    private void refreshOAuth2Token() {
        if (tokenEndpoint.length == 0) {
            throw new SAPAuthenticationException("Token endpoint not configured for OAuth2");
        }
        
        try {
            requestHTTP(tokenEndpoint,
                (scope req) {
                    req.method = HTTPMethod.POST;
                    req.headers["Content-Type"] = "application/x-www-form-urlencoded";
                    
                    auto body = format("grant_type=client_credentials&client_id=%s&client_secret=%s",
                        credential.clientId, credential.clientSecret);
                    req.writeBody(cast(ubyte[])body);
                },
                (scope res) {
                    if (res.statusCode != 200) {
                        throw new SAPAuthenticationException(
                            format("OAuth2 token request failed with status %d", res.statusCode));
                    }
                    
                    auto json = res.readJson();
                    currentToken.accessToken = json["access_token"].get!string;
                    currentToken.tokenType = json["token_type"].get!string;
                    currentToken.expiresIn = json["expires_in"].get!long;
                    currentToken.obtainedAt = Clock.currTime();
                    
                    if ("refresh_token" in json) {
                        currentToken.refreshToken = json["refresh_token"].get!string;
                    }
                    if ("scope" in json) {
                        currentToken.scope_ = json["scope"].get!string;
                    }
                }
            );
        } catch (Exception e) {
            throw new SAPAuthenticationException("Failed to refresh OAuth2 token: " ~ e.msg);
        }
    }
    
    /**
     * Add authentication headers to an HTTP request
     */
    void addAuthHeaders(HTTPClientRequest req) {
        auto authHeader = getAuthorizationHeader();
        if (authHeader.length > 0) {
            req.headers["Authorization"] = authHeader;
        }
    }
    
    /**
     * Validate credentials
     */
    bool validateCredentials() {
        try {
            final switch (credential.type) {
                case AuthType.BasicAuth:
                    return credential.username.length > 0 && credential.password.length > 0;
                case AuthType.OAuth2:
                    return credential.clientId.length > 0 && credential.clientSecret.length > 0;
                case AuthType.JWT:
                    return credential.token.length > 0;
                case AuthType.ApiKey:
                    return credential.apiKey.length > 0;
                case AuthType.Certificate:
                    return credential.certificatePath.length > 0;
            }
        } catch (Exception) {
            return false;
        }
    }
}
