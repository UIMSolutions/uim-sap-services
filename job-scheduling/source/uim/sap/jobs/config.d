/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.jobs.config;

import std.string : startsWith;

import uim.sap.jobs.exceptions;

struct JobSchedulingConfig : SAPConfig {
    string host = "0.0.0.0";
    ushort port = 8101;
    string basePath = "/api/job-scheduling";

    string serviceName = "uim-sap-job-scheduling";
    string serviceVersion = "1.0.0";

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
            throw new JobSchedulingConfigurationException("Auth token required when token auth is enabled");
        }
    }
}
