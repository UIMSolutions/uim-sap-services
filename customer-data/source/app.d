module app;

import std.conv : to;
import std.process : environment;
import std.stdio : writeln;

import vibe.core.core : runApplication;
import vibe.data.json : Json;

import uim.sap.cdc;

void main() {
  CDCConfig config = new CDCConfig();
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
    config.requireAuthToken(true);
    config.authToken(token);
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

  Json siteGroup = Json.emptyObject
    .set("group_id", "brand-emea")
    .set("name", "Brand Europe")
    .set("sites", Json.emptyArray
        .set(0, "shop.de")
    )
    .set("regions", Json.emptyArray
        .set(0, "eu-central")
    );
  auto siteGroupResult = service.upsertSiteGroup(tenantId, siteGroup);

  Json profile = Json.emptyObject
    .set("user_id", userId)
    .set("email", "maria@example.com")
    .set("first_name", "Maria")
    .set("last_name", "Meyer")
    .set("region", "eu-central")
    .set("site_group_id", "brand-emea")
    .set("password", "demo-password");
  auto profileResult = service.upsertProfile(tenantId, profile);

  Json consent = Json.emptyObject
    .set("consent_id", "email-marketing-v1")
    .set("purpose", "Email Marketing")
    .set("status", "granted");
  auto consentResult = service.upsertConsent(tenantId, userId, consent);

  Json riskProvider = Json.emptyObject
    .set("provider_id", "recaptcha-main")
    .set("name", "Google reCAPTCHA")
    .set("provider_kind", "google-recaptcha")
    .set("enabled", true);
  auto riskProviderResult = service.upsertRiskProvider(tenantId, riskProvider);

  Json authPayload = Json.emptyObject
    .set("user_id", userId)
    .set("password", "demo-password")
    .set("ip_address", "203.0.113.42")
    .set("provider_signals", Json.emptyObject
        .set("recaptcha_score", 0.9)
        .set("akamai_risk", false)
        .set("arkose_result", "clean")
        .set("transunion_score", cast(long)420)
        .set("impossible_travel", false)
    );
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
