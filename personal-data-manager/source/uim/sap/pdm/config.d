/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.pdm.config;

import uim.sap.pdm;

mixin(ShowModule!());

@safe:

struct PDMConfig : SAPConfig {

    override bool initialize(Json[string] initdata) {
    if (!super.initialize(initdata)) {
       return false;
    }

    return true;
  }
    string host = "0.0.0.0";
    ushort port = 8092;
    string basePath = "/api/pdm";

    string serviceName = "uim-pdm";
    string serviceVersion = "1.0.0";

    bool requireAuthToken = false;
    string authToken;

    /// Maximum data subjects per tenant
    size_t maxSubjectsPerTenant = 100_000;

    /// Maximum active requests per tenant
    size_t maxRequestsPerTenant = 10_000;

    /// Maximum personal data records per subject
    size_t maxRecordsPerSubject = 500;

    /// Request processing timeout in seconds
    size_t requestTimeoutSecs = 86_400;

    /// Default tenant ID for single-tenant mode
    string defaultTenantId = "default";

    /// Enable multitenancy
    bool multitenancy = true;

    string[string] customHeaders;

    override void validate() const {
        super.validate();

        if (host.length == 0)
            throw new PDMConfigurationException("Host cannot be empty");
        if (port == 0)
            throw new PDMConfigurationException("Port must be greater than zero");
        if (basePath.length == 0 || !basePath.startsWith("/"))
            throw new PDMConfigurationException("Base path must start with '/'");
        if (requireAuthToken && authToken.length == 0)
            throw new PDMConfigurationException("Auth token required when token auth is enabled");
        if (maxSubjectsPerTenant == 0)
            throw new PDMConfigurationException("maxSubjectsPerTenant must be greater than zero");
    }
}
