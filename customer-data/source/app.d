module app;

import std.conv : to;
import std.process : environment;
import std.stdio : writeln;

import vibe.core.core : runApplication;

import uim.sap.cdc;

void main() {
  CDCConfig config;
  config.host = envOr("CDC_HOST", "0.0.0.0");
  config.port = readPort(envOr("CDC_PORT", "8097"), 8097);
  config.basePath = envOr("CDC_BASE_PATH", "/api/customer-data");
  config.serviceName = envOr("CDC_SERVICE_NAME", "uim-sap-customer-data");
  config.serviceVersion = envOr("CDC_SERVICE_VERSION", UIM_SAP_CDC_VERSION);
  config.dataDirectory = envOr("CDC_DATA_DIR", "/tmp/uim-customer-data");
  config.cacheFileName = envOr("CDC_CACHE_FILE", "customer-data-cache.json");
  config.defaultRegion = envOr("CDC_DEFAULT_REGION", "eu-central");

  auto token = envOr("CDC_AUTH_TOKEN", "");
  if (token.length > 0) {
    config.requireAuthToken = true;
    config.authToken = token;
  }

  config.customHeaders["X-Service"] = config.serviceName;
  config.customHeaders["X-Version"] = config.serviceVersion;

  auto service = new CDCService(config);
  auto server = new CDCServer(service);

  writeln("Starting Customer Data service on ", config.host, ":", config.port);
  writeln("Base path: ", config.basePath);
  writeln("Data directory: ", config.dataDirectory);

  server.run();
  runApplication();
}

private string envOr(string key, string fallback) {
  auto value = environment.get(key, "");
  return value.length > 0 ? value : fallback;
}

private ushort readPort(string value, ushort fallback) {
  try {
    auto parsed = to!ushort(value);
    return parsed > 0 ? parsed : fallback;
  } catch (Exception) {
    return fallback;
  }
}
