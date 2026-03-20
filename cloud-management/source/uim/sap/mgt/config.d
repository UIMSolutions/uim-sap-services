module uim.sap.mgt.config;

import uim.sap.mgt;

mixin(ShowModule!());

@safe:

/** 
  * Configuration for MGT service
  *
  * Environment variables:
  * - MGT_HOST: Host to bind the server to (default: "0.0.0.0")
  * - MGT_PORT: Port to listen on (default: 8088)
  * - MGT_BASE_PATH: Base path for the API (default: "/api/mgt")
  * - MGT_REQUIRE_AUTH_TOKEN: Whether to require an auth token (default: false)
  * - MGT_AUTH_TOKEN: The auth token to require if MGT_REQUIRE_AUTH_TOKEN is true
  * - MGT_TENANT: BTP tenant (optional, used for scoping)
  * - MGT_SUBDOMAIN: BTP subdomain (required)
  * - MGT_REGION: BTP region (default: "api.sap.hana.ondemand.com")
  * - MGT_USERNAME: BTP username (required if not using OAuth2)
  * - MGT_PASSWORD: BTP password (required if not using OAuth2)
  * - MGT_CLIENT_ID: BTP OAuth2 client ID (required if using OAuth2 and not providing access token)
  * - MGT_CLIENT_SECRET: BTP OAuth2 client secret (required if using OAuth2 and not providing access token)
  * - MGT_ACCESS_TOKEN: BTP OAuth2 access token (optional, if using OAuth2, can be used instead of client ID/secret)
  * - MGT_USE_OAUTH2: Whether to use OAuth2 for authentication (default: false)
  *
  * Example usage:
  * MGTConfig config = MGTConfig(
  *     host: "0.0.0.0",
  *     port: 8088,
  *     basePath: "/api/mgt"
  * );
  */
class MGTConfig : SAPConfig {
  mixin(SAPConfigTemplate!HTMRepoConfig);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    // Network configuration
    basePath(initData.getString("basePath", "/api/mgt"));
    host(initData.getString("host", "0.0.0.0"));
    port(cast(ushort)initData.getInteger("port", 8088));
    
    // Service metadata
    serviceName(initData.getString("serviceName", "uim-mgt"));
    serviceVersion(initData.getString("serviceVersion", "1.0.0"));

    requireAuthToken(initData.getBoolean("requireAuthToken", false));
    authToken = initData.getString("authToken", "");

    return true;
  }

  string tenant;
  string subdomain;
  string region = "api.sap.hana.ondemand.com";
  string username;
  string password;
  UUID clientId;
  string clientSecret;
  string accessToken;
  bool useOAuth2 = false;

  string[string] customHeaders;

  override void validate() const {
    super.validate();

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
        throw new MGTConfigurationException(
          "When OAuth2 is enabled, set MGT_BTP_ACCESS_TOKEN or both MGT_BTP_CLIENT_ID and MGT_BTP_CLIENT_SECRET");
      }
    } else if (username.length == 0 || password.length == 0) {
      throw new MGTConfigurationException(
        "When OAuth2 is disabled, set MGT_BTP_USERNAME and MGT_BTP_PASSWORD");
    }
  }

}
