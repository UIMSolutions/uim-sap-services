
import uim.sap.eventmesh;

mixin(ShowModule!());

@safe:

version (unittest) {
} else {
  void main() {
    EMConfig config = new EMConfig;
    config.host = envOr("EM_HOST", "0.0.0.0");
    config.port = readPort(envOr("EM_PORT", "8092"), 8092);
    config.basePath = envOr("EM_BASE_PATH", "/api/em");
    config.serviceName = envOr("EM_SERVICE_NAME", "uim-sap-em");
    config.serviceVersion = envOr("EM_SERVICE_VERSION", UIM_EM_VERSION);

    auto token = envOr("EM_AUTH_TOKEN", "");
    if (token.length > 0) {
      config.requireAuthToken = true;
      config.authToken = token;
    }

    config.customHeaders["X-Service"] = config.serviceName;
    config.customHeaders["X-Version"] = config.serviceVersion;

    auto service = new EMService(config);
    auto server = new EMServer(service);

    writeln("Starting Event Mesh service on ", config.host, ":", config.port);
    writeln("Base path: ", config.basePath);
    server.run();
  }
}
