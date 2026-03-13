module app;

import std.conv : to;
import std.process : environment;
import std.stdio : writeln;

import vibe.core.core : runApplication;
import vibe.data.json : Json;

import uim.sap.cdc;

void main() {
  CDCConfig config;
  config.host = envOr("CDC_HOST", "0.0.0.0");
  config.port = readPort(envOr("CDC_PORT", "8097"), 8097);
  config.basePath = envOr("CDC_BASE_PATH", "/api/customer-data");
  config.serviceName = envOr("CDC_SERVICE_NAME", "uim-customer-data");
  config.serviceVersion = envOr("CDC_SERVICE_VERSION", UIM_CDC_VERSION);
  config.dataDirectory = envOr("CDC_DATA_DIR", "/tmp/uim-customer-data");
  config.cacheFileName = envOr("CDC_CACHE_FILE", "customer-data-cache.json");
  config.defaultRegion = envOr("CDC_DEFAULT_REGION", "eu-central");

  auto token = envOr("CDC_AUTH_TOKEN", "");
  if (token.length > 0) {
    config.requireAuthToken(true;)
    config.authToken = token;
  }

  auto service = new CDCService(config);

  auto runSmoke = envOr("CDC_INTERNAL_SMOKE", "") == "1";
  if (runSmoke) {
    runInternalSmoke(service);
    return;
  }

  writeln("Starting Customer Data service on ", config.host, ":", config.port);
  writeln("Base path: ", config.basePath);
  writeln("Data directory: ", config.dataDirectory);

  runCDCServer(
    service,
    config.host,
    config.port,
    config.basePath,
    config.requireAuthToken,
    config.authToken
  );
  runApplication();
}



private void runInternalSmoke(CDCService service) {
  auto tenantId = "demo-tenant";
  auto userId = "user-1001";

  Json siteGroup = Json.emptyObject;
  siteGroup["group_id"] = "brand-emea";
  siteGroup["name"] = "Brand Europe";
  siteGroup["sites"] = Json.emptyArray;
  siteGroup["sites"] ~= "shop.de";
  siteGroup["regions"] = Json.emptyArray;
  siteGroup["regions"] ~= "eu-central";
  auto siteGroupResult = service.upsertSiteGroup(tenantId, siteGroup);

  Json profile = Json.emptyObject;
  profile["user_id"] = userId;
  profile["email"] = "maria@example.com";
  profile["first_name"] = "Maria";
  profile["last_name"] = "Meyer";
  profile["region"] = "eu-central";
  profile["site_group_id"] = "brand-emea";
  profile["password"] = "demo-password";
  auto profileResult = service.upsertProfile(tenantId, profile);

  Json consent = Json.emptyObject;
  consent["consent_id"] = "email-marketing-v1";
  consent["purpose"] = "Email Marketing";
  consent["status"] = "granted";
  auto consentResult = service.upsertConsent(tenantId, userId, consent);

  Json riskProvider = Json.emptyObject;
  riskProvider["provider_id"] = "recaptcha-main";
  riskProvider["name"] = "Google reCAPTCHA";
  riskProvider["provider_kind"] = "google-recaptcha";
  riskProvider["enabled"] = true;
  auto riskProviderResult = service.upsertRiskProvider(tenantId, riskProvider);

  Json authPayload = Json.emptyObject;
  authPayload["user_id"] = userId;
  authPayload["password"] = "demo-password";
  authPayload["ip_address"] = "203.0.113.42";
  authPayload["provider_signals"] = Json.emptyObject;
  authPayload["provider_signals"]["recaptcha_score"] = 0.9;
  authPayload["provider_signals"]["akamai_risk"] = false;
  authPayload["provider_signals"]["arkose_result"] = "clean";
  authPayload["provider_signals"]["transunion_score"] = cast(long)420;
  authPayload["provider_signals"]["impossible_travel"] = false;
  auto authResult = service.authenticate(tenantId, authPayload);

  auto globalAccessResult = service.resolveGlobalAccess(tenantId, userId, "shop.de");

  writeln("INTERNAL_SMOKE_OK");
  writeln(siteGroupResult.toString());
  writeln(profileResult.toString());
  writeln(consentResult.toString());
  writeln(riskProviderResult.toString());
  writeln(authResult.toString());
  writeln(globalAccessResult.toString());
}
