/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.clf.config;

import uim.sap.clf;

mixin(ShowModule!());

@safe:

/**
 * CLFConfig is the configuration class for the Cloud Foundry runtime environment.
 * It extends the base SAPConfig and provides additional settings specific to CLF.
 *
  * Configuration options include:
  * - Network settings: basePath, host, port  
  * - Service settings: serviceName, serviceVersion
  * - Authentication settings: requireAuthToken, authToken
 * The initialize method populates the configuration from a JSON object, with default values for each setting.
 * The validate method ensures that required settings are properly set and throws exceptions if validation fails.
 */   
class CLFConfig : SAPConfig {
  mixin(SAPConfigTemplate!AgentryConfig);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    // Network settings
    basePath(initData.getString("basePath", "/api/cf"));
    host(initData.getString("host", "0.0.0.0"));
    port(cast(ushort)initData.getInteger("port", 8082));

    // Service settings
    serviceName(initData.getString("serviceName", "uim-clf"));
    serviceVersion(initData.getString("serviceVersion", "1.0.0"));

    // Authentication settings
    requireAuthToken(initData.getBoolean("requireAuthToken", false));
    if (requireAuthToken) {
      authToken(initData.getString("authToken", ""));
    }
    
    return true;
  }
}
///
unittest {
  CLFConfig config = new CLFConfig();
  assert(config.basePath == "/api/cf");
  assert(config.host == "0.0.0.0");
  assert(config.port == 8082);
  assert(config.serviceName == "uim-clf");
  assert(config.serviceVersion == "1.0.0");
  assert(config.requireAuthToken == false);
}