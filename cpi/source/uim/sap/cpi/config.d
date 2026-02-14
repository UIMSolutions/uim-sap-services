/**
 * Configuration for SAP Cloud Integration (CPI) client
 */
module uim.sap.cpi.config;

import core.time : Duration, seconds;
import std.string : format, startsWith;

import uim.sap.cpi.exceptions;

enum SAPCPIAuthType {
    Basic,
    OAuth2,
    ApiKey
}

struct SAPCPIConfig {
    string baseUrl;
    ushort port = 443;
    bool useSSL = true;
    bool verifySSL = true;

    SAPCPIAuthType authType = SAPCPIAuthType.Basic;
    string username;
    string password;
    string accessToken;
    string apiKey;
    string apiKeyHeader = "X-API-Key";

    string apiBasePath = "/api/v1";
    Duration timeout = 30.seconds;
    uint maxRetries = 2;

    string[string] customHeaders;

    void validate() const {
        if (baseUrl.length == 0) {
            throw new SAPCPIConfigurationException("Base URL cannot be empty");
        }

        final switch (authType) {
            case SAPCPIAuthType.Basic:
                if (username.length == 0 || password.length == 0) {
                    throw new SAPCPIConfigurationException(
                        "Username and password are required for Basic authentication"
                    );
                }
                break;
            case SAPCPIAuthType.OAuth2:
                if (accessToken.length == 0) {
                    throw new SAPCPIConfigurationException(
                        "Access token is required for OAuth2 authentication"
                    );
                }
                break;
            case SAPCPIAuthType.ApiKey:
                if (apiKey.length == 0) {
                    throw new SAPCPIConfigurationException(
                        "API key is required for API key authentication"
                    );
                }
                break;
        }
    }

    string fullBaseUrl() const {
        if (baseUrl.startsWith("https://") || baseUrl.startsWith("http://")) {
            return stripTrailingSlash(baseUrl).idup;
        }

        auto protocol = useSSL ? "https" : "http";
        if ((useSSL && port == 443) || (!useSSL && port == 80)) {
            return format("%s://%s", protocol, stripTrailingSlash(baseUrl));
        }

        return format("%s://%s:%d", protocol, stripTrailingSlash(baseUrl), port);
    }

    string apiBaseUrl() const {
        auto path = (apiBasePath.length > 0 ? apiBasePath : "/api/v1").idup;
        if (!path.startsWith("/")) {
            path = "/" ~ path;
        }
        return (fullBaseUrl() ~ path).idup;
    }

    static SAPCPIConfig createBasic(string baseUrl, string username, string password) {
        SAPCPIConfig cfg;
        cfg.baseUrl = baseUrl;
        cfg.username = username;
        cfg.password = password;
        cfg.authType = SAPCPIAuthType.Basic;
        return cfg;
    }

    static SAPCPIConfig createOAuth2(string baseUrl, string accessToken) {
        SAPCPIConfig cfg;
        cfg.baseUrl = baseUrl;
        cfg.accessToken = accessToken;
        cfg.authType = SAPCPIAuthType.OAuth2;
        return cfg;
    }

    private static string stripTrailingSlash(string value) {
        auto result = value;
        while (result.length > 0 && result[$ - 1] == '/') {
            result = result[0 .. $ - 1];
        }
        return result.idup;
    }
}
