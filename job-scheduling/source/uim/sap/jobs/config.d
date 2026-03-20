/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.jobs.config;

import uim.sap.jobs;

mixin(ShowModule!());

@safe:

  /**
  * Configuration class for the Job Scheduling service.
  * This class holds all the configuration parameters required to run the Job Scheduling service, such as:
  * - Host and port settings
  * - Service metadata (name, version)
  * - Scheduler settings (tick interval)
  * - Alerting and monitoring configurations
  * - Authentication settings
  * It also includes a `validate()` method to ensure that the configuration is correct before starting the service. 
  * Example usage:
  * ```d
  * JobSchedulingConfig config = new JobSchedulingConfig();
  * config.host = "localhost";
  * config.port = 8080;
  * config.basePath = "/api/job-scheduling";
  * config.serviceName = "uim-job-scheduling";
  * config.schedulerTickMs = 1000;
  * config.validate();
  * ```
  */
class JobSchedulingConfig : SAPConfig {
  mixin(SAPConfigTemplate!JobSchedulingConfig);

  override bool initialize(Json[string] initData) {
    if (!super.initialize(initData)) {
       return false;
    }

    port(cast(ushort)initData.getInteger("port", 8101));
    host(initData.getString("host", "0.0.0.0"));
    basePath(initData.getString("basePath", "/api/job-scheduling"));
    serviceName(initData.getString("serviceName", "uim-job-scheduling"));
    serviceVersion(initData.getString("serviceVersion", "1.0.0"));

    return true;
  }

  int schedulerTickMs = 1000;

  string alertEndpoint;
  string alertApiKey;
  string cloudAlmEndpoint;
  string cloudAlmApiKey;

  string outboundOauthToken;

  bool requireAuthToken = false;
  string authToken;


  override void validate() const {
    super.validate();

    if (schedulerTickMs < 200) {
      throw new JobSchedulingConfigurationException("Scheduler tick must be >= 200 ms");
    }
    if (requireAuthToken && authToken.length == 0) {
      throw new JobSchedulingConfigurationException(
        "Auth token required when token auth is enabled");
    }
  }
}
