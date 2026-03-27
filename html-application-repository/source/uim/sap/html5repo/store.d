/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.har.store;

import uim.sap.har;

class HARsitoryStore : SAPStore {
  private string _root;

  this(string rootPath) {
    _root = rootPath;
    mkdirRecurse(_root);
  }

  void uploadVersion(
    TenantContext tenant,
    string appId,
    string versionId,
    Visibility visibility,
    UploadedAsset[] files,
    long maxUploadBytes,
    bool activateNow
  ) {
    validateIdentity(tenant.tenantId, "tenant_id");
    validateIdentity(tenant.spaceId, "space_id");
    validateIdentity(appId, "app_id");
    validateIdentity(versionId, "version");

    if (files.length == 0) {
      throw new HARValidationException("At least one file is required");
    }

    auto versionRoot = versionDirectory(tenant.tenantId, tenant.spaceId, appId, versionId);
    auto contentRoot = buildPath(versionRoot, "content");
    mkdirRecurse(contentRoot);

    long totalBytes = 0;
    long fileCount = 0;

    foreach (asset; files) {
      auto cleanPath = normalizeAssetPath(asset.path);
      if (asset.contentBase64.length == 0) {
        throw new HARValidationException("content_base64 is required for " ~ cleanPath);
      }

      ubyte[] binaryContent;
      try {
        binaryContent = Base64.decode(asset.contentBase64);
      } catch (Exception) {
        throw new HARValidationException("Invalid content_base64 for " ~ cleanPath);
      }

      totalBytes += cast(long)binaryContent.length;
      if (totalBytes > maxUploadBytes) {
        throw new HARValidationException("Upload exceeds max upload size limit");
      }

      auto target = buildPath(contentRoot, cleanPath);
      mkdirRecurse(dirName(target));
      write(target, binaryContent);
      fileCount++;
    }

    auto now = Clock.currTime().toISOExtString();
    auto previous = tryGetVersionInfo(tenant.tenantId, tenant.spaceId, appId, versionId);

    AppVersionInfo info = new AppVersionInfo;
    info.tenantId = tenant.tenantId;
    info.spaceId = tenant.spaceId;
    info.appId = appId;
    info.versionId = versionId;
    info.visibility = visibility;
    info.createdAt = previous.versionId.length > 0 ? previous.createdAt : now;
    info.updatedAt = now;
    info.sizeBytes = totalBytes;
    info.fileCount = fileCount;
    info.active = false;

    writeVersionMetadata(info);

    if (activateNow) {
      setActiveVersion(tenant.tenantId, tenant.spaceId, appId, versionId);
    }
  }

  void setActiveVersion(UUID tenantId, string spaceId, string appId, string versionId) {
    auto requested = tryGetVersionInfo(tenantId, spaceId, appId, versionId);
    if (requested.versionId.length == 0) {
      throw new HARNotFoundException("Version", appId ~ ":" ~ versionId);
    }

    auto versions = listVersions(tenantId, spaceId, appId);
    foreach (item; versions) {
      auto current = item;
      current.active = current.versionId == versionId;
      current.updatedAt = Clock.currTime();
      writeVersionMetadata(current);
    }

    auto appRoot = appDirectory(tenantId, spaceId, appId);
    mkdirRecurse(appRoot);

    auto activeFile = buildPath(appRoot, "active-version.txt");
    auto tempFile = buildPath(appRoot, "active-version.tmp");
    write(tempFile, versionId);

    if (exists(activeFile)) {
      remove(activeFile);
    }
    rename(tempFile, activeFile);
  }

  AppVersionInfo[] listVersions(UUID tenantId, string spaceId, string appId) {
    AppVersionInfo[] results;
    auto versionsRoot = buildPath(appDirectory(tenantId, spaceId, appId), "versions");
    if (!exists(versionsRoot) || !isDir(versionsRoot)) {
      return results;
    }

    foreach (entry; dirEntries(versionsRoot, SpanMode.shallow)) {
      if (!entry.isDir) {
        continue;
      }

      auto metadataFile = buildPath(entry.name, "metadata.json");
      if (!exists(metadataFile)) {
        continue;
      }

      try {
        auto payload = parseJsonString(readText(metadataFile));
        auto info = AppVersionInfo.fromJson(payload);
        info.active = activeVersion(tenantId, spaceId, appId) == info.versionId;
        results ~= info;
      } catch (Exception) {
      }
    }

    return results;
  }

  Json[] listApplications(UUID tenantId, string spaceId, bool includePublicFromOtherSpaces) {
    Json[] result;
    auto spacesRoot = buildPath(tenantDirectory(tenantId), "spaces");
    if (!exists(spacesRoot)) {
      return result;
    }

    foreach (spaceEntry; dirEntries(spacesRoot, SpanMode.shallow)) {
      if (!spaceEntry.isDir) {
        continue;
      }

      auto currentSpace = baseName(spaceEntry.name);
      auto appsRoot = buildPath(spaceEntry.name, "apps");
      if (!exists(appsRoot)) {
        continue;
      }

      foreach (appEntry; dirEntries(appsRoot, SpanMode.shallow)) {
        if (!appEntry.isDir) {
          continue;
        }

        auto appId = baseName(appEntry.name);
        auto versions = listVersions(tenantId, currentSpace, appId);
        if (versions.length == 0) {
          continue;
        }

        auto active = activeVersion(tenantId, currentSpace, appId);
        if (active.length == 0) {
          active = versions[0].versionId;
        }

        auto activeInfo = tryGetVersionInfo(tenantId, currentSpace, appId, active);
        auto isOwnSpace = currentSpace == spaceId;
        auto isPublic = activeInfo.visibility == Visibility.publicAccess;
        if (!isOwnSpace && !(includePublicFromOtherSpaces && isPublic)) {
          continue;
        }

        result ~= Json.emptyObject
        .set("tenant_id", tenantId)
        .set("space_id", currentSpace)
        .set("app_id", appId)
        .set("active_version", active)
        .set("active_visibility", visibilityToString(activeInfo.visibility))
        .set("version_count", cast(long)versions.length);
      }
    }

    return result;
  }

  AppVersionInfo tryGetVersionInfo(UUID tenantId, string spaceId, string appId, string versionId) {
    auto metadataFile = buildPath(versionDirectory(tenantId, spaceId, appId, versionId), "metadata.json");
    if (!exists(metadataFile)) {
      return null;
    }

    try {
      auto payload = parseJsonString(readText(metadataFile));
      auto info = AppVersionInfo.fromJson(payload);
      info.active = activeVersion(tenantId, spaceId, appId) == info.versionId;
      return info;
    } catch (Exception) {
      return null;
    }
  }

  string activeVersion(UUID tenantId, string spaceId, string appId) {
    auto activeFile = buildPath(appDirectory(tenantId, spaceId, appId), "active-version.txt");
    if (!exists(activeFile)) {
      return "";
    }
    return strip(readText(activeFile));
  }

  string[] listFiles(UUID tenantId, string spaceId, string appId, string versionId) {
    string[] files;
    auto contentRoot = buildPath(versionDirectory(tenantId, spaceId, appId, versionId), "content");
    if (!exists(contentRoot)) {
      throw new HARNotFoundException("Version", appId ~ ":" ~ versionId);
    }

    foreach (entry; dirEntries(contentRoot, SpanMode.depth)) {
      if (entry.isDir) {
        continue;
      }

      auto normalizedRoot = contentRoot ~ "/";
      auto raw = entry.name;
      if (raw.canFind(normalizedRoot)) {
        auto relative = raw[normalizedRoot.length .. $];
        files ~= relative;
      }
    }

    return files;
  }

  RuntimeAsset loadAsset(
    UUID tenantId,
    string spaceId,
    string appId,
    string versionId,
    string assetPath,
    string consumerTenantId,
    string consumerSpaceId,
    bool allowPublicCrossSpace
  ) {
    auto info = tryGetVersionInfo(tenantId, spaceId, appId, versionId);
    if (info.versionId.length == 0) {
      throw new HARNotFoundException("Version", appId ~ ":" ~ versionId);
    }

    if (consumerTenantId.length > 0 && consumerTenantId != tenantId) {
      throw new HARAuthorizationException("Cross-tenant consumption is not allowed");
    }

    auto privateAsset = info.visibility == Visibility.privateAccess;
    auto crossSpace = consumerSpaceId.length > 0 && consumerSpaceId != spaceId;

    if (privateAsset && crossSpace) {
      throw new HARAuthorizationException(
        "Private application cannot be consumed from another space");
    }

    if (!privateAsset && crossSpace && !allowPublicCrossSpace) {
      throw new HARAuthorizationException("Cross-space public sharing is disabled");
    }

    auto cleanPath = normalizeAssetPath(assetPath);
    auto assetFile = buildPath(versionDirectory(tenantId, spaceId, appId, versionId), "content", cleanPath);
    if (!exists(assetFile)) {
      throw new HARNotFoundException("Asset", cleanPath);
    }

    RuntimeAsset asset = new RuntimeAsset;
    asset.tenantId = tenantId;
    asset.spaceId = spaceId;
    asset.appId = appId;
    asset.versionId = versionId;
    asset.path = cleanPath;
    asset.isPublic = !privateAsset;
    asset.content = cast(ubyte[])read(assetFile);
    asset.contentType = mimeTypeFor(cleanPath);
    asset.etag = toEtag(info, cleanPath);
    return asset;
  }

  void deleteVersion(UUID tenantId, string spaceId, string appId, string versionId) {
    auto root = versionDirectory(tenantId, spaceId, appId, versionId);
    if (!exists(root)) {
      throw new HARNotFoundException("Version", appId ~ ":" ~ versionId);
    }
    rmdirRecurse(root);

    auto active = activeVersion(tenantId, spaceId, appId);
    if (active == versionId) {
      auto activeFile = buildPath(appDirectory(tenantId, spaceId, appId), "active-version.txt");
      if (exists(activeFile)) {
        remove(activeFile);
      }
    }
  }

  private void writeVersionMetadata(AppVersionInfo info) {
    auto root = versionDirectory(info.tenantId, info.spaceId, info.appId, info.versionId);
    mkdirRecurse(root);
    auto file = buildPath(root, "metadata.json");
    write(file, info.toJson().toString());
  }

  private string toEtag(AppVersionInfo info, string path) {
    return info.appId ~ "-" ~ info.versionId ~ "-" ~ to!string(info.sizeBytes) ~ "-" ~ path;
  }

  private string normalizeAssetPath(string pathValue) {
    auto value = strip(pathValue);
    if (value.length == 0) {
      throw new HARValidationException("asset path is required");
    }

    if (value[0] == '/') {
      value = value[1 .. $];
    }

    auto segments = split(value, "/");
    string[] clean;
    foreach (segment; segments) {
      if (segment.length == 0 || segment == "." || segment == "..") {
        throw new HARValidationException("Invalid asset path");
      }
      clean ~= segment;
    }

    return clean.join("/");
  }

  private string mimeTypeFor(string assetPath) {
    auto ext = toLower(extension(assetPath));
    switch (ext) {
    case ".html":
      return "text/html; charset=utf-8";
    case ".css":
      return "text/css; charset=utf-8";
    case ".js":
      return "application/javascript; charset=utf-8";
    case ".json":
      return "application/json; charset=utf-8";
    case ".svg":
      return "image/svg+xml";
    case ".png":
      return "image/png";
    case ".jpg":
    case ".jpeg":
      return "image/jpeg";
    case ".gif":
      return "image/gif";
    case ".ico":
      return "image/x-icon";
    case ".txt":
      return "text/plain; charset=utf-8";
    default:
      return "application/octet-stream";
    }
  }

  private string appDirectory(UUID tenantId, string spaceId, string appId) {
    return buildPath(spaceDirectory(tenantId, spaceId), "apps", safeIdentity(appId));
  }

  private string versionDirectory(UUID tenantId, string spaceId, string appId, string versionId) {
    return buildPath(appDirectory(tenantId, spaceId, appId), "versions", safeIdentity(versionId));
  }

  private string tenantDirectory(UUID tenantId) {
    return buildPath(_root, "tenants", safeIdentity(tenantId));
  }

  private string spaceDirectory(UUID tenantId, string spaceId) {
    return buildPath(tenantDirectory(tenantId), "spaces", safeIdentity(spaceId));
  }

  private string safeIdentity(string raw) {
    char[] sanitized;
    foreach (ch; raw) {
      if (
        (ch >= 'a' && ch <= 'z') ||
        (ch >= 'A' && ch <= 'Z') ||
        (ch >= '0' && ch <= '9') ||
        ch == '-' ||
        ch == '_' ||
        ch == '.'
        ) {
        sanitized ~= ch;
      } else {
        sanitized ~= '_';
      }
    }
    return sanitized.idup;
  }

  private void validateIdentity(string value, string fieldName) {
    if (strip(value).length == 0) {
      throw new HARValidationException(fieldName ~ " is required");
    }
  }
}
