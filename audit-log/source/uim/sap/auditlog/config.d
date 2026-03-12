module uim.sap.auditlog.config;

import std.string : startsWith, toLower;

import uim.sap.auditlog.exceptions;

class AuditLogConfig : SAPConfig {
  mixin(SAPConfigTemplate!AuditLogConfig);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    port(cast(ushort)initData.getInteger("port", 8090));
    basePath(initData.getString("basePath", "/api/auditlog"));
    serviceName(initData.getString("serviceName", "uim-audit-log"));
    serviceVersion(initData.getString("serviceVersion", "1.0.0"));
    host(initData.getString("host", "0.0.0.0"));
    
    return true;
  }

  int defaultRetentionDays = 90;
  string defaultPlan = "default";
  double premiumCostPerThousandEvents = 0.75;

  bool requireAuthToken = false;
  string authToken;

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

    if (requireAuthToken && authToken.length == 0) {
      throw new AuditLogConfigurationException("Auth token required when auth is enabled");
    }

    if (requireOAuthToken && oauthToken.length == 0) {
      throw new AuditLogConfigurationException(
        "OAuth token required when OAuth write protection is enabled");
    }
  }
}
