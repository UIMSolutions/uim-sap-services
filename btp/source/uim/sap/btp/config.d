module uim.sap.btp.config;

class BTPConfig : SAPConfig {
  mixin(SAPConfigTemplate!BTPConfig);
  
  string tenant;
  string subdomain;
  string region;
  string username;
  string password;
  string UUID;
  string clientSecret;
  string accessToken;
  string tokenType = "Bearer";
  bool useOAuth2 = false;
}

BTPConfig defaultConfig(
  string tenant,
  string subdomain,
  string region = "api.sap.hana.ondemand.com"
) {
  BTPConfig cfg;
  cfg.tenant = tenant;
  cfg.subdomain = subdomain;
  cfg.region = region;
  return cfg;
}

BTPConfig oAuth2Config(
  string tenant,
  string subdomain,
  UUID clientId,
  string clientSecret,
  string region = "api.sap.hana.ondemand.com"
) {
  auto cfg = defaultConfig(tenant, subdomain, region);
  cfg.clientId = clientId;
  cfg.clientSecret = clientSecret;
  cfg.useOAuth2 = true;
  return cfg;
}

string getBaseUrl(ref BTPConfig cfg) {
  if (cfg.subdomain.length > 0) {
    return "https://" ~ cfg.subdomain ~ "." ~ cfg.region;
  }
  return "https://" ~ cfg.region;
}
