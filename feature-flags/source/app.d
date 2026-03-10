module app;

import uim.sap.featureflags;

mixin(ShowModule!());

@safe:

version (unittest) {
} else {
  void main() {
    FFLConfig config = new FFLConfig;
    config.host = envOr("FFL_HOST", "0.0.0.0");
    config.port = readPort(envOr("FFL_PORT", "8094"), 8094);
    config.basePath = envOr("FFL_BASE_PATH", "/api/ff");
    config.serviceName = envOr("FFL_SERVICE_NAME", "uim-ff");
    config.serviceVersion = envOr("FFL_SERVICE_VERSION", UIM_FFL_VERSION);

    auto token = envOr("FFL_AUTH_TOKEN", "");
    if (token.length > 0) {
      config.requireAuthToken = true;
      config.authToken = token;
    }

    config.customHeaders["X-Service"] = config.serviceName;
    config.customHeaders["X-Version"] = config.serviceVersion;

    auto service = new FFLService(config);
    auto server = new FFLServer(service);

    writeln("Starting Feature Flags service on ", config.host, ":", config.port);
    writeln("Base path: ", config.basePath);
    server.run();
  }
}
