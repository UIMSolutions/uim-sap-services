
import uim.sap.eventmesh;

mixin(ShowModule!());

@safe:

version (unittest) {
} else {
  void main() {
    EVMConfig config = new EVMConfig;
    config.host = envOr("EVM_HOST", "0.0.0.0");
    config.port = readPort(envOr("EVM_PORT", "8092"), 8092);
    config.basePath = envOr("EVM_BASE_PATH", "/api/em");
    config.serviceName = envOr("EVM_SERVICE_NAME", "uim-em");
    config.serviceVersion = envOr("EVM_SERVICE_VERSION", UIM_EVM_VERSION);

    auto token = envOr("EVM_AUTH_TOKEN", "");
    if (token.length > 0) {
      config.requireAuthToken(true);
      config.authToken(token);
    }

    config.customHeaders["X-Service"] = config.serviceName;
    config.customHeaders["X-Version"] = config.serviceVersion;

    auto service = new EVMService(config);
    auto server = new EVMServer(service);

    writeln("Starting Event Mesh service on ", config.host, ":", config.port);
    writeln("Base path: ", config.basePath);
    server.run();
  }
}
