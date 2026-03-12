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

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    host(initData.getString("host", "0.0.0.0"));
    port(cast(ushort)initData.getInteger("port", 8098));
    basePath(initData.getString("basePath", "/api/datasphere"));
    serviceName(initData.getString("serviceName", "uim-datasphere"));
    serviceVersion(initData.getString("serviceVersion", "1.0.0"));

    return true;
  }

  int defaultSpaceDiskGb = 50;
  int defaultSpaceMemoryGb = 16;

  bool requireAuthToken = false;
  string authToken;

  string[string] customHeaders;

  override void validate() const {
    super.validate();

    if (host.length == 0)
      throw new DSPConfigurationException("Host cannot be empty");
    if (port == 0)
      throw new DSPConfigurationException("Port must be greater than zero");
    if (basePath.length == 0 || !basePath.startsWith("/")) {
      throw new DSPConfigurationException("Base path must start with '/'");
    }
    if (serviceName.length == 0)
      throw new DSPConfigurationException("Service name cannot be empty");
    if (defaultSpaceDiskGb <= 0)
      throw new DSPConfigurationException("Default space disk must be > 0");
    if (defaultSpaceMemoryGb <= 0)
      throw new DSPConfigurationException("Default space memory must be > 0");
    if (requireAuthToken && authToken.length == 0) {
      throw new DSPConfigurationException("Auth token required when token auth is enabled");
    }
  }
}
