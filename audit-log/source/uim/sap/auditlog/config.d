module uim.sap.auditlog.config;

import std.string : startsWith, toLower;

import uim.sap.auditlog.exceptions;

class AuditLogConfig : SAPConfig {
  mixin(SAPConfigTemplate!AuditLogConfig);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    // Network configuration
    basePath(initData.getString("basePath", "/api/auditlog"));
    host(initData.getString("host", "0.0.0.0"));
    port(cast(ushort)initData.getInteger("port", 8090));

    // Service metadata
    serviceName(initData.getString("serviceName", "uim-audit-log"));
    serviceVersion(initData.getString("serviceVersion", "1.0.0"));

    // Authentication configuration
    requireAuthToken(initData.getBool("requireAuthToken", false));
    if (requireAuthToken) {
      authToken(initData.getString("authToken", ""));
    }

    return true;
  }

  int defaultRetentionDays = 90;
  string defaultPlan = "default";
  double premiumCostPerThousandEvents = 0.75;

  bool requireOAuthToken = false;
  string oauthToken;

  string[string] customHeaders;

  override void validate() const {
    super.validate();

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

    if (requireOAuthToken && oauthToken.length == 0) {
      throw new AuditLogConfigurationException(
        "OAuth token required when OAuth write protection is enabled");
    }
  }
}
