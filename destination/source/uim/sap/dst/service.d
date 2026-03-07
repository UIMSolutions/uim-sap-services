module uim.sap.dst.service;

import uim.sap.dst;

mixin(ShowModule!());

@safe:

// ---------------------------------------------------------------------------
// DSTService – business logic for the Destination service
// ---------------------------------------------------------------------------
class DSTService : SAPService {
    private DSTConfig _config;
    private DSTStore  _store;

    this(DSTConfig config) {
        config.validate();
        _config = config;
        _store  = new DSTStore;
    }

    @property const(DSTConfig) config() const { return _config; }

    // -----------------------------------------------------------------------
    // Health / readiness
    // -----------------------------------------------------------------------
    Json health() const {
        Json j = Json.emptyObject;
        j["status"]       = "UP";
        j["service"]      = _config.serviceName;
        j["version"]      = _config.serviceVersion;
        j["runtime"]      = _config.runtime;
        j["multitenancy"] = true;
        j["domain"]       = "destination";
        return j;
    }


    // -----------------------------------------------------------------------
    // Dashboard HTML
    // -----------------------------------------------------------------------
    string dashboardHtml() const {
        return import("dashboard.html");
    }

    // =======================================================================
    // DESTINATIONS
    // =======================================================================
    Json listDestinations(string tenantId, string protocolFilter, string proxyFilter) {
        DSTDestination[] items;
        if (protocolFilter.length > 0 || proxyFilter.length > 0)
            items = _store.filterDestinations(tenantId, protocolFilter, proxyFilter);
        else
            items = _store.listDestinations(tenantId);

        Json arr = Json.emptyArray;
        foreach (d; items) arr ~= d.toJson();
        return arr;
    }

    Json createDestination(string tenantId, Json payload) {
        if (!("name" in payload) || payload["name"].get!string.length == 0)
            throw new DSTValidationException("Destination name is required");
        if (!("url" in payload) || payload["url"].get!string.length == 0)
            throw new DSTValidationException("Destination URL is required");

        auto name = payload["name"].get!string;

        // Check for duplicate name
        DSTDestination existing;
        if (_store.tryGetDestination(tenantId, name, existing))
            throw new DSTValidationException("Destination already exists: " ~ name);

        auto protocol = jstr(payload, "protocol", "HTTP");
        _validateProtocol(protocol);

        auto authType = jstr(payload, "authentication_type", "NoAuthentication");
        _validateAuthType(authType);

        auto proxyType = jstr(payload, "proxy_type", "Internet");
        _validateProxyType(proxyType);

        DSTDestination d;
        d.tenantId           = tenantId;
        d.name               = name;
        d.description        = jstr(payload, "description");
        d.url                = payload["url"].get!string;
        d.protocol           = protocol;
        d.authenticationType = authType;
        d.proxyType          = proxyType;
        d.environment        = jstr(payload, "environment", _config.runtime);
        d.user               = jstr(payload, "user");
        d.password           = jstr(payload, "password");
        d.tokenServiceUrl    = jstr(payload, "token_service_url");
        d.clientId           = jstr(payload, "client_id");
        d.clientSecret       = jstr(payload, "client_secret");
        d.certificateName    = jstr(payload, "certificate_name");
        d.locationId         = jstr(payload, "location_id");
        d.sapClient          = jstr(payload, "sap_client");
        d.active             = jbool(payload, "active", true);
        d.createdAt          = Clock.currTime();
        d.updatedAt          = d.createdAt;

        // Parse custom properties
        if ("properties" in payload && payload["properties"].isObject) {
            foreach (string k, v; payload["properties"])
                if (v.isString)
                    d.properties[k] = v.get!string;
        }

        // Validate certificate reference if given
        if (d.certificateName.length > 0) {
            DSTCertificate cert;
            if (!_store.tryGetCertificate(tenantId, d.certificateName, cert))
                throw new DSTNotFoundException("Certificate", d.certificateName);
        }

        // Validate auth-specific required fields
        _validateAuthFields(d);

        _store.upsertDestination(d);
        _appendLog(tenantId, name, "created", "info",
            "Destination created: " ~ name ~ " (" ~ protocol ~ " / " ~ authType ~ ")");
        return d.toJson();
    }

    Json getDestination(string tenantId, string name) {
        DSTDestination d;
        if (!_store.tryGetDestination(tenantId, name, d))
            throw new DSTNotFoundException("Destination", name);
        auto j = d.toJson();
        // Embed recent logs
        Json logs = Json.emptyArray;
        foreach (l; _store.listLogsByDestination(tenantId, name)) logs ~= l.toJson();
        j["audit_logs"] = logs;
        return j;
    }

    Json updateDestination(string tenantId, string name, Json payload) {
        DSTDestination d;
        if (!_store.tryGetDestination(tenantId, name, d))
            throw new DSTNotFoundException("Destination", name);

        // Apply partial update
        if ("description" in payload)          d.description        = payload["description"].get!string;
        if ("url" in payload)                  d.url                = payload["url"].get!string;
        if ("protocol" in payload) {
            auto p = payload["protocol"].get!string;
            _validateProtocol(p);
            d.protocol = p;
        }
        if ("authentication_type" in payload) {
            auto a = payload["authentication_type"].get!string;
            _validateAuthType(a);
            d.authenticationType = a;
        }
        if ("proxy_type" in payload) {
            auto pt = payload["proxy_type"].get!string;
            _validateProxyType(pt);
            d.proxyType = pt;
        }
        if ("environment" in payload)          d.environment        = payload["environment"].get!string;
        if ("user" in payload)                 d.user               = payload["user"].get!string;
        if ("password" in payload)             d.password           = payload["password"].get!string;
        if ("token_service_url" in payload)    d.tokenServiceUrl    = payload["token_service_url"].get!string;
        if ("client_id" in payload)            d.clientId           = payload["client_id"].get!string;
        if ("client_secret" in payload)        d.clientSecret       = payload["client_secret"].get!string;
        if ("certificate_name" in payload)     d.certificateName    = payload["certificate_name"].get!string;
        if ("location_id" in payload)          d.locationId         = payload["location_id"].get!string;
        if ("sap_client" in payload)           d.sapClient          = payload["sap_client"].get!string;
        if ("active" in payload)               d.active             = jbool(payload, "active", d.active);

        if ("properties" in payload && payload["properties"].isObject) {
            string[string] newProps;
            foreach (string k, v; payload["properties"])
                if (v.isString)
                    newProps[k] = v.get!string;
            d.properties = newProps;
        }

        d.updatedAt = Clock.currTime();
        _store.upsertDestination(d);
        _appendLog(tenantId, name, "updated", "info", "Destination updated: " ~ name);
        return d.toJson();
    }

    Json deleteDestination(string tenantId, string name) {
        if (!_store.removeDestination(tenantId, name))
            throw new DSTNotFoundException("Destination", name);
        _appendLog(tenantId, name, "deleted", "info", "Destination deleted: " ~ name);
        Json j = Json.emptyObject;
        j["deleted"] = name;
        return j;
    }

    // =======================================================================
    // DESTINATION LOOKUP (runtime resolution)
    // =======================================================================
    Json lookupDestination(string tenantId, string name) {
        DSTDestination d;
        if (!_store.tryGetDestination(tenantId, name, d))
            throw new DSTNotFoundException("Destination", name);

        if (!d.active)
            throw new DSTDestinationException("Destination is inactive: " ~ name);

        DSTLookupResult result;
        result.destinationName    = d.name;
        result.url                = d.url;
        result.protocol           = d.protocol;
        result.authenticationType = d.authenticationType;
        result.proxyType          = d.proxyType;
        result.environment        = d.environment;
        result.properties         = d.properties;
        result.resolvedAt         = Clock.currTime();

        // Simulate authentication flow based on type
        switch (d.authenticationType) {
            case "NoAuthentication":
                // No auth headers needed
                break;
            case "BasicAuthentication":
                if (d.user.length > 0)
                    result.headers["Authorization"] = "Basic <encoded>";
                break;
            case "OAuth2ClientCredentials":
            case "OAuth2SAMLBearerAssertion":
            case "OAuth2UserTokenExchange":
            case "OAuth2JWTBearer":
            case "OAuth2Password":
                // Simulate OAuth token retrieval
                result.authToken = "simulated-oauth-token-" ~ createId()[0..8];
                result.headers["Authorization"] = "Bearer " ~ result.authToken;
                break;
            case "ClientCertificateAuthentication":
                result.headers["X-Certificate"] = d.certificateName;
                break;
            case "PrincipalPropagation":
                result.headers["SAP-Connectivity-Authentication"] = "propagated";
                break;
            case "SAMLAssertion":
                result.headers["Authorization"] = "SAML <simulated-assertion>";
                break;
            default:
                break;
        }

        // Add proxy headers for OnPremise
        if (d.proxyType == "OnPremise") {
            result.headers["Proxy-Authorization"] = "Bearer <connectivity-token>";
            if (d.locationId.length > 0)
                result.headers["SAP-Connectivity-SCC-Location_ID"] = d.locationId;
        }

        _appendLog(tenantId, name, "lookup", "info",
            "Destination resolved: " ~ name ~ " → " ~ d.url);

        return result.toJson();
    }

    // =======================================================================
    // CERTIFICATES
    // =======================================================================
    Json listCertificates(string tenantId) {
        Json arr = Json.emptyArray;
        foreach (c; _store.listCertificates(tenantId)) arr ~= c.toJson();
        return arr;
    }

    Json createCertificate(string tenantId, Json payload) {
        if (!("name" in payload) || payload["name"].get!string.length == 0)
            throw new DSTValidationException("Certificate name is required");
        if (!("content" in payload) || payload["content"].get!string.length == 0)
            throw new DSTValidationException("Certificate content is required");

        auto name = payload["name"].get!string;

        // Check duplicate
        DSTCertificate existing;
        if (_store.tryGetCertificate(tenantId, name, existing))
            throw new DSTValidationException("Certificate already exists: " ~ name);

        DSTCertificate c;
        c.tenantId    = tenantId;
        c.name        = name;
        c.description = jstr(payload, "description");
        c.certType    = jstr(payload, "cert_type", "PEM");
        c.content     = payload["content"].get!string;
        c.issuer      = jstr(payload, "issuer");
        c.subject     = jstr(payload, "subject");
        c.expiresAt   = jstr(payload, "expires_at");
        c.createdAt   = Clock.currTime();
        c.updatedAt   = c.createdAt;

        _store.upsertCertificate(c);
        _appendLog(tenantId, "", "cert-uploaded", "info",
            "Certificate uploaded: " ~ name ~ " (" ~ c.certType ~ ")");
        return c.toJson();
    }

    Json getCertificate(string tenantId, string name) {
        DSTCertificate c;
        if (!_store.tryGetCertificate(tenantId, name, c))
            throw new DSTNotFoundException("Certificate", name);
        return c.toJson();
    }

    Json deleteCertificate(string tenantId, string name) {
        if (!_store.removeCertificate(tenantId, name))
            throw new DSTNotFoundException("Certificate", name);
        _appendLog(tenantId, "", "cert-deleted", "info", "Certificate deleted: " ~ name);
        Json j = Json.emptyObject;
        j["deleted"] = name;
        return j;
    }

    // =======================================================================
    // AUDIT LOGS
    // =======================================================================
    Json listLogs(string tenantId) {
        Json arr = Json.emptyArray;
        foreach (l; _store.listLogs(tenantId)) arr ~= l.toJson();
        return arr;
    }

    // =======================================================================
    // Private helpers
    // =======================================================================
    private static immutable string[] VALID_PROTOCOLS = [
        "HTTP", "RFC", "LDAP", "MAIL", "TCP"
    ];

    private static immutable string[] VALID_AUTH_TYPES = [
        "NoAuthentication", "BasicAuthentication",
        "OAuth2ClientCredentials", "OAuth2SAMLBearerAssertion",
        "OAuth2UserTokenExchange", "OAuth2JWTBearer", "OAuth2Password",
        "ClientCertificateAuthentication", "PrincipalPropagation",
        "SAMLAssertion"
    ];

    private static immutable string[] VALID_PROXY_TYPES = [
        "Internet", "OnPremise", "PrivateLink"
    ];

    private static void _validateProtocol(string protocol) {
        if (!canFind(VALID_PROTOCOLS, protocol))
            throw new DSTValidationException(
                "Invalid protocol: " ~ protocol
                ~ ". Allowed: HTTP, RFC, LDAP, MAIL, TCP");
    }

    private static void _validateAuthType(string authType) {
        if (!canFind(VALID_AUTH_TYPES, authType))
            throw new DSTValidationException(
                "Invalid authentication type: " ~ authType);
    }

    private static void _validateProxyType(string proxyType) {
        if (!canFind(VALID_PROXY_TYPES, proxyType))
            throw new DSTValidationException(
                "Invalid proxy type: " ~ proxyType
                ~ ". Allowed: Internet, OnPremise, PrivateLink");
    }

    /// Validate that the required fields for the chosen auth type are present
    private static void _validateAuthFields(const ref DSTDestination d) {
        switch (d.authenticationType) {
            case "BasicAuthentication":
                if (d.user.length == 0)
                    throw new DSTValidationException(
                        "BasicAuthentication requires 'user' field");
                break;
            case "OAuth2ClientCredentials":
            case "OAuth2SAMLBearerAssertion":
            case "OAuth2UserTokenExchange":
            case "OAuth2JWTBearer":
                if (d.tokenServiceUrl.length == 0 || d.clientId.length == 0)
                    throw new DSTValidationException(
                        d.authenticationType
                        ~ " requires 'token_service_url' and 'client_id'");
                break;
            case "OAuth2Password":
                if (d.tokenServiceUrl.length == 0 || d.clientId.length == 0
                        || d.user.length == 0)
                    throw new DSTValidationException(
                        "OAuth2Password requires 'token_service_url', 'client_id', and 'user'");
                break;
            case "ClientCertificateAuthentication":
                if (d.certificateName.length == 0)
                    throw new DSTValidationException(
                        "ClientCertificateAuthentication requires 'certificate_name'");
                break;
            default:
                break;
        }
    }

    private void _appendLog(string tenantId, string destName,
                             string action, string level, string message) {
        DSTAuditLog log;
        log.tenantId        = tenantId;
        log.logId           = _store.nextId("log");
        log.destinationName = destName;
        log.action          = action;
        log.message         = message;
        log.level           = level;
        log.timestamp       = Clock.currTime();
        _store.upsertLog(log);
    }

    // -----------------------------------------------------------------------
    // JSON helpers
    // -----------------------------------------------------------------------
    private static string jstr(Json j, string key, string fallback = "") {
        if (key in j && j[key].isString)
            return j[key].get!string;
        return fallback;
    }

    private static bool jbool(Json j, string key, bool fallback = false) {
        if (key in j) {
            auto v = j[key];
            if (v.type == Json.Type.bool_) return v.get!bool;
            if (v.type == Json.Type.true_) return true;
            if (v.type == Json.Type.false_) return false;
        }
        return fallback;
    }
}
