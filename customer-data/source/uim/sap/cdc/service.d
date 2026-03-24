/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.cdc.service;

import uim.sap.cdc;

mixin(ShowModule!());

@safe:

class CDCService : SAPService {
  mixin(SAPServiceTemplate!CDCService);

  private CDCStore _store;

  this(CDCConfig config) {
    super(config);

    _store = new CDCStore(config.cacheFilePath);
  }

  Json health() const {
    return super.health()
      .set("domain", "customer-data");
  }

  Json upsertProfile(UUID tenantId, Json data) {
    validateTenant(tenantId);

    auto now = Clock.currTime();
    auto existing = _store.getProfileByTenantUser(tenantId, requiredString(data, "user_id"));

    CDCProfile profile = new CDCProfile(data);
    profile.tenantId = tenantId;
    profile.userId = UUID(data.requiredString("user_id"));
    profile.email = data.getString("email", existing.isNull ? "" : existing.get.email);
    profile.phone = data.getString("phone", existing.isNull ? "" : existing.get.phone);
    profile.firstName = data.getString("first_name",
      existing.isNull ? "" : existing.get.firstName);
    profile.lastName = data.getString("last_name",
      existing.isNull ? "" : existing.get.lastName);
    profile.region = data.getString("region",
      existing.isNull ? _config.defaultRegion : existing.get.region);
    profile.siteGroupId = UUID(data.getString("site_group_id",
        existing.isNull ? "global-default" : existing.get.siteGroupId));
    profile.passwordSecret = data.getString("password", existing.isNull ?
        "changeme" : existing.get.passwordSecret);
    profile.active = data.getBoolean("active", existing.isNull ? true : existing.get.active);
    profile.emailVerified = data.getBoolean("email_verified", existing.isNull ? false
        : existing.get.emailVerified);
    profile.preferences = data.readObject("preferences",
      existing.isNull ? Json.emptyObject : existing.get.preferences
    );
    profile.customAttributes = data.readObject("custom_attributes",
      existing.isNull ? Json.emptyObject : existing.get.customAttributes
    );
    profile.failedLoginAttempts = existing.isNull ? 0 : existing.get.failedLoginAttempts;
    profile.hasLockedUntil = existing.isNull ? false : existing.get.hasLockedUntil;
    profile.lockedUntil = existing.isNull
      ? SysTime.fromISOExtString("1970-01-01T00:00:00Z") : existing.get.lockedUntil;
    profile.createdAt = existing.isNull ? now : existing.get.createdAt;
    profile.updatedAt = now;

    validateRegion(profile.region);
    auto saved = _store.upsertProfile(profile);

    Json payload = Json.emptyObject;
    return payload
      .set("message", "Profile upserted")
      .set("profile", saved.toJson());
  }

  Json listProfiles(UUID tenantId, string region, string search, size_t limit, size_t offset) {
    validateTenant(tenantId);
    auto normalizedSearch = toLower(search);
    auto normalizedRegion = toLower(
      region);
    CDCProfile[] filtered;
    foreach (profile; _store.listProfilesByTenant(tenantId)) {
      if (normalizedRegion.length > 0 && toLower(profile.region) != normalizedRegion)
        continue;
      if (normalizedSearch.length > 0) {
        auto inEmail = toLower(profile.email).indexOf(normalizedSearch) >= 0;
        auto inName = (toLower(profile.firstName) ~ " " ~ toLower(profile.lastName)).indexOf(
          normalizedSearch) >= 0;
        auto inUser = toLower(profile.userId).indexOf(
          normalizedSearch) >= 0;
        if (!inEmail && !inName && !inUser)
          continue;
      }

      filtered ~= profile;
    }

    sort!((left, right) => left.updatedAt > right.updatedAt)(filtered);
    auto safeOffset = offset > filtered
      .length ? filtered.length : offset;
    auto safeLimit = limit == 0 ? 100 : limit;
    auto end = safeOffset + safeLimit;
    if (end > filtered.length)
      end = filtered.length;

    Json profiles = filtered[safeOffset .. end].map!(profile => profile.toJson()).array.toJson;

    Json payload = Json.emptyObject;
    return payload
      .set("tenant_id", tenantId)
      .set("total", cast(long)filtered.length)
      .set("returned", cast(long)profiles.length)
      .set("offset", cast(long)safeOffset)
      .set("limit", cast(long)safeLimit)
      .set("profiles", profiles);
  }

  Json getProfile(UUID tenantId, string userId) {
    validateTenant(tenantId);
    if (userId.length == 0)
      throw new CDCValidationException("user_id is required");
    auto profile = _store
      .getProfileByTenantUser(tenantId, userId);
    if (profile.isNull)
      throw new CDCNotFoundException(
        "Profile", userId);
    
    return Json.emptyObject
      .set("profile", profile.get.toJson());
  }

  Json upsertConsent(UUID tenantId, string userId, Json data) {
    validateTenant(tenantId);
    if (userId.length == 0)
      throw new CDCValidationException("user_id is required");
    auto status = normalizeConsentStatus(
      requiredString(data, "status"));
    auto now = Clock.currTime();

    CDCConsent consent;
    consent.tenantId = tenantId;
    consent.userId = userId;
    consent.consentid = requiredUUID(data, "consent_id");
    consent.purpose = requiredString(data, "purpose");
    consent.legalBasis = optionalString(data, "legal_basis", "consent");
    consent.status = status;
    consent.source = optionalString(data, "source", "preference-center");
    consent.language = optionalString(data, "language", "en");
    consent.updatedAt = now;

    auto saved = _store.upsertConsent(consent);
    
    return Json.emptyObject
      .set("message", "Consent preference saved")
      .set("transparency_note", "Consent state is visible and auditable for the end user")
      .set("consent", saved.toJson());
  }

  Json listConsents(UUID tenantId, string userId) {
    validateTenant(tenantId);
    if (userId.length == 0)
      throw new CDCValidationException("user_id is required");

    Json consents = Json.emptyArray;
    foreach (consent; _store.listConsents(tenantId, userId))
      consents ~= consent.toJson();
    
    return Json.emptyObject
      .set("tenant_id", tenantId)
      .set("user_id", userId)
      .set("count", cast(long)consents.length)
      .set("consents", consents);
  }

  Json upsertSiteGroup(UUID tenantId, Json data) {
    validateTenant(tenantId);
    auto now = Clock.currTime();

    CDCSiteGroup group;
    group.tenantId = tenantId;
    group.groupid = requiredUUID(data, "group_id");
    group.name = requiredString(data, "name");
    group.sites = readStringArray(data, "sites");
    group.regions = readStringArray(data, "regions");
    if (group.regions.length == 0)
      group.regions = [
        _config.defaultRegion
      ];
    foreach (value; group.regions)
      validateRegion(value);
    group.createdAt = now;
    group.updatedAt = now;
    auto saved = _store.upsertSiteGroup(
      group);
    
    return Json.emptyObject
      .set("message", "Global access site group saved")
      .set("site_group", saved.toJson());
  }

  Json listSiteGroups(UUID tenantId) {
    validateTenant(tenantId);
    Json groups = Json.emptyArray;
    foreach (group; _store.listSiteGroups(tenantId))
      groups ~= group.toJson();
      
    return Json.emptyObject
      .set("tenant_id", tenantId)
      .set("count", cast(long)groups.length)
      .set("site_groups", groups);
  }

  Json resolveGlobalAccess(UUID tenantId, string userId, string site) {
    validateTenant(tenantId);
    if (userId.length == 0)
      throw new CDCValidationException("user_id is required");

    auto profile = _store.getProfileByTenantUser(tenantId, userId);
    if (profile.isNull)
      throw new CDCNotFoundException("Profile", userId);

    auto siteGroup = _store.getSiteGroup(tenantId, profile
        .get.siteGroupId);
    
    Json payload = Json.emptyObject
      .set("tenant_id", tenantId)
      .set("user_id", userId)
      .set("site", site)
      .set("data_region", profile.get.region)
      .set("site_group_id", profile.get.siteGroupId)
      .set("route", "regional-data-center");

    if (!siteGroup.isNull) {
      payload["site_group"] = siteGroup.get.toJson();
      payload["site_allowed"] = site
        .length == 0 || siteGroup.get.sites.canFind(site);
      payload["region_allowed"] = siteGroup.get.regions.canFind(
        profile.get.region);
    } else {
      payload["site_allowed"] = true;
      payload["region_allowed"] = true;
    }

    return payload;
  }

  Json upsertRiskProvider(UUID tenantId, Json data) {
    validateTenant(tenantId);
    auto now = Clock.currTime();

    CDCRiskProvider provider;
    provider.tenantId = tenantId;
    provider.providerid = requiredUUID(data, "provider_id");
    provider.name = requiredString(data, "name");
    provider.providerKind = normalizeProviderKind(requiredString(data, "provider_kind"));
    provider.enabled = optionalBoolean("enabled", true);
    provider.config = optionalObject(data, "config", Json.emptyObject);
    provider.createdAt = now;
    provider.updatedAt = now;
    auto saved = _store.upsertRiskProvider(
      provider);

    return Json.emptyObject
      .set("message", "Risk provider configured")
      .set("provider", saved.toJson());
  }

  Json listRiskProviders(UUID tenantId) {
    validateTenant(tenantId);
    Json providers = _store.listRiskProviders(tenantId)
      .map!(provider => provider.toJson()).array.toJson;

    return Json.emptyObject
      .set("tenant_id", tenantId)
      .set("count", cast(long)providers.length)
      .set("providers", providers);
  }

  Json authenticate(UUID tenantId, Json data) {
    validateTenant(tenantId);
    auto userid = requiredUUID(data, "user_id");
    auto password = requiredString(data, "password");
    auto ipAddress = optionalString(data, "ip_address", "");

    auto profileOpt = _store.getProfileByTenantUser(tenantId, userId);
    if (profileOpt.isNull)
      throw new CDCNotFoundException("Profile", userId);

    auto profile = profileOpt.get;
    auto now = Clock.currTime();

    if (profile.hasLockedUntil && now < profile.lockedUntil) {
      return deniedAuthPayload(tenantId, userId, ipAddress, "deny_locked", "high", 100, Json
          .emptyObject);
    }

    auto providerSignals = readObject(data, "provider_signals", Json
        .emptyObject);
    auto riskScore = evaluateRiskScore(profile, ipAddress, providerSignals);
    auto riskLevel = riskLevelForScore(riskScore);

    if (profile.passwordSecret != password) {
      profile.failedLoginAttempts += 1;
      profile.updatedAt = now;

      if (profile.failedLoginAttempts >= 5) {
        profile.hasLockedUntil = true;
        profile.lockedUntil = now + dur!"minutes"(
          30);
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
      _store.upsertProfile(
        profile);
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
    _store.upsertProfile(
      profile);
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

    return super.toJson
      .set("decision", "allow")
      .set("risk_level", riskLevel)
      .set("risk_score", riskScore)
      .set("session", Json.emptyObject)
      .set("session", "sess-" ~ userId ~ "-" ~ to!string(now.stdTime))
      .set("session", 3600)
      .set("profile", profile.toJson())
      .set("auth_event", event.toJson());
  }

  Json listAuthEvents(UUID tenantId, size_t limit) {
    validateTenant(tenantId);
    auto safeLimit = limit == 0 ? 100 : limit;
    Json events = Json.emptyArray;
    foreach (event; _store.listAuthEvents(tenantId, safeLimit))
      events ~= event.toJson();
    
    return Json.emptyObject
    .set("tenant_id", tenantId)
    .set("count", cast(long)events.length)
    .set("events", events);
  }

  private Json deniedAuthPayload(
    UUID tenantId,
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
      ? "Step-up authentication required" : "Authentication blocked by account protection";
    return payload;
  }

  private CDCAuthEvent appendAuthEvent(
    UUID tenantId,
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
    event.tenantId = UUID(
      tenantId);
    event.eventId = "evt-" ~ to!string(
      now.stdTime);
    event.userId = userId;
    event.providerId = providerId;
    event.ipAddress = ipAddress;
    event.decision = decision;
    event.riskLevel = riskLevel;
    event.riskScore = riskScore;
    event.providerSignals = signals;
    event.createdAt = now;
    return _store.appendAuthEvent(
      event);
  }

  private long evaluateRiskScore(CDCProfile profile, string ipAddress, Json providerSignals) {
    long score = 0;
    if (
      profile.failedLoginAttempts >= 3)
      score += 30;
    if (
      profile.hasLockedUntil)
      score += 40;

    if (ipAddress.length == 0)
      score += 5;

    if ("recaptcha_score" in providerSignals && providerSignals["recaptcha_score"]
      .isFloat) {
      if (providerSignals["recaptcha_score"]
        .get!double < 0.5)
        score += 40;
    }

    if ("akamai_risk" in providerSignals && providerSignals["akamai_risk"]
      .isBoolean) {
      if (
        providerSignals["akamai_risk"]
        .get!bool)
        score += 30;
    }

    if ("arkose_result" in providerSignals && providerSignals["arkose_result"]
      .isString) {
      if (toLower(
          providerSignals["arkose_result"].get!string) == "suspicious")
        score += 35;
    }

    if ("transunion_score" in providerSignals && providerSignals["transunion_score"]
      .isInteger) {
      if (
        providerSignals["transunion_score"].get!long > 700)
        score += 20;
    }

    if ("impossible_travel" in providerSignals && providerSignals["impossible_travel"]
      .isBoolean) {
      if (
        providerSignals["impossible_travel"]
        .get!bool)
        score += 25;
    }

    if (score > 100)
      score = 100;
    return score;
  }

  private string riskLevelForScore(
    long score) {
    if (score >= 70)
      return "high";
    if (score >= 30)
      return "medium";
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

  private void validateRegion(
    string value) const {
    if (value.length == 0)
      throw new CDCValidationException(
        "region is required");
  }

  private string normalizeConsentStatus(
    string value) const {
    auto normalized = toLower(value);
    if (normalized != "granted" && normalized != "withdrawn" && normalized != "pending") {
      throw new CDCValidationException("status must be one of granted|withdrawn|pending");
    }
    return normalized;
  }

  private string normalizeProviderKind(
    string value) const {
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

  private bool readrequestgetBoolean(Json data, string key, bool fallback) const {
    if (!(key in data) || data[key].isNull)
      return fallback;
    requiredBooleanType(data, key);
    return data[key].get!bool;
  }

  private string[] readStringArray(Json data, string key) const {
    string[] values;
    if (!(key in data) || data[key]
      .isNull)
      return values;
    requiredArrayType(data, key);
    foreach (item; data[key]) {
      if (!item.isString)
        throw new CDCValidationException(
          key ~ " must contain strings");
      values ~= item
        .get!string;
    }
    return values;
  }

  private Json readObject(Json data, string key, Json fallback) const {
    if (!(key in data) || data[key]
      .isNull) {
      return fallback;
    }

    requiredObjectType(data, key);
    return data[key];
  }
}
