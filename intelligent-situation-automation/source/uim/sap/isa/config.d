/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.isa.config;
import uim.sap.isa;

mixin(ShowModule!());

@safe:

class ISAConfig : SAPConfig {
  mixin(SAPConfigTemplate!ISAConfig);

  string host = "0.0.0.0";
  ushort port = 8088;
  string basePath = "/api/situation-automation";

  string serviceName = "uim-isa";
  string serviceVersion = "1.0.0";

  string defaultTenant = "default";

  bool requireAuthToken = false;
  string authToken;

  string[string] customHeaders;

  override void validate() const {
    super.validate();

    if (host.length == 0) {
      throw new ISAConfigurationException("Host cannot be empty");
    }
    if (port == 0) {
      throw new ISAConfigurationException("Port must be greater than zero");
    }
    if (basePath.length == 0 || !basePath.startsWith("/")) {
      throw new ISAConfigurationException("Base path must start with '/'");
    }
    if (defaultTenant.length == 0) {
      throw new ISAConfigurationException("Default tenant cannot be empty");
    }
    if (requireAuthToken && authToken.length == 0) {
      throw new ISAConfigurationException("Auth token required when token auth is enabled");
    }
  }
}
