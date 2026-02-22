module uim.sap.mgt.config;

import std.string : startsWith;

import uim.sap.btp.config : SAPBTPConfig;
import uim.sap.mgt.exceptions;

struct MGTConfig {
    string host = "0.0.0.0";
    ushort port = 8088;
    string basePath = "/api/mgt";

    string serviceName = "uim-sap-mgt";
    string serviceVersion = "1.0.0";

    bool requireAuthToken = false;
    string authToken;

    string tenant;
    string subdomain;
    string region = "api.sap.hana.ondemand.com";
    string username;
    string password;
    string clientId;
    string clientSecret;
    string accessToken;
    bool useOAuth2 = false;

    string[string] customHeaders;

    void validate() const {
        if (host.length == 0) {
            throw new MGTConfigurationException("Host cannot be empty");
        }
        if (port == 0) {
            throw new MGTConfigurationException("Port must be greater than zero");
        }
        if (basePath.length == 0 || !basePath.startsWith("/")) {
            throw new MGTConfigurationException("Base path must start with '/'");
        }
        if (requireAuthToken && authToken.length == 0) {
            throw new MGTConfigurationException("Auth token required when token auth is enabled");
        }
        if (region.length == 0) {
            throw new MGTConfigurationException("BTP region cannot be empty");
        }
        if (subdomain.length == 0) {
            throw new MGTConfigurationException("BTP subdomain cannot be empty");
        }
        if (useOAuth2) {
            if (accessToken.length == 0 && (clientId.length == 0 || clientSecret.length == 0)) {
                throw new MGTConfigurationException("When OAuth2 is enabled, set MGT_BTP_ACCESS_TOKEN or both MGT_BTP_CLIENT_ID and MGT_BTP_CLIENT_SECRET");
            }
        } else if (username.length == 0 || password.length == 0) {
            throw new MGTConfigurationException("When OAuth2 is disabled, set MGT_BTP_USERNAME and MGT_BTP_PASSWORD");
        }
    }

    SAPBTPConfig toSAPBTPConfig() const {
        SAPBTPConfig btp;
        btp.tenant = tenant;
        btp.subdomain = subdomain;
        btp.region = region;
        btp.username = username;
        btp.password = password;
        btp.clientId = clientId;
        btp.clientSecret = clientSecret;
        btp.accessToken = accessToken;
        btp.useOAuth2 = useOAuth2;
        return btp;
    }
}
