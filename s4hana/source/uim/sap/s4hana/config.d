/**
 * Configuration for S/4HANA client
 */
module uim.sap.s4hana.config;

import core.time : Duration, seconds;
import std.string : format, startsWith;

import uim.sap.s4hana.exceptions;

enum SAPS4HANAAuthType {
    Basic,
    OAuth2,
    ApiKey
}

struct SAPS4HANAConfig {
    string baseUrl;
    ushort port = 443;
    bool useSSL = true;
    bool verifySSL = true;

    string sapClient;
    string sapLanguage = "EN";

    SAPS4HANAAuthType authType = SAPS4HANAAuthType.Basic;
    string username;
    string password;
    string accessToken;
    string apiKey;
    string apiKeyHeader = "X-API-Key";

    string odataBasePath = "/sap/opu/odata/sap";
    Duration timeout = 30.seconds;
    uint maxRetries = 2;

    string[string] customHeaders;

    void validate() const {
        if (baseUrl.length == 0) {
            throw new SAPS4HANAConfigurationException("Base URL cannot be empty");
        }

        final switch (authType) {
            case SAPS4HANAAuthType.Basic:
                if (username.length == 0 || password.length == 0) {
                    throw new SAPS4HANAConfigurationException(
                        "Username and password are required for Basic authentication"
                    );
                }
                break;
            case SAPS4HANAAuthType.OAuth2:
                if (accessToken.length == 0) {
                    throw new SAPS4HANAConfigurationException(
                        "Access token is required for OAuth2 authentication"
                    );
                }
                break;
            case SAPS4HANAAuthType.ApiKey:
                if (apiKey.length == 0) {
                    throw new SAPS4HANAConfigurationException(
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

    string odataBaseUrl() const {
        auto path = (odataBasePath.length > 0 ? odataBasePath : "/sap/opu/odata/sap").idup;
        if (!path.startsWith("/")) {
            path = "/" ~ path;
        }
        return (fullBaseUrl() ~ path).idup;
    }

    static SAPS4HANAConfig createBasic(
        string baseUrl,
        string username,
        string password,
        string sapClient = ""
    ) {
        SAPS4HANAConfig cfg;
        cfg.baseUrl = baseUrl;
        cfg.username = username;
        cfg.password = password;
        cfg.sapClient = sapClient;
        cfg.authType = SAPS4HANAAuthType.Basic;
        return cfg;
    }

    static SAPS4HANAConfig createOAuth2(string baseUrl, string accessToken, string sapClient = "") {
        SAPS4HANAConfig cfg;
        cfg.baseUrl = baseUrl;
        cfg.accessToken = accessToken;
        cfg.sapClient = sapClient;
        cfg.authType = SAPS4HANAAuthType.OAuth2;
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
