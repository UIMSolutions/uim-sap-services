/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.datasphere.config;

import uim.sap.datasphere;

mixin(ShowModule!());

@safe:

/**
  * Configuration class for the DataSphere service.
  * This class extends the base SAPConfig and adds specific settings for DataSphere.
  * It includes properties for default space resources, authentication, and custom headers.
  * The initialize method populates the configuration from a JSON object, and the validate method checks for required fields and logical consistency.
  */
class DSPConfig : SAPConfig {
  mixin(SAPConfigTemplate!DSPConfig);

  /** 
    * Initializes the configuration properties from a JSON object.
    * This method calls the base class initialize method and then populates additional properties specific to DataSphere.
    * It sets default values for network settings and service metadata if they are not provided in the input JSON.
    * If the base initialization fails, it returns false to indicate unsuccessful initialization.
    */
  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    /// Network
    basePath(initData.getString("basePath", "/api/datasphere"));
    host(initData.getString("host", "0.0.0.0"));
    port(cast(ushort)initData.getInteger("port", 8098));
    
    /// Service metadata
    serviceName(initData.getString("serviceName", "uim-datasphere"));
    serviceVersion(initData.getString("serviceVersion", "1.0.0"));

    return true;
  }

  int defaultSpaceDiskGb = 50;
  int defaultSpaceMemoryGb = 16;

  bool requireAuthToken = false;
  string authToken;

  string[string] customHeaders;

  /**
    * Validates the configuration properties to ensure they meet required criteria.
    * This method checks for non-empty values, positive integers, and logical consistency between related properties.
    * If any validation check fails, a DSPConfigurationException is thrown with a descriptive error message.
    */
  override void validate() const {
    super.validate();

    if (defaultSpaceDiskGb <= 0)
      throw new DSPConfigurationException("Default space disk must be > 0");
    if (defaultSpaceMemoryGb <= 0)
      throw new DSPConfigurationException("Default space memory must be > 0");
    if (requireAuthToken && authToken.length == 0) {
      throw new DSPConfigurationException("Auth token required when token auth is enabled");
    }
  }
}
