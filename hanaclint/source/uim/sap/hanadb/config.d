/**
 * Configuration for SAP HANA DB client
 */
module uim.sap.hanadb.config;

import core.time : Duration, seconds;
import std.string : format, startsWith;

import uim.sap.hanadb.exceptions;

enum SAPHanaDBAuthType {
    Basic,
    Bearer
}

struct SAPHanaDBConfig {
    string host;
    ushort port = 443;
    bool useSSL = true;
    bool verifySSL = true;

    string database;
    string endpointPath = "/sql";

    SAPHanaDBAuthType authType = SAPHanaDBAuthType.Basic;
    string username;
    string password;
    string bearerToken;

    Duration timeout = 30.seconds;
    uint maxRetries = 2;

    string[string] customHeaders;

    void validate() const {
        if (host.length == 0) {
            throw new SAPHanaDBConfigurationException("Host cannot be empty");
        }

        if (database.length == 0) {
            throw new SAPHanaDBConfigurationException("Database cannot be empty");
        }

        if (authType == SAPHanaDBAuthType.Basic) {
            if (username.length == 0 || password.length == 0) {
                throw new SAPHanaDBConfigurationException(
                    "Username and password are required for Basic authentication"
                );
            }
        }

        if (authType == SAPHanaDBAuthType.Bearer && bearerToken.length == 0) {
            throw new SAPHanaDBConfigurationException(
                "Bearer token is required for Bearer authentication"
            );
        }
    }

    string baseUrl() const {
        if (host.startsWith("https://") || host.startsWith("http://")) {
            return stripTrailingSlash(host).idup;
        }

        auto protocol = useSSL ? "https" : "http";
        if ((useSSL && port == 443) || (!useSSL && port == 80)) {
            return format("%s://%s", protocol, stripTrailingSlash(host));
        }

        return format("%s://%s:%d", protocol, stripTrailingSlash(host), port);
    }

    string sqlUrl() const {
        auto normalizedPath = (endpointPath.length == 0 ? "/sql" : endpointPath).idup;
        if (!normalizedPath.startsWith("/")) {
            normalizedPath = "/" ~ normalizedPath;
        }
        return (baseUrl() ~ normalizedPath).idup;
    }

    static SAPHanaDBConfig createBasic(
        string host,
        string database,
        string username,
        string password
    ) {
        SAPHanaDBConfig cfg;
        cfg.host = host;
        cfg.database = database;
        cfg.username = username;
        cfg.password = password;
        cfg.authType = SAPHanaDBAuthType.Basic;
        return cfg;
    }

    static SAPHanaDBConfig createBearer(
        string host,
        string database,
        string bearerToken
    ) {
        SAPHanaDBConfig cfg;
        cfg.host = host;
        cfg.database = database;
        cfg.bearerToken = bearerToken;
        cfg.authType = SAPHanaDBAuthType.Bearer;
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
