module uim.sap.cdc.store;

import core.sync.mutex : Mutex;

import std.datetime : SysTime;
import std.file : exists, mkdirRecurse, readText, write;
import std.path : dirName;
import std.typecons : Nullable;

import vibe.data.json : Json, parseJsonString;

import uim.sap.cdc.exceptions;
import uim.sap.cdc.models;

class CDCStore : SAPStore {
  private CDCProfile[string] _profiles;
  private CDCConsent[string] _consents;
  private CDCSiteGroup[string] _siteGroups;
  private CDCRiskProvider[string] _riskProviders;
  private CDCAuthEvent[string] _authEvents;

  private string _cacheFilePath;
  private Mutex _lock;

  this(string cacheFilePath) {
    _cacheFilePath = cacheFilePath;
    _lock = new Mutex;
    loadSnapshot();
  }

  CDCProfile upsertProfile(CDCProfile profile) {
    synchronized (_lock) {
      auto key = scopedProfileKey(profile.tenantId, profile.region, profile.userId);
      if (auto existing = key in _profiles) {
        profile.createdAt = existing.createdAt;
      }
      _profiles[key] = profile;
      persistSnapshot();
      return profile;
    }
  }

  Nullable!CDCProfile getProfileByTenantRegionUser(string tenantId, string region, string userId) {
    synchronized (_lock) {
      auto key = scopedProfileKey(tenantId, region, userId);
      if (auto value = key in _profiles) return Nullable!CDCProfile(*value);
      return Nullable!CDCProfile.init;
    }
  }

  Nullable!CDCProfile getProfileByTenantUser(string tenantId, string userId) {
    synchronized (_lock) {
      auto prefix = tenantId ~ ":profile:";
      auto suffix = ":" ~ userId;
      foreach (key, value; _profiles) {
        if (key.length >= prefix.length + suffix.length && key[0 .. prefix.length] == prefix) {
          if (key[$ - suffix.length .. $] == suffix) return Nullable!CDCProfile(value);
        }
      }
      return Nullable!CDCProfile.init;
    }
  }

  CDCProfile[] listProfilesByTenant(string tenantId) {
    CDCProfile[] values;
    synchronized (_lock) {
      auto prefix = tenantId ~ ":profile:";
      foreach (key, value; _profiles) {
        if (key.length >= prefix.length && key[0 .. prefix.length] == prefix) values ~= value;
      }
    }
    return values;
  }

  CDCConsent upsertConsent(CDCConsent consent) {
    synchronized (_lock) {
      auto key = scopedConsentKey(consent.tenantId, consent.userId, consent.consentId);
      _consents[key] = consent;
      persistSnapshot();
      return consent;
    }
  }

  CDCConsent[] listConsents(string tenantId, string userId) {
    CDCConsent[] values;
    synchronized (_lock) {
      auto prefix = scopedConsentPrefix(tenantId, userId);
      foreach (key, value; _consents) {
        if (key.length >= prefix.length && key[0 .. prefix.length] == prefix) values ~= value;
      }
    }
    return values;
  }

  CDCSiteGroup upsertSiteGroup(CDCSiteGroup group) {
    synchronized (_lock) {
      auto key = scopedSiteGroupKey(group.tenantId, group.groupId);
      if (auto existing = key in _siteGroups) {
        group.createdAt = existing.createdAt;
      }
      _siteGroups[key] = group;
      persistSnapshot();
      return group;
    }
  }

  Nullable!CDCSiteGroup getSiteGroup(string tenantId, string groupId) {
    synchronized (_lock) {
      auto key = scopedSiteGroupKey(tenantId, groupId);
      if (auto value = key in _siteGroups) return Nullable!CDCSiteGroup(*value);
      return Nullable!CDCSiteGroup.init;
    }
  }

  CDCSiteGroup[] listSiteGroups(string tenantId) {
    CDCSiteGroup[] values;
    synchronized (_lock) {
      auto prefix = tenantId ~ ":site-group:";
      foreach (key, value; _siteGroups) {
        if (key.length >= prefix.length && key[0 .. prefix.length] == prefix) values ~= value;
      }
    }
    return values;
  }

  CDCRiskProvider upsertRiskProvider(CDCRiskProvider provider) {
    synchronized (_lock) {
      auto key = scopedRiskProviderKey(provider.tenantId, provider.providerId);
      if (auto existing = key in _riskProviders) {
        provider.createdAt = existing.createdAt;
      }
      _riskProviders[key] = provider;
      persistSnapshot();
      return provider;
    }
  }

  CDCRiskProvider[] listRiskProviders(string tenantId) {
    CDCRiskProvider[] values;
    synchronized (_lock) {
      auto prefix = tenantId ~ ":risk-provider:";
      foreach (key, value; _riskProviders) {
        if (key.length >= prefix.length && key[0 .. prefix.length] == prefix) values ~= value;
      }
    }
    return values;
  }

  CDCAuthEvent appendAuthEvent(CDCAuthEvent event) {
    synchronized (_lock) {
      auto key = scopedAuthEventKey(event.tenantId, event.eventId);
      _authEvents[key] = event;
      persistSnapshot();
      return event;
    }
  }

  CDCAuthEvent[] listAuthEvents(string tenantId, size_t limit) {
    CDCAuthEvent[] values;
    synchronized (_lock) {
      auto prefix = tenantId ~ ":auth-event:";
      foreach (key, value; _authEvents) {
        if (key.length >= prefix.length && key[0 .. prefix.length] == prefix) values ~= value;
      }
    }

    if (values.length <= limit) return values;
    return values[$ - limit .. $];
  }

  private void loadSnapshot() {
    if (!exists(_cacheFilePath)) return;

    try {
      auto raw = readText(_cacheFilePath);
      if (raw.length == 0) return;

      auto snapshot = parseJsonString(raw);
      if ("profiles" in snapshot && snapshot["profiles"].type == Json.Type.array) {
        foreach (item; snapshot["profiles"]) {
          auto value = parseProfile(item);
          _profiles[scopedProfileKey(value.tenantId, value.region, value.userId)] = value;
        }
      }

      if ("consents" in snapshot && snapshot["consents"].type == Json.Type.array) {
        foreach (item; snapshot["consents"]) {
          auto value = parseConsent(item);
          _consents[scopedConsentKey(value.tenantId, value.userId, value.consentId)] = value;
        }
      }

      if ("site_groups" in snapshot && snapshot["site_groups"].type == Json.Type.array) {
        foreach (item; snapshot["site_groups"]) {
          auto value = parseSiteGroup(item);
          _siteGroups[scopedSiteGroupKey(value.tenantId, value.groupId)] = value;
        }
      }

      if ("risk_providers" in snapshot && snapshot["risk_providers"].type == Json.Type.array) {
        foreach (item; snapshot["risk_providers"]) {
          auto value = parseRiskProvider(item);
          _riskProviders[scopedRiskProviderKey(value.tenantId, value.providerId)] = value;
        }
      }

      if ("auth_events" in snapshot && snapshot["auth_events"].type == Json.Type.array) {
        foreach (item; snapshot["auth_events"]) {
          auto value = parseAuthEvent(item);
          _authEvents[scopedAuthEventKey(value.tenantId, value.eventId)] = value;
        }
      }
    } catch (Exception e) {
      throw new CDCStoreException("Failed to read customer-data cache snapshot: " ~ e.msg);
    }
  }

  private void persistSnapshot() {
    try {
      auto parentDir = dirName(_cacheFilePath);
      if (!exists(parentDir)) mkdirRecurse(parentDir);

      Json snapshot = Json.emptyObject;

      Json profiles = Json.emptyArray;
      foreach (_key, value; _profiles) profiles ~= value.toJson();
      snapshot["profiles"] = profiles;

      Json consents = Json.emptyArray;
      foreach (_key, value; _consents) consents ~= value.toJson();
      snapshot["consents"] = consents;

      Json siteGroups = Json.emptyArray;
      foreach (_key, value; _siteGroups) siteGroups ~= value.toJson();
      snapshot["site_groups"] = siteGroups;

      Json riskProviders = Json.emptyArray;
      foreach (_key, value; _riskProviders) riskProviders ~= value.toJson();
      snapshot["risk_providers"] = riskProviders;

      Json authEvents = Json.emptyArray;
      foreach (_key, value; _authEvents) authEvents ~= value.toJson();
      snapshot["auth_events"] = authEvents;

      write(_cacheFilePath, snapshot.toString());
    } catch (Exception e) {
      throw new CDCStoreException("Failed to persist customer-data cache snapshot: " ~ e.msg);
    }
  }

  private CDCProfile parseProfile(Json item) {
    CDCProfile value;
    value.tenantId = readString(item, "tenant_id", true);
    value.userId = readString(item, "user_id", true);
    value.email = readString(item, "email", false, "");
    value.phone = readString(item, "phone", false, "");
    value.firstName = readString(item, "first_name", false, "");
    value.lastName = readString(item, "last_name", false, "");
    value.region = readString(item, "region", true);
    value.siteGroupId = readString(item, "site_group_id", false, "");
    value.passwordSecret = readString(item, "password_secret", false, "");
    value.active = readBool(item, "active", true);
    value.emailVerified = readBool(item, "email_verified", false);
    value.preferences = readObject(item, "preferences");
    value.customAttributes = readObject(item, "custom_attributes");
    value.failedLoginAttempts = cast(size_t)readLong(item, "failed_login_attempts", 0);
    if ("locked_until" in item && item["locked_until"].isString) {
      value.hasLockedUntil = true;
      value.lockedUntil = parseTime(item["locked_until"].get!string);
    }
    value.createdAt = readTime(item, "created_at");
    value.updatedAt = readTime(item, "updated_at");
    return value;
  }

  private CDCConsent parseConsent(Json item) {
    CDCConsent value;
    value.tenantId = readString(item, "tenant_id", true);
    value.userId = readString(item, "user_id", true);
    value.consentId = readString(item, "consent_id", true);
    value.purpose = readString(item, "purpose", true);
    value.legalBasis = readString(item, "legal_basis", true);
    value.status = readString(item, "status", true);
    value.source = readString(item, "source", false, "portal");
    value.language = readString(item, "language", false, "en");
    value.updatedAt = readTime(item, "updated_at");
    return value;
  }

  private CDCSiteGroup parseSiteGroup(Json item) {
    CDCSiteGroup value;
    value.tenantId = readString(item, "tenant_id", true);
    value.groupId = readString(item, "group_id", true);
    value.name = readString(item, "name", true);
    value.sites = readStringArray(item, "sites");
    value.regions = readStringArray(item, "regions");
    value.createdAt = readTime(item, "created_at");
    value.updatedAt = readTime(item, "updated_at");
    return value;
  }

  private CDCRiskProvider parseRiskProvider(Json item) {
    CDCRiskProvider value;
    value.tenantId = readString(item, "tenant_id", true);
    value.providerId = readString(item, "provider_id", true);
    value.name = readString(item, "name", true);
    value.providerKind = readString(item, "provider_kind", true);
    value.enabled = readBool(item, "enabled", true);
    value.config = readObject(item, "config");
    value.createdAt = readTime(item, "created_at");
    value.updatedAt = readTime(item, "updated_at");
    return value;
  }

  private CDCAuthEvent parseAuthEvent(Json item) {
    CDCAuthEvent value;
    value.tenantId = readString(item, "tenant_id", true);
    value.eventId = readString(item, "event_id", true);
    value.userId = readString(item, "user_id", true);
    value.providerId = readString(item, "provider_id", false, "");
    value.ipAddress = readString(item, "ip_address", false, "");
    value.decision = readString(item, "decision", false, "allow");
    value.riskLevel = readString(item, "risk_level", false, "low");
    value.riskScore = readLong(item, "risk_score", 0);
    value.providerSignals = readObject(item, "provider_signals");
    value.createdAt = readTime(item, "created_at");
    return value;
  }

  private string readString(Json item, string key, bool required, string fallback = "") {
    if (!(key in item) || item[key].type == Json.Type.null_) {
      if (required) throw new CDCStoreException(key ~ " is required in cache item");
      return fallback;
    }
    if (item[key].type != Json.Type.string) {
      throw new CDCStoreException(key ~ " must be a string in cache item");
    }
    auto value = item[key].get!string;
    if (required && value.length == 0) {
      throw new CDCStoreException(key ~ " cannot be empty in cache item");
    }
    return value.length > 0 ? value : fallback;
  }

  private bool readBool(Json item, string key, bool fallback) {
    if (!(key in item) || item[key].type == Json.Type.null_) return fallback;
    if (item[key].type != Json.Type.bool_) {
      throw new CDCStoreException(key ~ " must be boolean in cache item");
    }
    return item[key].get!bool;
  }

  private long readLong(Json item, string key, long fallback) {
    if (!(key in item) || item[key].type == Json.Type.null_) return fallback;
    if (item[key].type != Json.Type.int_) {
      throw new CDCStoreException(key ~ " must be integer in cache item");
    }
    return item[key].get!long;
  }

  private string[] readStringArray(Json item, string key) {
    string[] values;
    if (!(key in item) || item[key].isNull) return values;
    if (!item[key].isArray) {
      throw new CDCStoreException(key ~ " must be an array in cache item");
    }
    foreach (entry; item[key]) {
      if (entry.isString) values ~= entry.get!string;
    }
    return values;
  }

  private Json readObject(Json item, string key) {
    if (!(key in item) || item[key].isNull) return Json.emptyObject;
    if (!item[key].isObject) {
      throw new CDCStoreException(key ~ " must be an object in cache item");
    }
    return item[key];
  }

  private SysTime parseTime(string value) {
    try {
      return SysTime.fromISOExtString(value);
    } catch (Exception) {
      return SysTime.fromISOExtString("1970-01-01T00:00:00Z");
    }
  }

  private SysTime readTime(Json item, string key) {
    if (!(key in item) || !item[key].isString) {
      return SysTime.fromISOExtString("1970-01-01T00:00:00Z");
    }
    return parseTime(item[key].get!string);
  }

  private string scopedProfileKey(string tenantId, string region, string userId) {
    return tenantId ~ ":profile:" ~ region ~ ":" ~ userId;
  }

  private string scopedConsentPrefix(string tenantId, string userId) {
    return tenantId ~ ":consent:" ~ userId ~ ":";
  }

  private string scopedConsentKey(string tenantId, string userId, string consentId) {
    return scopedConsentPrefix(tenantId, userId) ~ consentId;
  }

  private string scopedSiteGroupKey(string tenantId, string groupId) {
    return tenantId ~ ":site-group:" ~ groupId;
  }

  private string scopedRiskProviderKey(string tenantId, string providerId) {
    return tenantId ~ ":risk-provider:" ~ providerId;
  }

  private string scopedAuthEventKey(string tenantId, string eventId) {
    return tenantId ~ ":auth-event:" ~ eventId;
  }
}
