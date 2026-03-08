module tenant_config;

import std.json;
import std.file;
import std.array;

struct TenantConfig : SAPConfig, ISAPConfig {
    string tenantId;
    string domain;
    string databaseUrl;
    string apiKey;
}

TenantConfig[] loadTenantConfigurations(string configFilePath) {
    auto jsonData = cast(Json) parseJSON(readText(configFilePath));
    TenantConfig[] tenantConfigs;

    foreach (key, value; jsonData) {
        TenantConfig config;
        config.tenantId = key;
        config.domain = value["domain"].str;
        config.databaseUrl = value["databaseUrl"].str;
        config.apiKey = value["apiKey"].str;
        tenantConfigs ~= config;
    }

    return tenantConfigs;
}