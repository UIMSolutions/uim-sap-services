module uim.sap.dqm.config;

import uim.sap.dqm;

mixin(ShowModule!());

@safe:

class DQMConfig : SAPConfig {
  mixin(SAPConfigTemplate!DQMConfig);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    // Network
    basePath(initData.getString("basePath", "/api/dqm"));
    host(initData.getString("host", "0.0.0.0"));
    port(cast(ushort)initData.getInteger("port", 8091));

    // Service metadata
    serviceName(initData.getString("serviceName", "uim-dqm"));
    serviceVersion(initData.getString("serviceVersion", "1.0.0"));

    /// Default country
    defaultCountry(initData.getString("defaultCountry", "DE"));

    // Authentication configuration
    requireAuthToken(initData.getBool("requireAuthToken", false));
    if (requireAuthToken) {
      authToken(initData.getString("authToken", ""));
    }

    return true;
  }

  /** 
    * Default country code to use for data quality checks when country is not specified in the input data.
    * Should be a valid ISO 3166-1 alpha-2 country code (e.g. "DE", "US", "FR").
    * This is used to provide better data quality results by applying country-specific rules and reference data.
    */
  override void validate() const {
    super.validate();
    
    if (defaultCountry.length == 0)
      throw new DQMConfigurationException("Default country cannot be empty");
    if (requireAuthToken && authToken.length == 0)
      throw new DQMConfigurationException("Auth token required when token auth is enabled");
  }
}
