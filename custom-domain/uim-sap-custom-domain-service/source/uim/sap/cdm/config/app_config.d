module config;

import vibe.vibe;

struct AppConfig : SAPConfig {
  string serverHost;
  int serverPort;
  string environment;
  string logLevel;
}

AppConfig loadAppConfig() {
  return AppConfig(
serverHost : "0.0.0.0",
serverPort:
    8080,
environment:
    "development",
logLevel:
    "info"
  );
}
