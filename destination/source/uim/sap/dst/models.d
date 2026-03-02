module uim.sap.dst.models;

import std.datetime : Clock, SysTime;
import std.uuid     : randomUUID;

import vibe.data.json : Json;

string createId() {
    return randomUUID().toString();
}

// ---------------------------------------------------------------------------
// DSTDestination – a configured destination (connection to remote service)
// ---------------------------------------------------------------------------
struct DSTDestination {
    string tenantId;
    /// Unique name within a tenant (used as lookup key)
    string name;
    string description;
    /// URL / hostname of the remote service
    string url;
    /// Protocol: "HTTP" | "RFC" | "LDAP" | "MAIL" | "TCP"
    string protocol;
    /// Authentication type:
    ///   "NoAuthentication" | "BasicAuthentication" | "OAuth2ClientCredentials"
    ///   "OAuth2SAMLBearerAssertion" | "OAuth2UserTokenExchange"
    ///   "ClientCertificateAuthentication" | "PrincipalPropagation"
    ///   "SAMLAssertion" | "OAuth2JWTBearer" | "OAuth2Password"
    string authenticationType;
    /// Proxy type: "Internet" | "OnPremise" | "PrivateLink"
    string proxyType;
    /// Target environment: "cloud-foundry" | "kyma" | "abap" | "kubernetes"
    string environment;
    /// User / client credentials
    string user;
    string password;          // stored but masked in output
    /// OAuth2 fields
    string tokenServiceUrl;
    string clientId;
    string clientSecret;      // stored but masked in output
    /// Certificate name (reference to DSTCertificate)
    string certificateName;
    /// Cloud Connector location ID (for OnPremise)
    string locationId;
    /// SAP Client (RFC / ABAP)
    string sapClient;
    /// Custom key-value properties
    string[string] properties;
    bool   active;
    SysTime createdAt;
    SysTime updatedAt;

    Json toJson() const {
        Json j = Json.emptyObject;
        j["tenant_id"]           = tenantId;
        j["name"]                = name;
        j["description"]         = description;
        j["url"]                 = url;
        j["protocol"]            = protocol;
        j["authentication_type"] = authenticationType;
        j["proxy_type"]          = proxyType;
        j["environment"]         = environment;
        j["user"]                = user;
        j["password"]            = password.length > 0 ? "***" : "";
        j["token_service_url"]   = tokenServiceUrl;
        j["client_id"]           = clientId;
        j["client_secret"]       = clientSecret.length > 0 ? "***" : "";
        j["certificate_name"]    = certificateName;
        j["location_id"]         = locationId;
        j["sap_client"]          = sapClient;
        // Properties
        Json props = Json.emptyObject;
        foreach (k, v; properties) props[k] = v;
        j["properties"]          = props;
        j["active"]              = active;
        j["created_at"]          = createdAt.toISOExtString();
        j["updated_at"]          = updatedAt.toISOExtString();
        return j;
    }
}

// ---------------------------------------------------------------------------
// DSTCertificate – a TLS certificate stored per tenant
// ---------------------------------------------------------------------------
struct DSTCertificate {
    string tenantId;
    /// Unique certificate name within a tenant
    string name;
    string description;
    /// Certificate type: "PEM" | "PFX" | "P12" | "JKS"
    string certType;
    /// Base64-encoded certificate content (stored but masked in output)
    string content;
    /// Issuer / subject hints
    string issuer;
    string subject;
    /// Expiry date as ISO string
    string expiresAt;
    SysTime createdAt;
    SysTime updatedAt;

    Json toJson() const {
        Json j = Json.emptyObject;
        j["tenant_id"]   = tenantId;
        j["name"]        = name;
        j["description"] = description;
        j["cert_type"]   = certType;
        j["content"]     = content.length > 0 ? "***" : "";
        j["issuer"]      = issuer;
        j["subject"]     = subject;
        j["expires_at"]  = expiresAt;
        j["created_at"]  = createdAt.toISOExtString();
        j["updated_at"]  = updatedAt.toISOExtString();
        return j;
    }
}

// ---------------------------------------------------------------------------
// DSTLookupResult – the result of a runtime destination lookup
// ---------------------------------------------------------------------------
struct DSTLookupResult {
    string destinationName;
    string url;
    string protocol;
    string authenticationType;
    string proxyType;
    string environment;
    /// Resolved auth token (if OAuth flow was performed)
    string authToken;
    /// Headers to inject when calling the destination
    string[string] headers;
    /// Custom properties forwarded to the caller
    string[string] properties;
    SysTime resolvedAt;

    Json toJson() const {
        Json j = Json.emptyObject;
        j["destination_name"]    = destinationName;
        j["url"]                 = url;
        j["protocol"]            = protocol;
        j["authentication_type"] = authenticationType;
        j["proxy_type"]          = proxyType;
        j["environment"]         = environment;
        j["auth_token"]          = authToken.length > 0 ? "***" : "";
        Json hdr = Json.emptyObject;
        foreach (k, v; headers) hdr[k] = v;
        j["headers"]    = hdr;
        Json props = Json.emptyObject;
        foreach (k, v; properties) props[k] = v;
        j["properties"] = props;
        j["resolved_at"] = resolvedAt.toISOExtString();
        return j;
    }
}

// ---------------------------------------------------------------------------
// DSTAuditLog – audit trail for destination operations
// ---------------------------------------------------------------------------
struct DSTAuditLog {
    string tenantId;
    string logId;
    string destinationName;
    string action;     // "created", "updated", "deleted", "lookup", "cert-uploaded", …
    string message;
    string level;      // "info" | "warning" | "error"
    SysTime timestamp;

    Json toJson() const {
        Json j = Json.emptyObject;
        j["tenant_id"]        = tenantId;
        j["log_id"]           = logId;
        j["destination_name"] = destinationName;
        j["action"]           = action;
        j["message"]          = message;
        j["level"]            = level;
        j["timestamp"]        = timestamp.toISOExtString();
        return j;
    }
}
