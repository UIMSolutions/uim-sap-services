module uim.sap.mob.config;

import uim.sap.mob;

mixin(ShowModule!());

@safe:

class MOBConfig : SAPConfig {
  override bool initialize(Json[string] initdata) {
    if (!super.initialize(initdata)) {
      return false;
    }

    // Network
    basePath(initdata.getString("basePath", "/api/mob"));
    host(initdata.getString("host", "0.0.0.0"));
    port(cast(ushort)initdata.getInteger("port", 8089));

    // Service metadata
    serviceName(initdata.getString("serviceName", "uim-mob"));
    serviceVersion(initdata.getString("serviceVersion", "1.0.0"));

    return true;
  }

  bool requireAuthToken = false;
  string authToken;

  /// Maximum applications managed
  size_t maxApplications = 500;

  /// Maximum versions per application
  size_t maxVersionsPerApp = 100;

  /// Maximum user connections per application
  size_t maxUsersPerApp = 10_000;

  /// Maximum push notifications retained per app
  size_t maxNotificationsPerApp = 5000;

  /// Default offline sync interval in seconds
  size_t defaultSyncIntervalSecs = 300;

  string[string] customHeaders;

  override void validate() const {
    super.validate();

    if (requireAuthToken && authToken.length == 0)
      throw new MOBConfigurationException("Auth token required when token auth is enabled");
    if (maxApplications == 0)
      throw new MOBConfigurationException("maxApplications must be greater than zero");
  }
}
