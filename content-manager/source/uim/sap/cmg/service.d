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

  Json upsertManualContent(string tenantId, string contentType, Json data) {
    validateTenant(tenantId);
    auto normalizedType = normalizeContentType(contentType);

    auto itemid = requiredUUID(body, "item_id");
    auto now = Clock.currTime();

    CMGContentItem item = new CMGContentItem(item);
    item.tenantId = UUID(tenantId);
    item.itemId = itemId;
    item.contentType = normalizedType;
    item.title = requiredString(body, "title");
    item.description = optionalString(body, "description", "");
    item.source = "manual";
    item.sourceRef = optionalString(body, "source_ref", "content-editor");
    item.tags = readStringArray(body, "tags");
    item.config = readObject(body, "config");
    item.createdAt = now;
    item.updatedAt = now;

    auto saved = _store.upsertItem(item);

    return Json.emptyObject
      .set("message", "Content item saved from manual editor")
      .set("item", saved.toJson());
  }

  Json listProviders(string tenantId) {
    validateTenant(tenantId);

    Json providers = _store.listProviders(tenantId).map!(provider => provider.toJson()).array.toJson(); 

    return Json.emptyObject
      .set("tenant_id", tenantId)
      .set("providers", providers)
      .set("count", cast(long)providers.length);
  }

  Json upsertProvider(string tenantId, Json data) {
    validateTenant(tenantId);

    auto now = Clock.currTime();
    CMGContentProvider provider;
    provider.tenantId = UUID(tenantId);
    provider.providerid = requiredUUID(body, "provider_id");
    provider.name = requiredString(body, "name");
    provider.providerType = optionalString(body, "provider_type", "remote-content");
    provider.endpoint = optionalString(body, "endpoint", "");
    provider.exposedTypes = normalizeContentTypes(readStringArray(body, "exposed_types"));
    provider.active = optionalBoolean(data, "active", true);
    provider.createdAt = now;
    provider.updatedAt = now;
    auto saved = _store.upsertProvider(provider);
    
    return Json.emptyObject
      .set("message", "Content provider registered")
      .set("provider", saved.toJson());
  }

  Json integrateProviderContent(string tenantId, string providerId, Json data) {
    validateTenant(tenantId);
    if (providerId.length == 0)
      throw new CMGValidationException("provider_id is required");
    auto provider = _store.getProvider(tenantId, providerId);
    if (provider.isNull)
      throw new CMGNotFoundException("Content provider not found");
    if (!provider.get.active)
      throw new CMGValidationException(
        "Content provider is inactive");
    auto requestedTypes = normalizeContentTypes(
      readStringArray(body, "content_types"));
    auto typesToIntegrate = requestedTypes.length > 0 ? requestedTypes : provider
      .get.exposedTypes;
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
      item.tenantId = UUID(tenantId);
      item.itemId = providerId ~ "-" ~ normalizedType;
      item.contentType = normalizedType;
      item.title = provider.get.name ~ " " ~ normalizedType ~ " item";
      item.description = "Integrated from provider " ~ providerId;
      item.source = "provider";
      item.sourceRef = providerId;
      item.tags = [
        "imported", "provider:" ~ providerId
      ];
      item.config = Json.emptyObject;
      item.config["provider_id"] = providerId;
      item.config["provider_type"] = provider.get.providerType;
      item.config["integration_mode"] = "provider-sync";
      item.createdAt = now;
      item.updatedAt = now;
      auto saved = _store.upsertItem(
        item);
      imported ~= saved.toJson();
    }

    return Json.emptyObject
      .set("message", "Provider content integrated into subaccount")
      .set("tenant_id", tenantId)
      .set("provider_id", providerId)
      .set("imported_items", imported)
      .set("count", cast(long)imported.length);
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
    return values.map!(value => normalizeContentType(value)).array;
  }
}
