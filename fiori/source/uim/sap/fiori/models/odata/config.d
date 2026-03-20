/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.fiori.models.odata.config;

import uim.sap.fiori;

@safe:

/**
 * OData client configuration
 */
struct ODataConfig : SAPConfig {
  mixin(SAPConfigTemplate!ODataConfig);
  
  override bool initialize(Json[string] initData) {
    if (!super.initialize(initData)) {
      return false;
    }

    serviceName(initData.getString("serviceName", "uim-odata-client"));
    serviceVersion(initData.getString("serviceVersion", "1.0.0"));
    return true;
  }

  string serviceUrl;
  string username;
  string password;
  ODataVersion version_ = ODataVersion.V4;
  FioriAuthType authType = FioriAuthType.Basic;
  string oauthToken;
  string apiKey;
  bool useSSL = true;
  string sapClient;
  string sapLanguage = "EN";
  string[string] customHeaders;
  Duration timeout = 30.seconds;

  override void validate() const {
    super.validate();

    if (serviceUrl.length == 0) {
      throw new ODataConfigurationException("Service URL cannot be empty");
    }

    if (authType == FioriAuthType.Basic) {
      if (username.length == 0 || password.length == 0) {
        throw new ODataConfigurationException(
          "Username and password are required for Basic authentication");
      }
    }

    if (authType == FioriAuthType.OAuth2 && oauthToken.length == 0) {
      throw new ODataConfigurationException(
        "OAuth token is required for OAuth2 authentication");
    }

    if (authType == FioriAuthType.ApiKey && apiKey.length == 0) {
      throw new ODataConfigurationException(
        "API key is required for API Key authentication");
    }
  }

  /**
     * Build OData query string from options
     */
  string buildQueryString(ODataQueryOptions options) const {
    return options.toQueryString();
  }

}
