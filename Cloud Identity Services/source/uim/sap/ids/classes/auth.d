/**
 * Authentication module for SAP Cloud Identity Services
 * 
 * Copyright: Copyright © 2018-2026, Ozan Nurettin Süel
 * License: Apache-2.0
 * Authors: Ozan Nurettin Süel
 */
module uim.sap.ids.auth;

import uim.sap.ids.structs;
import uim.sap.ids.exceptions;
import vibe.http.client;
import vibe.data.json;
import vibe.stream.operations;
import std.datetime : Clock;
import std.string : format;
import std.base64 : Base64;

/**
 * OAuth2 authentication manager for SAP Cloud Identity Services
 */
class IdentityAuthManager {
    private OAuth2Credentials credentials;
    private OAuth2Token currentToken;
    private string tokenEndpoint;
    
    /**
     * Constructor
     */
    this(OAuth2Credentials credentials, string tokenEndpoint) {
        this.credentials = credentials;
        this.tokenEndpoint = tokenEndpoint;
    }
    
    /**
     * Get valid access token (refresh if needed)
     */
    string getAccessToken() {
        if (currentToken.accessToken.length == 0 || currentToken.isExpired) {
            refreshToken();
        }
        return currentToken.accessToken;
    }
    
    /**
     * Get authorization header value
     */
    string getAuthorizationHeader() {
        return format("Bearer %s", getAccessToken());
    }
    
    /**
     * Add authentication headers to request
     */
    void addAuthHeaders(HTTPClientRequest req) {
        req.headers["Authorization"] = getAuthorizationHeader();
    }
    
    /**
     * Refresh OAuth2 token using client credentials
     */
    void refreshToken() {
        if (tokenEndpoint.length == 0) {
            throw new IdentityAuthenticationException("Token endpoint not configured");
        }
        
        try {
            requestHTTP(tokenEndpoint,
                (scope req) {
                    req.method = HTTPMethod.POST;
                    req.headers["Content-Type"] = "application/x-www-form-urlencoded";
                    
                    // Basic authentication with client credentials
                    auto authString = format("%s:%s", credentials.clientId, credentials.clientSecret);
                    auto encoded = Base64.encode(cast(ubyte[])authString);
                    req.headers["Authorization"] = format("Basic %s", encoded);
                    
                    auto body = "grant_type=client_credentials";
                    if (credentials.scopes.length > 0) {
                        import std.array : join;
                        body ~= format("&scope=%s", credentials.scopes.join(" "));
                    }
                    
                    req.writeBody(cast(ubyte[])body);
                },
                (scope res) {
                    if (res.statusCode != 200) {
                        auto errorBody = res.bodyReader.readAllUTF8();
                        throw new IdentityAuthenticationException(
                            format("Token request failed with status %d: %s", res.statusCode, errorBody));
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
                    if ("id_token" in json) {
                        currentToken.idToken = json["id_token"].get!string;
                    }
                }
            );
        } catch (IdentityAuthenticationException e) {
            throw e;
        } catch (Exception e) {
            throw new IdentityAuthenticationException("Failed to refresh token: " ~ e.msg);
        }
    }
    
    /**
     * Exchange authorization code for token (for OAuth2 authorization code flow)
     */
    void exchangeAuthCode(OAuth2AuthCode authCode, string tokenEndpoint) {
        try {
            requestHTTP(tokenEndpoint,
                (scope req) {
                    req.method = HTTPMethod.POST;
                    req.headers["Content-Type"] = "application/x-www-form-urlencoded";
                    
                    auto body = format("grant_type=authorization_code&code=%s&redirect_uri=%s",
                        authCode.code, authCode.redirectUri);
                    
                    if (authCode.codeVerifier.length > 0) {
                        body ~= format("&code_verifier=%s", authCode.codeVerifier);
                    }
                    
                    // Basic authentication
                    auto authString = format("%s:%s", credentials.clientId, credentials.clientSecret);
                    auto encoded = Base64.encode(cast(ubyte[])authString);
                    req.headers["Authorization"] = format("Basic %s", encoded);
                    
                    req.writeBody(cast(ubyte[])body);
                },
                (scope res) {
                    if (res.statusCode != 200) {
                        throw new IdentityAuthenticationException(
                            format("Authorization code exchange failed with status %d", res.statusCode));
                    }
                    
                    auto json = res.readJson();
                    
                    currentToken.accessToken = json["access_token"].get!string;
                    currentToken.tokenType = json["token_type"].get!string;
                    currentToken.expiresIn = json["expires_in"].get!long;
                    currentToken.obtainedAt = Clock.currTime();
                    
                    if ("refresh_token" in json) {
                        currentToken.refreshToken = json["refresh_token"].get!string;
                    }
                    if ("id_token" in json) {
                        currentToken.idToken = json["id_token"].get!string;
                    }
                }
            );
        } catch (Exception e) {
            throw new IdentityAuthenticationException("Failed to exchange authorization code: " ~ e.msg);
        }
    }
    
    /**
     * Validate credentials
     */
    bool validateCredentials() const pure nothrow @safe @nogc {
        return credentials.isValid();
    }
    
    /**
     * Check if currently authenticated
     */
    bool isAuthenticated() const pure nothrow @safe @nogc {
        return currentToken.isValid;
    }
    
    /**
     * Clear current token
     */
    void clearToken() pure nothrow @safe @nogc {
        currentToken = OAuth2Token.init;
    }
}
