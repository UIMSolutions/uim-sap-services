/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.html5repo.service;

import vibe.data.json : Json;

import uim.sap.html5repo.cache;
import uim.sap.html5repo.config;
import uim.sap.html5repo.exceptions;
import uim.sap.html5repo.models;
import uim.sap.html5repo.store;

class HTMRepoService : SAPService {
    private HTMRepoConfig _config;
    private HTMRepositoryStore _store;
    private RuntimeAssetCache _cache;

    this(HTMRepoConfig config) {
        config.validate();
        _config = config;
        _store = new HTMRepositoryStore(_config.dataDirectory);
        _cache = new RuntimeAssetCache(_config.cacheTtlSeconds);
    }

    @property const(HTMRepoConfig) config() const {
        return _config;
    }

    override Json health() {
        Json healthInfo = super.health();
        healthInfo["ok"] = true;
        healthInfo["service_name"] = _config.serviceName;
        healthInfo["service_version"] = _config.serviceVersion;
        healthInfo["cache_entries"] = cast(long)_cache.size();
        return healthInfo;
    }

    Json uploadVersion(TenantContext tenant, string appId, string versionId, Json request) {
        auto visibility = visibilityFromString(getString(request, "visibility", "private"));
        auto activate = getBool(request, "activate", true);

        if (!("files" in request) || !request["files"].isArray) {
            throw new HTMRepoValidationException("files array is required");
        }

        UploadedAsset[] files;
        foreach (item; request["files"]) {
            if (!item.isObject) {
                throw new HTMRepoValidationException("files entries must be objects");
            }

            UploadedAsset file;
            file.path = getString(item, "path", "");
            file.contentBase64 = getString(item, "content_base64", "");
            file.contentType = getString(item, "content_type", "");
            files ~= file;
        }

        _store.uploadVersion(tenant, appId, versionId, visibility, files, _config.maxUploadBytes, activate);
        invalidateAppCache(tenant.tenantId, tenant.spaceId, appId);

        auto info = _store.tryGetVersionInfo(tenant.tenantId, tenant.spaceId, appId, versionId);
        Json payload = Json.emptyObject;
        payload["uploaded"] = true;
        payload["version"] = info.toJson();
        payload["zero_downtime"] = "Application router stays untouched, only static content version pointer changes.";
        return payload;
    }

    Json activateVersion(TenantContext tenant, string appId, string versionId) {
        _store.setActiveVersion(tenant.tenantId, tenant.spaceId, appId, versionId);
        invalidateAppCache(tenant.tenantId, tenant.spaceId, appId);

        Json payload = Json.emptyObject;
        payload["activated"] = true;
        payload["app_id"] = appId;
        payload["version"] = versionId;
        return payload;
    }

    Json listVersions(TenantContext tenant, string appId) {
        auto versions = _store.listVersions(tenant.tenantId, tenant.spaceId, appId);
        Json list = Json.emptyArray;
        foreach (item; versions) {
            list ~= item.toJson();
        }

        Json payload = Json.emptyObject;
        payload["tenant_id"] = tenant.tenantId;
        payload["space_id"] = tenant.spaceId;
        payload["app_id"] = appId;
        payload["versions"] = list;
        payload["active_version"] = _store.activeVersion(tenant.tenantId, tenant.spaceId, appId);
        return payload;
    }

    Json listFiles(TenantContext tenant, string appId, string versionId) {
        auto files = _store.listFiles(tenant.tenantId, tenant.spaceId, appId, versionId);
        Json list = Json.emptyArray;
        foreach (path; files) {
            list ~= path;
        }

        Json payload = Json.emptyObject;
        payload["tenant_id"] = tenant.tenantId;
        payload["space_id"] = tenant.spaceId;
        payload["app_id"] = appId;
        payload["version"] = versionId;
        payload["files"] = list;
        payload["total_files"] = cast(long)files.length;
        return payload;
    }

    Json listApplications(TenantContext tenant) {
        auto apps = _store.listApplications(tenant.tenantId, tenant.spaceId, _config.allowPublicCrossSpace);
        Json list = Json.emptyArray;
        foreach (item; apps) {
            list ~= item;
        }

        Json payload = Json.emptyObject;
        payload["tenant_id"] = tenant.tenantId;
        payload["space_id"] = tenant.spaceId;
        payload["applications"] = list;
        payload["total_results"] = cast(long)apps.length;
        payload["cross_space_public_enabled"] = _config.allowPublicCrossSpace;
        return payload;
    }

    Json deleteVersion(TenantContext tenant, string appId, string versionId) {
        _store.deleteVersion(tenant.tenantId, tenant.spaceId, appId, versionId);
        invalidateAppCache(tenant.tenantId, tenant.spaceId, appId);

        Json payload = Json.emptyObject;
        payload["deleted"] = true;
        payload["app_id"] = appId;
        payload["version"] = versionId;
        return payload;
    }

    RuntimeAsset runtimeAssetByActiveVersion(
        string tenantId,
        string spaceId,
        string appId,
        string assetPath,
        string consumerTenantId,
        string consumerSpaceId
    ) {
        auto activeVersion = _store.activeVersion(tenantId, spaceId, appId);
        if (activeVersion.length == 0) {
            throw new HTMRepoNotFoundException("Active version", appId);
        }
        return runtimeAssetByVersion(
            tenantId,
            spaceId,
            appId,
            activeVersion,
            assetPath,
            consumerTenantId,
            consumerSpaceId
        );
    }

    RuntimeAsset runtimeAssetByVersion(
        string tenantId,
        string spaceId,
        string appId,
        string versionId,
        string assetPath,
        string consumerTenantId,
        string consumerSpaceId
    ) {
        auto key = tenantId ~ "|" ~ spaceId ~ "|" ~ appId ~ "|" ~ versionId ~ "|" ~
            assetPath ~ "|" ~ consumerTenantId ~ "|" ~ consumerSpaceId;
        RuntimeAsset cached;
        if (_cache.tryGet(key, cached)) {
            return cached;
        }

        auto loaded = _store.loadAsset(
            tenantId,
            spaceId,
            appId,
            versionId,
            assetPath,
            consumerTenantId,
            consumerSpaceId,
            _config.allowPublicCrossSpace
        );
        _cache.put(key, loaded);
        return loaded;
    }

    Json activeVersion(TenantContext tenant, string appId) {
        auto activeVersionId = _store.activeVersion(tenant.tenantId, tenant.spaceId, appId);
        if (activeVersionId.length == 0) {
            throw new HTMRepoNotFoundException("Active version", appId);
        }

        auto info = _store.tryGetVersionInfo(tenant.tenantId, tenant.spaceId, appId, activeVersionId);
        Json payload = Json.emptyObject;
        payload["tenant_id"] = tenant.tenantId;
        payload["space_id"] = tenant.spaceId;
        payload["app_id"] = appId;
        payload["active_version"] = activeVersionId;
        payload["visibility"] = visibilityToString(info.visibility);
        return payload;
    }

    private string getString(Json payload, string key, string fallback) {
        if (key in payload && payload[key].isString) {
            return payload[key].get!string;
        }
        return fallback;
    }

    private bool getBool(Json payload, string key, bool fallback) {
        if (key in payload && payload[key].isBoolean) {
            return payload[key].get!bool;
        }
        return fallback;
    }

    private void invalidateAppCache(string tenantId, string spaceId, string appId) {
        auto prefix = tenantId ~ "|" ~ spaceId ~ "|" ~ appId ~ "|";
        _cache.invalidateByPrefix(prefix);
    }
}
