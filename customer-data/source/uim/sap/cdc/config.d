module uim.sap.cdc.config;

import std.path : buildPath;
import std.string : startsWith;

import uim.sap.cdc.exceptions;

struct CDCConfig {
  string host = "0.0.0.0";
  ushort port = 8097;
  string basePath = "/api/customer-data";

  string serviceName = "uim-sap-customer-data";
  string serviceVersion = "1.0.0";

  string dataDirectory = "/tmp/uim-customer-data";
  string cacheFileName = "customer-data-cache.json";
  string defaultRegion = "eu-central";

  bool requireAuthToken = false;
  string authToken;

  string[string] customHeaders;

  @property string cacheFilePath() const {
    return buildPath(dataDirectory, cacheFileName);
  }

  void validate() const {
    if (host.length == 0) throw new CDCConfigurationException("Host cannot be empty");
    if (port == 0) throw new CDCConfigurationException("Port must be greater than zero");
    if (basePath.length == 0 || !basePath.startsWith("/")) {
      throw new CDCConfigurationException("Base path must start with '/'");
    }
    if (serviceName.length == 0) throw new CDCConfigurationException("Service name cannot be empty");
    if (dataDirectory.length == 0) throw new CDCConfigurationException("Data directory cannot be empty");
    if (cacheFileName.length == 0) throw new CDCConfigurationException("Cache file name cannot be empty");
    if (defaultRegion.length == 0) throw new CDCConfigurationException("Default region cannot be empty");
    if (requireAuthToken && authToken.length == 0) {
      throw new CDCConfigurationException("Auth token required when token auth is enabled");
    }
  }
}
