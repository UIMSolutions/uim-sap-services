module uim.sap.auditlog.config;

import std.string : startsWith, toLower;

import uim.sap.auditlog.exceptions;

class AuditLogConfig : SAPHostConfig {
  mixin(SAPConfigTemplate!AgentryConfig);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    host(initData.getString("host", "0.0.0.0"));
  }
  ushort port = 8090;
  string basePath = "/api/auditlog";

  string serviceName = "uim-sap-audit-log";
  string serviceVersion = "1.0.0";

  int defaultRetentionDays = 90;
  string defaultPlan = "default";
  double premiumCostPerThousandEvents = 0.75;

  bool requireAuthToken = false;
  string authToken;

  bool requireOAuthToken = false;
  string oauthToken;

  string[string] customHeaders;

  void validate() const {
    if (host.length == 0) {
      throw new AuditLogConfigurationException("Host cannot be empty");
    }
    if (port == 0) {
      throw new AuditLogConfigurationException("Port must be greater than zero");
    }
    if (basePath.length == 0 || !basePath.startsWith("/")) {
      throw new AuditLogConfigurationException("Base path must start with '/'");
    }
    if (serviceName.length == 0) {
      throw new AuditLogConfigurationException("Service name cannot be empty");
    }
    if (defaultRetentionDays <= 0) {
      throw new AuditLogConfigurationException("Default retention must be greater than zero days");
    }
    auto plan = toLower(defaultPlan);
    if (plan != "default" && plan != "premium") {
      throw new AuditLogConfigurationException("default_plan must be 'default' or 'premium'");
    }
    if (premiumCostPerThousandEvents < 0) {
      throw new AuditLogConfigurationException("Premium cost cannot be negative");
    }
    if (requireAuthToken && authToken.length == 0) {
      throw new AuditLogConfigurationException("Auth token required when auth is enabled");
    }
    if (requireOAuthToken && oauthToken.length == 0) {
      throw new AuditLogConfigurationException(
        "OAuth token required when OAuth write protection is enabled");
    }
  }
}
