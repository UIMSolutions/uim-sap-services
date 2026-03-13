module app;

import uim.sap.alertnotification;

mixin(ShowModule!());

@safe:

version (unittest) {
} else {
  void main() {
    AlertNotificationConfig config = new AlertNotificationConfig();
    config.host = envOr("ALERT_HOST", "0.0.0.0");
    config.port = readPort(envOr("ALERT_PORT", "8097"), 8097);
    config.basePath = envOr("ALERT_BASE_PATH", "/api/alert-notification");
    config.serviceName = envOr("ALERT_SERVICE_NAME", "uim-alert-notification");
    config.serviceVersion = envOr("ALERT_SERVICE_VERSION", UIM_ALERT_NOTIFICATION_VERSION);

    auto token = envOr("ALERT_AUTH_TOKEN", "");
    if (token.length > 0) {
      config.requireAuthToken(true);
      config.authToken = token;
    }

    config.customHeader("X-Service", config.serviceName);
    config.customHeader("X-Version", config.serviceVersion);

    auto service = new AlertNotificationService(config);
    auto server = new AlertNotificationServer(service);

    writeln("Starting Alert Notification service on ", config.host, ":", config.port);
    writeln("Base path: ", config.basePath);
    server.run();
  }
}
