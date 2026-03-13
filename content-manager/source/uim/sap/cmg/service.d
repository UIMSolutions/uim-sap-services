/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.cmg.service;

import uim.sap.cmg;

mixin(ShowModule!());

@safe:

class CMGService : SAPService {
  mixin(SAPServiceTemplate!CMGService);

  private CMGStore _store;

  this(CMGConfig config) {
    super(config);

    _store = new CMGStore;
  }

  override Json health() {
    Json healthInfo = super.health();
    healthInfo["domain"] = "content-manager";
    return healthInfo;
  }

  Json listContent(string tenantId, string contentType) {
    validateTenant(tenantId);
    auto normalizedType = normalizeContentType(contentType);

    Json items = _store.listItems(tenantId, normalizedType)
      .map!(item => item.toJson()).array.toJson();

    Json payload = Json.emptyObject;
    payload["tenant_id"] = tenantId;
    payload["content_type"] = normalizedType;
    payload["items"] = items;
    payload["count"] = cast(long)items.length;
    return payload;
  }

  Json upsertManualContent(string tenantId, string contentType, Json body) {
    validateTenant(tenantId);
    auto normalizedType = normalizeContentType(contentType);

    auto itemId = readRequired(body, "item_id");
    auto now = Clock.currTime();

    CMGContentItem item;
    item.tenantId = tenantId;
    item.itemId = itemId;
    item.contentType = normalizedType;
    item.title = readRequired(body, "title");
    item.description = readOptional(body, "description", "");
    item.source = "manual";
    item.sourceRef = readOptional(body, "source_ref", "content-editor");
    item.tags = readStringArray(body, "tags");
    item.config = readObject(body, "config");
    item.createdAt = now;
    item.updatedAt = now;

    auto saved = _store.upsertItem(item);

    Json payload = Json.emptyObject;
    payload["message"] = "Content item saved from manual editor";
    payload["item"] = saved.toJson();
    return payload;
  }

  Json listProviders(string tenantId) {
    validateTenant(tenantId);

    Json providers = _store.listProviders(tenantId)
      .map!(provider => provider.toJson()).array.toJson();

    Json payload = Json.emptyObject;
    payload["tenant_id"] = tenantId;
    payload["providers"] = providers;
    payload["count"] = cast(long)providers.length;
    return payload;
  }

  Json upsertProvider(string tenantId, Json body) {
    validateTenant(tenantId);

    auto now = Clock.currTime();
    CMGContentProvider provider;
    provider.tenantId = tenantId;
    provider.providerId = readRequired(body, "provider_id");
    provider.name = readRequired(body, "name");
    provider.providerType = readOptional(body, "provider_type", "remote-content");
    provider.endpoint = readOptional(body, "endpoint", "");
    provider.exposedTypes = normalizeContentTypes(readStringArray(body, "exposed_types"));
    provider.active = readOptionalBool(body, "active", true);
    provider.createdAt = now;
    provider.updatedAt = now;

    auto saved = _store.upsertProvider(provider);

    Json payload = Json.emptyObject;
    payload["message"] = "Content provider registered";
    payload["provider"] = saved.toJson();
    return payload;
  }

  Json integrateProviderContent(string tenantId, string providerId, Json body) {
    validateTenant(tenantId);
    if (providerId.length == 0)
      throw new CMGValidationException("provider_id is required");

    auto provider = _store.getProvider(tenantId, providerId);
    if (provider.isNull)
      throw new CMGNotFoundException("Content provider not found");
    if (!provider.get.active)
      throw new CMGValidationException("Content provider is inactive");

    auto requestedTypes = normalizeContentTypes(readStringArray(body, "content_types"));
    auto typesToIntegrate = requestedTypes.length > 0 ? requestedTypes : provider.get.exposedTypes;
    if (typesToIntegrate.length == 0) {
      typesToIntegrate = [
        "apps", "catalogs", "groups", "roles", "shell-plugins"
      ];
    }

    Json imported = Json.emptyArray;
    auto now = Clock.currTime();

    foreach (contentType; typesToIntegrate) {
      auto normalizedType = normalizeContentType(contentType);

      CMGContentItem item;
      item.tenantId = tenantId;
      item.itemId = providerId ~ "-" ~ normalizedType;
      item.contentType = normalizedType;
      item.title = provider.get.name ~ " " ~ normalizedType ~ " item";
      item.description = "Integrated from provider " ~ providerId;
      item.source = "provider";
      item.sourceRef = providerId;
      item.tags = ["imported", "provider:" ~ providerId];
      item.config = Json.emptyObject;
      item.config["provider_id"] = providerId;
      item.config["provider_type"] = provider.get.providerType;
      item.config["integration_mode"] = "provider-sync";
      item.createdAt = now;
      item.updatedAt = now;

      auto saved = _store.upsertItem(item);
      imported ~= saved.toJson();
    }

    Json payload = Json.emptyObject;
    payload["message"] = "Provider content integrated into subaccount";
    payload["tenant_id"] = tenantId;
    payload["provider_id"] = providerId;
    payload["imported_items"] = imported;
    payload["count"] = cast(long)imported.length;
    return payload;
  }

  private void validateTenant(string tenantId) const {
    if (tenantId.length == 0)
      throw new CMGValidationException("tenant_id is required");
  }

  private string normalizeContentType(string value) const {
    auto normalized = toLower(value);
    if (normalized == "shell_plugins")
      normalized = "shell-plugins";
    if (normalized != "apps" && normalized != "catalogs" && normalized != "groups" && normalized != "roles" && normalized != "shell-plugins") {
      throw new CMGValidationException(
        "content type must be one of apps|catalogs|groups|roles|shell-plugins");
    }
    return normalized;
  }

  private string[] normalizeContentTypes(string[] values) const {
    string[] normalized;
    foreach (value; values)
      normalized ~= normalizeContentType(value);
    return normalized;
  }

  private string readRequired(Json data, string key) const {
    if (!(key in data) || !data[key].isString || data[key].get!string.length == 0) {
      throw new CMGValidationException(key ~ " is required");
    }
    return     data[key].get!string;
  }

  private string readOptional(Json data, string key, string fallback) const {
    if (!(key in data) || data[key].isNull)
      return fallback;
    if (!data[key].isString)
      throw new CMGValidationException(key ~ " must be a string");
    return     data[key].get!string;
  }

  private bool readOptionalBool(Json data, string key, bool fallback) const {
    if (!(key in data) || data[key].isNull)
      return fallback;
    if (!data[key].isBoolean)
      throw new CMGValidationException(key ~ " must be a boolean");
      
    return data[key].get!bool;
  }

  private string[] readStringArray(Json data, string key) const {
    string[] values;
    if (!(key in data) || data[key].isNull)
      return values;

    if (!data[key].isArray)
      throw new CMGValidationException(key ~ " must be an array");

    foreach (item; data[key].toArray) {
      if (!item.isString)
        throw new CMGValidationException(key ~ " must contain strings");

      values ~= item.get!string;
    }
    return values;
  }

  private Json readObject(Json data, string key) const {
    if (!(key in data) || data[key].isNull) {
      return Json.emptyObject;
    }

    if (!data[key].isObject) {
      throw new CMGValidationException(key ~ " must be an object");
    }

    return data[key];
  }
}
