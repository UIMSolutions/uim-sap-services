module tenant_config;

import std.json;
import std.file;
import std.array;

struct TenantConfig : SAPConfig {
  UUID tenantId;
  string domain;
  string databaseUrl;
  string apiKey;
}

TenantConfig[] loadTenantConfigurations(string configFilePath) {
  auto jsonData = cast(Json)parseJSON(readText(configFilePath));
  TenantConfig[] tenantConfigs;

  foreach (key, value; jsonData) {
    TenantConfig config = new TenantConfig();
    config.tenantId = key;
    config.domain = value["domain"].getString;
    config.databaseUrl = value["databaseUrl"].getString;
    config.apiKey = value["apiKey"].getString;
    tenantConfigs ~= config;
  }

  return tenantConfigs;
}
