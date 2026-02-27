/**
 * Configuration for RFC adapter
 *
 * Copyright: Copyright © 2018-2026, Ozan Nurettin Süel
 * License: Apache-2.0
 * Authors: Ozan Nurettin Süel
 */
module uim.sap.rfc.config;

import core.time : Duration, seconds;
import std.string : format, startsWith;

import uim.sap.rfc.exceptions;

enum SAPRFCAuthType {
    None,
    Basic,
    Bearer
}

struct SAPRFCConfig {
    string baseUrl;
    string endpointPath = "/sap/bc/rfc";

    ushort port = 443;
    bool useSSL = true;
    bool verifySSL = true;

    SAPRFCAuthType authType = SAPRFCAuthType.None;
    string username;
    string password;
    string bearerToken;

    string sapClient;
    string sapLanguage = "EN";

    Duration timeout = 30.seconds;
    uint maxRetries = 2;

    string[string] customHeaders;

    void validate() const {
        if (baseUrl.length == 0) {
            throw new SAPRFCConfigurationException("Base URL cannot be empty");
        }

        if (authType == SAPRFCAuthType.Basic) {
            if (username.length == 0 || password.length == 0) {
                throw new SAPRFCConfigurationException(
                    "Username and password are required for Basic authentication");
            }
        }

        if (authType == SAPRFCAuthType.Bearer && bearerToken.length == 0) {
            throw new SAPRFCConfigurationException(
                "Bearer token is required for Bearer authentication");
        }
    }

    string fullBaseUrl() const {
        if (baseUrl.startsWith("http://") || baseUrl.startsWith("https://")) {
            return stripTrailingSlash(baseUrl);
        }

        auto protocol = useSSL ? "https" : "http";
        if ((useSSL && port == 443) || (!useSSL && port == 80)) {
            return format("%s://%s", protocol, stripTrailingSlash(baseUrl));
        }
        return format("%s://%s:%d", protocol, stripTrailingSlash(baseUrl), port);
    }

    string serviceUrl() const {
        auto path = (endpointPath.length == 0 ? "/sap/bc/rfc" : endpointPath).dup;
        if (!path.startsWith("/")) {
            path = "/" ~ path;
        }
        return stripTrailingSlash(fullBaseUrl()) ~ path;
    }

    static SAPRFCConfig createBasic(
        string baseUrl,
        string username,
        string password,
        string sapClient = ""
    ) {
        SAPRFCConfig cfg;
        cfg.baseUrl = baseUrl;
        cfg.username = username;
        cfg.password = password;
        cfg.sapClient = sapClient;
        cfg.authType = SAPRFCAuthType.Basic;
        return cfg;
    }

    static SAPRFCConfig createBearer(
        string baseUrl,
        string token,
        string sapClient = ""
    ) {
        SAPRFCConfig cfg;
        cfg.baseUrl = baseUrl;
        cfg.bearerToken = token;
        cfg.sapClient = sapClient;
        cfg.authType = SAPRFCAuthType.Bearer;
        return cfg;
    }

    private static string stripTrailingSlash(string url) {
        auto result = url;
        while (result.length > 0 && result[$ - 1] == '/') {
            result = result[0 .. $ - 1];
        }
        return result;
    }
}
