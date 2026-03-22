/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.s4hana.config;

import uim.sap.s4hana;

mixin(ShowModule!());

@safe:

enum S4HANAAuthType {
    Basic,
    OAuth2,
    ApiKey
}

class S4HANAConfig : SAPConfig {
    string baseUrl;
    ushort port = 443;
    bool useSSL = true;
    bool verifySSL = true;

    string sapClient;
    string sapLanguage = "EN";

    S4HANAAuthType authType = S4HANAAuthType.Basic;
    string username;
    string password;
    string accessToken;
    string apiKey;
    string apiKeyHeader = "X-API-Key";

    string odataBasePath = "/sap/opu/odata/sap";
    Duration timeout = 30.seconds;
    uint maxRetries = 2;

    string[string] customHeaders;

    override void validate() {
        if (baseUrl.length == 0) {
            throw new S4HANAConfigurationException("Base URL cannot be empty");
        }

        final switch (authType) {
            case S4HANAAuthType.Basic:
                if (username.length == 0 || password.length == 0) {
                    throw new S4HANAConfigurationException(
                        "Username and password are required for Basic authentication"
                    );
                }
                break;
            case S4HANAAuthType.OAuth2:
                if (accessToken.length == 0) {
                    throw new S4HANAConfigurationException(
                        "Access token is required for OAuth2 authentication"
                    );
                }
                break;
            case S4HANAAuthType.ApiKey:
                if (apiKey.length == 0) {
                    throw new S4HANAConfigurationException(
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

    static S4HANAConfig createBasic(
        string baseUrl,
        string username,
        string password,
        string sapClient = ""
    ) {
        S4HANAConfig cfg = new S4HANAConfig;
        cfg.baseUrl = baseUrl;
        cfg.username = username;
        cfg.password = password;
        cfg.sapClient = sapClient;
        cfg.authType = S4HANAAuthType.Basic;
        return cfg;
    }

    static S4HANAConfig createOAuth2(string baseUrl, string accessToken, string sapClient = "") {
        S4HANAConfig cfg = new S4HANAConfig;
        cfg.baseUrl = baseUrl;
        cfg.accessToken = accessToken;
        cfg.sapClient = sapClient;
        cfg.authType = S4HANAAuthType.OAuth2;
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
