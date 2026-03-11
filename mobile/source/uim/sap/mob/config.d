module uim.sap.mob.config;

import uim.sap.mob;

mixin(ShowModule!());

@safe:

struct MOBConfig : SAPConfig {
    override bool initialize(Json[string] initdata) {
    if (!super.initialize(initdata)) {
       return false;
    }

    return true;
  }
    string host = "0.0.0.0";
    ushort port = 8089;
    string basePath = "/api/mob";

    string serviceName = "uim-mob";
    string serviceVersion = "1.0.0";

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

        if (host.length == 0)
            throw new MOBConfigurationException("Host cannot be empty");
        if (port == 0)
            throw new MOBConfigurationException("Port must be greater than zero");
        if (basePath.length == 0 || !basePath.startsWith("/"))
            throw new MOBConfigurationException("Base path must start with '/'");
        if (requireAuthToken && authToken.length == 0)
            throw new MOBConfigurationException("Auth token required when token auth is enabled");
        if (maxApplications == 0)
            throw new MOBConfigurationException("maxApplications must be greater than zero");
    }
}
