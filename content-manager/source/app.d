module app;

import std.conv : to;
import std.process : environment;
import std.stdio : writeln;

import uim.sap.cmg;

mixin(ShowModule!());

@safe:

void main() {
  CMGConfig config;
  config.host = envOr("CMG_HOST", "0.0.0.0");
  config.port = readPort(envOr("CMG_PORT", "8095"), 8095);
  config.basePath = envOr("CMG_BASE_PATH", "/api/cmg");
  config.serviceName = envOr("CMG_SERVICE_NAME", "uim-sap-cmg");
  config.serviceVersion = envOr("CMG_SERVICE_VERSION", UIM_CMG_VERSION);

  auto token = envOr("CMG_AUTH_TOKEN", "");
  if (token.length > 0) {
    config.requireAuthToken = true;
    config.authToken = token;
  }

  config.customHeaders["X-Service"] = config.serviceName;
  config.customHeaders["X-Version"] = config.serviceVersion;

  auto service = new CMGService(config);
  auto server = new CMGServer(service);

  writeln("Starting Content Manager service on ", config.host, ":", config.port);
  writeln("Base path: ", config.basePath);
  server.run();
}

