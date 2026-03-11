/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.jobs.config;

import std.string : startsWith;

import uim.sap.jobs.exceptions;

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

  override bool initialize(Json[string] initdata) {
    if (!super.initialize(initdata)) {
       return false;
    }

    port(cast(ushort)initdata.getInteger("port", 8101));
    host(initdata.getString("host", "0.0.0.0"));
    basePath(initdata.getString("basePath", "/api/job-scheduling"));
    serviceName(initdata.getString("serviceName", "uim-job-scheduling"));
    serviceVersion(initdata.getString("serviceVersion", "1.0.0"));

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

  string[string] customHeaders;

  void validate() const {
    super.validate();

    if (host.length == 0) {
      throw new JobSchedulingConfigurationException("Host cannot be empty");
    }
    if (port == 0) {
      throw new JobSchedulingConfigurationException("Port must be greater than zero");
    }
    if (basePath.length == 0 || !basePath.startsWith("/")) {
      throw new JobSchedulingConfigurationException("Base path must start with '/'");
    }
    if (serviceName.length == 0) {
      throw new JobSchedulingConfigurationException("Service name cannot be empty");
    }
    if (schedulerTickMs < 200) {
      throw new JobSchedulingConfigurationException("Scheduler tick must be >= 200 ms");
    }
    if (requireAuthToken && authToken.length == 0) {
      throw new JobSchedulingConfigurationException(
        "Auth token required when token auth is enabled");
    }
  }
}
