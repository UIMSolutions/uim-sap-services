/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
modulemodule uim.sap.obs.config;

import uim.sap.obs;

mixin(ShowModule!());

@safe:

/** 
  * Configuration class for the Object Store Service (OBS).
  * This class extends the base SAPConfig and adds OBS-specific configuration parameters.
  *
  * It includes validation logic to ensure that the configuration is correct before the service starts.
  *
  * Configuration parameters include:
  * - host: The hostname or IP address to bind the service to (default "0.0.0.0")
  * - port: The port number to bind the service to (default 8091)
  * - basePath: The base path for the API endpoints (default "/api/obs")
  * - serviceName: The name of the service (default "uim-obs")
  * - serviceVersion: The version of the service (default "1.0.0")
  * - requireAuthToken: Whether an authentication token is required (default false)
  * - authToken: The authentication token to use if required
  * - maxBucketsPerTenant: The maximum number of buckets allowed per tenant (default 100)
  * - maxObjectsPerBucket: The maximum number of objects allowed per bucket (default 100,000)
  * - maxObjectSizeBytes: The maximum size of an object in bytes (default 5 GiB)
  * - maxMultipartParts: The maximum number of parts allowed in a multipart upload (default 10,000)
  * - replicationFactor: The default replication factor for stored objects (default 3)
  * - credentialExpirySecs: The expiry time for credentials in seconds (default 3600)
  * - customHeaders: A dictionary of custom headers to include in responses
  *
  * The validate() method checks for required fields and valid values, throwing an OBSConfigurationException if any issues are found.
  */
class OBSConfig : SAPConfig {
  mixin(SAPConfigTemplate!OBSConfig);

  override bool initialized(Json[string] initData = null) {
    if (!super.initialized(initData)) {
      return false;
    }

    /// Network
    basePath(initData.getString("basePath", "/api/obs"));
    host(initData.getString("host", "0.0.0.0"));
    port(cast(ushort)inidata.getInteger("port", 8091));

    /// Service metadata
    serviceName(initData.getString("serviceName", "uim-obs"));
    serviceVersion(initData.getString("serviceVersion", "1.0.0"));

    return true;
  }

  bool requireAuthToken = false;
  string authToken;

  /// Maximum buckets per tenant
  size_t maxBucketsPerTenant = 100;

  /// Maximum objects per bucket
  size_t maxObjectsPerBucket = 100_000;

  /// Maximum object size in bytes (default 5 GiB)
  size_t maxObjectSizeBytes = 5L * 1024 * 1024 * 1024;

  /// Maximum multipart upload parts
  size_t maxMultipartParts = 10_000;

  /// Default storage replication factor
  size_t replicationFactor = 3;

  /// Credential expiry in seconds
  size_t credentialExpirySecs = 3600;

  string[string] customHeaders;

  override void validate() const {
    super.validate();

    if (requireAuthToken && authToken.length == 0)
      throw new OBSConfigurationException("Auth token required when token auth is enabled");
    if (maxBucketsPerTenant == 0)
      throw new OBSConfigurationException("maxBucketsPerTenant must be greater than zero");
  }
}
