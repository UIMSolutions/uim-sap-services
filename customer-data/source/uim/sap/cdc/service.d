module uim.sap.cdc.service;

import std.algorithm.searching : canFind;
import std.algorithm.sorting : sort;
import std.conv : to;
import std.datetime : Clock, SysTime, dur;
import std.string : indexOf, toLower;

import vibe.data.json : Json;

import uim.sap.cdc.config;
import uim.sap.cdc.exceptions;
import uim.sap.cdc.models;
import uim.sap.cdc.store;

class CDCService {
  private CDCConfig _config;
  private CDCStore _store;

  this(CDCConfig config) {
    config.validate();
    _config = config;
    _store = new CDCStore(config.cacheFilePath);
  }

  @property inout(CDCConfig) config() inout {
    return _config;
  }

  Json health() const {
    Json payload = Json.emptyObject;
    payload["status"] = "UP";
    payload["service"] = _config.serviceName;
    payload["version"] = _config.serviceVersion;
    payload["domain"] = "customer-data";
    return payload;
  }

  Json ready() const {
    Json payload = Json.emptyObject;
    payload["status"] = "READY";
    return payload;
  }

  Json upsertProfile(string tenantId, Json body) {
    validateTenant(tenantId);

    auto now = Clock.currTime();
    auto existing = _store.getProfileByTenantUser(tenantId, readRequired(body, "user_id"));

    CDCProfile profile;
    profile.tenantId = tenantId;
    profile.userId = readRequired(body, "user_id");
    profile.email = readOptional(body, "email", existing.isNull ? "" : existing.get.email);
    profile.phone = readOptional(body, "phone", existing.isNull ? "" : existing.get.phone);
    profile.firstName = readOptional(body, "first_name", existing.isNull ? "" : existing.get.firstName);
    profile.lastName = readOptional(body, "last_name", existing.isNull ? "" : existing.get.lastName);
    profile.region = readOptional(body, "region", existing.isNull ? _config.defaultRegion : existing.get.region);
    profile.siteGroupId = readOptional(
      body,
      "site_group_id",
      existing.isNull ? "global-default" : existing.get.siteGroupId
    );
    profile.passwordSecret = readOptional(
      body,
      "password",
      existing.isNull ? "changeme" : existing.get.passwordSecret
    );
    profile.active = readOptionalBool(body, "active", existing.isNull ? true : existing.get.active);
    profile.emailVerified = readOptionalBool(
      body,
      "email_verified",
      existing.isNull ? false : existing.get.emailVerified
    );
    profile.preferences = readObject(
      body,
      "preferences",
      existing.isNull ? Json.emptyObject : existing.get.preferences
    );
    profile.customAttributes = readObject(
      body,
      "custom_attributes",
      existing.isNull ? Json.emptyObject : existing.get.customAttributes
    );
    profile.failedLoginAttempts = existing.isNull ? 0 : existing.get.failedLoginAttempts;
    profile.hasLockedUntil = existing.isNull ? false : existing.get.hasLockedUntil;
    profile.lockedUntil = existing.isNull
      ? SysTime.fromISOExtString("1970-01-01T00:00:00Z")
      : existing.get.lockedUntil;
    profile.createdAt = existing.isNull ? now : existing.get.createdAt;
    profile.updatedAt = now;

    validateRegion(profile.region);

    auto saved = _store.upsertProfile(profile);

    Json payload = Json.emptyObject;
    payload["message"] = "Profile upserted";
    payload["profile"] = saved.toJson();
    return payload;
  }

  Json listProfiles(string tenantId, string region, string search, size_t limit, size_t offset) {
    validateTenant(tenantId);

    auto normalizedSearch = toLower(search);
    auto normalizedRegion = toLower(region);

    CDCProfile[] filtered;
    foreach (profile; _store.listProfilesByTenant(tenantId)) {
      if (normalizedRegion.length > 0 && toLower(profile.region) != normalizedRegion) continue;

      if (normalizedSearch.length > 0) {
        auto inEmail = toLower(profile.email).indexOf(normalizedSearch) >= 0;
        auto inName = (toLower(profile.firstName) ~ " " ~ toLower(profile.lastName)).indexOf(normalizedSearch) >= 0;
        auto inUser = toLower(profile.userId).indexOf(normalizedSearch) >= 0;
        if (!inEmail && !inName && !inUser) continue;
      }

      filtered ~= profile;
    }

    sort!((left, right) => left.updatedAt > right.updatedAt)(filtered);

    auto safeOffset = offset > filtered.length ? filtered.length : offset;
    auto safeLimit = limit == 0 ? 100 : limit;
    auto end = safeOffset + safeLimit;
    if (end > filtered.length) end = filtered.length;

    Json profiles = Json.emptyArray;
    foreach (profile; filtered[safeOffset .. end]) profiles ~= profile.toJson();

    Json payload = Json.emptyObject;
    payload["tenant_id"] = tenantId;
    payload["total"] = cast(long)filtered.length;
    payload["returned"] = cast(long)profiles.length;
    payload["offset"] = cast(long)safeOffset;
    payload["limit"] = cast(long)safeLimit;
    payload["profiles"] = profiles;
    return payload;
  }

  Json getProfile(string tenantId, string userId) {
    validateTenant(tenantId);
    if (userId.length == 0) throw new CDCValidationException("user_id is required");

    auto profile = _store.getProfileByTenantUser(tenantId, userId);
    if (profile.isNull) throw new CDCNotFoundException("Profile", userId);

    Json payload = Json.emptyObject;
    payload["profile"] = profile.get.toJson();
    return payload;
  }

  Json upsertConsent(string tenantId, string userId, Json body) {
    validateTenant(tenantId);
    if (userId.length == 0) throw new CDCValidationException("user_id is required");

    auto status = normalizeConsentStatus(readRequired(body, "status"));
    auto now = Clock.currTime();

    CDCConsent consent;
    consent.tenantId = tenantId;
    consent.userId = userId;
    consent.consentId = readRequired(body, "consent_id");
    consent.purpose = readRequired(body, "purpose");
    consent.legalBasis = readOptional(body, "legal_basis", "consent");
    consent.status = status;
    consent.source = readOptional(body, "source", "preference-center");
    consent.language = readOptional(body, "language", "en");
    consent.updatedAt = now;

    auto saved = _store.upsertConsent(consent);

    Json payload = Json.emptyObject;
    payload["message"] = "Consent preference saved";
    payload["transparency_note"] = "Consent state is visible and auditable for the end user";
    payload["consent"] = saved.toJson();
    return payload;
  }

  Json listConsents(string tenantId, string userId) {
    validateTenant(tenantId);
    if (userId.length == 0) throw new CDCValidationException("user_id is required");

    Json consents = Json.emptyArray;
    foreach (consent; _store.listConsents(tenantId, userId)) consents ~= consent.toJson();

    Json payload = Json.emptyObject;
    payload["tenant_id"] = tenantId;
    payload["user_id"] = userId;
    payload["count"] = cast(long)consents.length;
    payload["consents"] = consents;
    return payload;
  }

  Json upsertSiteGroup(string tenantId, Json body) {
    validateTenant(tenantId);

    auto now = Clock.currTime();

    CDCSiteGroup group;
    group.tenantId = tenantId;
    group.groupId = readRequired(body, "group_id");
    group.name = readRequired(body, "name");
    group.sites = readStringArray(body, "sites");
    group.regions = readStringArray(body, "regions");
    if (group.regions.length == 0) group.regions = [_config.defaultRegion];
    foreach (value; group.regions) validateRegion(value);
    group.createdAt = now;
    group.updatedAt = now;

    auto saved = _store.upsertSiteGroup(group);

    Json payload = Json.emptyObject;
    payload["message"] = "Global access site group saved";
    payload["site_group"] = saved.toJson();
    return payload;
  }

  Json listSiteGroups(string tenantId) {
    validateTenant(tenantId);

    Json groups = Json.emptyArray;
    foreach (group; _store.listSiteGroups(tenantId)) groups ~= group.toJson();

    Json payload = Json.emptyObject;
    payload["tenant_id"] = tenantId;
    payload["count"] = cast(long)groups.length;
    payload["site_groups"] = groups;
    return payload;
  }

  Json resolveGlobalAccess(string tenantId, string userId, string site) {
    validateTenant(tenantId);
    if (userId.length == 0) throw new CDCValidationException("user_id is required");

    auto profile = _store.getProfileByTenantUser(tenantId, userId);
    if (profile.isNull) throw new CDCNotFoundException("Profile", userId);

    auto siteGroup = _store.getSiteGroup(tenantId, profile.get.siteGroupId);

    Json payload = Json.emptyObject;
    payload["tenant_id"] = tenantId;
    payload["user_id"] = userId;
    payload["site"] = site;
    payload["data_region"] = profile.get.region;
    payload["site_group_id"] = profile.get.siteGroupId;
    payload["route"] = "regional-data-center";

    if (!siteGroup.isNull) {
      payload["site_group"] = siteGroup.get.toJson();
      payload["site_allowed"] = site.length == 0 || siteGroup.get.sites.canFind(site);
      payload["region_allowed"] = siteGroup.get.regions.canFind(profile.get.region);
    } else {
      payload["site_allowed"] = true;
      payload["region_allowed"] = true;
    }

    return payload;
  }

  Json upsertRiskProvider(string tenantId, Json body) {
    validateTenant(tenantId);

    auto now = Clock.currTime();

    CDCRiskProvider provider;
    provider.tenantId = tenantId;
    provider.providerId = readRequired(body, "provider_id");
    provider.name = readRequired(body, "name");
    provider.providerKind = normalizeProviderKind(readRequired(body, "provider_kind"));
    provider.enabled = readOptionalBool(body, "enabled", true);
    provider.config = readObject(body, "config", Json.emptyObject);
    provider.createdAt = now;
    provider.updatedAt = now;

    auto saved = _store.upsertRiskProvider(provider);

    Json payload = Json.emptyObject;
    payload["message"] = "Risk provider configured";
    payload["provider"] = saved.toJson();
    return payload;
  }

  Json listRiskProviders(string tenantId) {
    validateTenant(tenantId);

    Json providers = Json.emptyArray;
    foreach (provider; _store.listRiskProviders(tenantId)) providers ~= provider.toJson();

    Json payload = Json.emptyObject;
    payload["tenant_id"] = tenantId;
    payload["count"] = cast(long)providers.length;
    payload["providers"] = providers;
    return payload;
  }

  Json authenticate(string tenantId, Json body) {
    validateTenant(tenantId);

    auto userId = readRequired(body, "user_id");
    auto password = readRequired(body, "password");
    auto ipAddress = readOptional(body, "ip_address", "");

    auto profileOpt = _store.getProfileByTenantUser(tenantId, userId);
    if (profileOpt.isNull) throw new CDCNotFoundException("Profile", userId);

    auto profile = profileOpt.get;
    auto now = Clock.currTime();

    if (profile.hasLockedUntil && now < profile.lockedUntil) {
      return deniedAuthPayload(tenantId, userId, ipAddress, "deny_locked", "high", 100, Json.emptyObject);
    }

    auto providerSignals = readObject(body, "provider_signals", Json.emptyObject);

    auto riskScore = evaluateRiskScore(profile, ipAddress, providerSignals);
    auto riskLevel = riskLevelForScore(riskScore);

    if (profile.passwordSecret != password) {
      profile.failedLoginAttempts += 1;
      profile.updatedAt = now;

      if (profile.failedLoginAttempts >= 5) {
        profile.hasLockedUntil = true;
        profile.lockedUntil = now + dur!"minutes"(30);
      }

      _store.upsertProfile(profile);
      return deniedAuthPayload(
        tenantId,
        userId,
        ipAddress,
        "deny_invalid_credentials",
        riskLevel,
        riskScore,
        providerSignals
      );
    }

    if (riskLevel == "high") {
      profile.updatedAt = now;
      _store.upsertProfile(profile);

      Json payload = deniedAuthPayload(
        tenantId,
        userId,
        ipAddress,
        "challenge",
        riskLevel,
        riskScore,
        providerSignals
      );
      payload["step_up_required"] = true;
      payload["recommended_providers"] = supportedRiskProviderKinds();
      return payload;
    }

    profile.failedLoginAttempts = 0;
    profile.hasLockedUntil = false;
    profile.updatedAt = now;
    _store.upsertProfile(profile);

    auto event = appendAuthEvent(
      tenantId,
      userId,
      "internal-password",
      ipAddress,
      "allow",
      riskLevel,
      riskScore,
      providerSignals,
      now
    );

    Json payload = Json.emptyObject;
    payload["decision"] = "allow";
    payload["risk_level"] = riskLevel;
    payload["risk_score"] = riskScore;
    payload["session"] = Json.emptyObject;
    payload["session"]["token"] = "sess-" ~ userId ~ "-" ~ to!string(now.stdTime);
    payload["session"]["expires_in_seconds"] = 3600;
    payload["profile"] = profile.toJson();
    payload["auth_event"] = event.toJson();
    return payload;
  }

  Json listAuthEvents(string tenantId, size_t limit) {
    validateTenant(tenantId);

    auto safeLimit = limit == 0 ? 100 : limit;

    Json events = Json.emptyArray;
    foreach (event; _store.listAuthEvents(tenantId, safeLimit)) events ~= event.toJson();

    Json payload = Json.emptyObject;
    payload["tenant_id"] = tenantId;
    payload["count"] = cast(long)events.length;
    payload["events"] = events;
    return payload;
  }

  private Json deniedAuthPayload(
    string tenantId,
    string userId,
    string ipAddress,
    string decision,
    string riskLevel,
    long riskScore,
    Json providerSignals
  ) {
    auto now = Clock.currTime();
    auto event = appendAuthEvent(
      tenantId,
      userId,
      "internal-password",
      ipAddress,
      decision,
      riskLevel,
      riskScore,
      providerSignals,
      now
    );

    Json payload = Json.emptyObject;
    payload["decision"] = decision;
    payload["risk_level"] = riskLevel;
    payload["risk_score"] = riskScore;
    payload["auth_event"] = event.toJson();
    payload["message"] = decision == "challenge"
      ? "Step-up authentication required"
      : "Authentication blocked by account protection";
    return payload;
  }

  private CDCAuthEvent appendAuthEvent(
    string tenantId,
    string userId,
    string providerId,
    string ipAddress,
    string decision,
    string riskLevel,
    long riskScore,
    Json signals,
    SysTime now
  ) {
    CDCAuthEvent event;
    event.tenantId = tenantId;
    event.eventId = "evt-" ~ to!string(now.stdTime);
    event.userId = userId;
    event.providerId = providerId;
    event.ipAddress = ipAddress;
    event.decision = decision;
    event.riskLevel = riskLevel;
    event.riskScore = riskScore;
    event.providerSignals = signals;
    event.createdAt = now;
    return _store.appendAuthEvent(event);
  }

  private long evaluateRiskScore(CDCProfile profile, string ipAddress, Json providerSignals) {
    long score = 0;

    if (profile.failedLoginAttempts >= 3) score += 30;
    if (profile.hasLockedUntil) score += 40;

    if (ipAddress.length == 0) score += 5;

    if ("recaptcha_score" in providerSignals && providerSignals["recaptcha_score"].isFloat) {
      if (providerSignals["recaptcha_score"].get!double < 0.5) score += 40;
    }

    if ("akamai_risk" in providerSignals && providerSignals["akamai_risk"].isBoolean) {
      if (providerSignals["akamai_risk"].get!bool) score += 30;
    }

    if ("arkose_result" in providerSignals && providerSignals["arkose_result"].isString) {
      if (toLower(providerSignals["arkose_result"].get!string) == "suspicious") score += 35;
    }

    if ("transunion_score" in providerSignals && providerSignals["transunion_score"].isInteger) {
      if (providerSignals["transunion_score"].get!long > 700) score += 20;
    }

    if ("impossible_travel" in providerSignals && providerSignals["impossible_travel"].isBoolean) {
      if (providerSignals["impossible_travel"].get!bool) score += 25;
    }

    if (score > 100) score = 100;
    return score;
  }

  private string riskLevelForScore(long score) {
    if (score >= 70) return "high";
    if (score >= 30) return "medium";
    return "low";
  }

  private Json supportedRiskProviderKinds() {
    Json values = Json.emptyArray;
    values ~= "google-recaptcha";
    values ~= "akamai";
    values ~= "arkose-labs";
    values ~= "transunion";
    values ~= "custom";
    return values;
  }

  private void validateTenant(string tenantId) const {
    if (tenantId.length == 0) throw new CDCValidationException("tenant_id is required");
  }

  private void validateRegion(string value) const {
    if (value.length == 0) throw new CDCValidationException("region is required");
  }

  private string normalizeConsentStatus(string value) const {
    auto normalized = toLower(value);
    if (normalized != "granted" && normalized != "withdrawn" && normalized != "pending") {
      throw new CDCValidationException("status must be one of granted|withdrawn|pending");
    }
    return normalized;
  }

  private string normalizeProviderKind(string value) const {
    auto normalized = toLower(value);
    if (
      normalized != "google-recaptcha" && normalized != "akamai" && normalized != "arkose-labs" &&
      normalized != "transunion" && normalized != "custom"
    ) {
      throw new CDCValidationException(
        "provider_kind must be one of google-recaptcha|akamai|arkose-labs|transunion|custom"
      );
    }
    return normalized;
  }

  private string readRequired(Json body, string key) const {
    if (!(key in body) || body[key].type != Json.Type.string || body[key].get!string.length == 0) {
      throw new CDCValidationException(key ~ " is required");
    }
    return body[key].get!string;
  }

  private string readOptional(Json body, string key, string fallback) const {
    if (!(key in body) || body[key].type == Json.Type.null_) return fallback;
    if (body[key].type != Json.Type.string) throw new CDCValidationException(key ~ " must be a string");
    return body[key].get!string;
  }

  private bool readOptionalBool(Json body, string key, bool fallback) const {
    if (!(key in body) || body[key].type == Json.Type.null_) return fallback;
    if (body[key].type != Json.Type.bool_) throw new CDCValidationException(key ~ " must be a boolean");
    return body[key].get!bool;
  }

  private string[] readStringArray(Json body, string key) const {
    string[] values;
    if (!(key in body) || body[key].type == Json.Type.null_) return values;
    if (body[key].type != Json.Type.array) throw new CDCValidationException(key ~ " must be an array");
    foreach (item; body[key]) {
      if (item.type != Json.Type.string) throw new CDCValidationException(key ~ " must contain strings");
      values ~= item.get!string;
    }
    return values;
  }

  private Json readObject(Json body, string key, Json fallback) const {
    if (!(key in body) || body[key].type == Json.Type.null_) return fallback;
    if (body[key].type != Json.Type.object) throw new CDCValidationException(key ~ " must be an object");
    return body[key];
  }
}
