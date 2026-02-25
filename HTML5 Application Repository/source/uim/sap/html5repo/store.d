module uim.sap.html5repo.store;

import std.algorithm.searching : canFind;
import std.array : join;
import std.base64 : Base64;
import std.datetime : Clock;
import std.file : SpanMode, dirEntries, exists, isDir, mkdirRecurse, readText, remove, rename, write;
import std.path : baseName, buildPath, dirName, extension;
import std.string : split, strip, toLower;

import vibe.data.json : Json, parseJsonString;

import uim.sap.html5repo.exceptions;
import uim.sap.html5repo.models;

class HTML5RepositoryStore {
    private string _root;

    this(string rootPath) {
        _root = rootPath;
        mkdirRecurse(_root);
    }

    void uploadVersion(TenantContext tenant, string appId, string version, Visibility visibility, UploadedAsset[] files, long maxUploadBytes, bool activateNow) {
        validateIdentity(tenant.tenantId, "tenant_id");
        validateIdentity(tenant.spaceId, "space_id");
        validateIdentity(appId, "app_id");
        validateIdentity(version, "version");

        if (files.length == 0) {
            throw new HTML5RepoValidationException("At least one file is required");
        }

        auto versionRoot = versionDirectory(tenant.tenantId, tenant.spaceId, appId, version);
        auto contentRoot = buildPath(versionRoot, "content");
        mkdirRecurse(contentRoot);

        long totalBytes = 0;
        long fileCount = 0;

        foreach (asset; files) {
            auto cleanPath = normalizeAssetPath(asset.path);
            if (asset.contentBase64.length == 0) {
                throw new HTML5RepoValidationException("content_base64 is required for " ~ cleanPath);
            }

            ubyte[] binaryContent;
            try {
                binaryContent = Base64.decode(asset.contentBase64);
            } catch (Exception) {
                throw new HTML5RepoValidationException("Invalid content_base64 for " ~ cleanPath);
            }

            totalBytes += cast(long)binaryContent.length;
            if (totalBytes > maxUploadBytes) {
                throw new HTML5RepoValidationException("Upload exceeds max upload size limit");
            }

            auto target = buildPath(contentRoot, cleanPath);
            mkdirRecurse(dirName(target));
            write(target, binaryContent);
            fileCount++;
        }

        auto now = Clock.currTime().toISOExtString();
        auto previous = tryGetVersionInfo(tenant.tenantId, tenant.spaceId, appId, version);

        AppVersionInfo info;
        info.tenantId = tenant.tenantId;
        info.spaceId = tenant.spaceId;
        info.appId = appId;
        info.version = version;
        info.visibility = visibility;
        info.createdAt = previous.version.length > 0 ? previous.createdAt : now;
        info.updatedAt = now;
        info.sizeBytes = totalBytes;
        info.fileCount = fileCount;
        info.active = false;

        writeVersionMetadata(info);

        if (activateNow) {
            setActiveVersion(tenant.tenantId, tenant.spaceId, appId, version);
        }
    }

    void setActiveVersion(string tenantId, string spaceId, string appId, string version) {
        auto requested = tryGetVersionInfo(tenantId, spaceId, appId, version);
        if (requested.version.length == 0) {
            throw new HTML5RepoNotFoundException("Version", appId ~ ":" ~ version);
        }

        auto versions = listVersions(tenantId, spaceId, appId);
        foreach (item; versions) {
            auto current = item;
            current.active = current.version == version;
            current.updatedAt = Clock.currTime().toISOExtString();
            writeVersionMetadata(current);
        }

        auto appRoot = appDirectory(tenantId, spaceId, appId);
        mkdirRecurse(appRoot);

        auto activeFile = buildPath(appRoot, "active-version.txt");
        auto tempFile = buildPath(appRoot, "active-version.tmp");
        write(tempFile, version);

        if (exists(activeFile)) {
            remove(activeFile);
        }
        rename(tempFile, activeFile);
    }

    AppVersionInfo[] listVersions(string tenantId, string spaceId, string appId) {
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
                info.active = activeVersion(tenantId, spaceId, appId) == info.version;
                results ~= info;
            } catch (Exception) {
            }
        }

        return results;
    }

    Json[] listApplications(string tenantId, string spaceId, bool includePublicFromOtherSpaces) {
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
                    active = versions[0].version;
                }

                auto activeInfo = tryGetVersionInfo(tenantId, currentSpace, appId, active);
                auto isOwnSpace = currentSpace == spaceId;
                auto isPublic = activeInfo.visibility == Visibility.publicAccess;
                if (!isOwnSpace && !(includePublicFromOtherSpaces && isPublic)) {
                    continue;
                }

                Json item = Json.emptyObject;
                item["tenant_id"] = tenantId;
                item["space_id"] = currentSpace;
                item["app_id"] = appId;
                item["active_version"] = active;
                item["active_visibility"] = visibilityToString(activeInfo.visibility);
                item["version_count"] = cast(long)versions.length;
                result ~= item;
            }
        }

        return result;
    }

    AppVersionInfo tryGetVersionInfo(string tenantId, string spaceId, string appId, string version) {
        auto metadataFile = buildPath(versionDirectory(tenantId, spaceId, appId, version), "metadata.json");
        if (!exists(metadataFile)) {
            return AppVersionInfo.init;
        }

        try {
            auto payload = parseJsonString(readText(metadataFile));
            auto info = AppVersionInfo.fromJson(payload);
            info.active = activeVersion(tenantId, spaceId, appId) == info.version;
            return info;
        } catch (Exception) {
            return AppVersionInfo.init;
        }
    }

    string activeVersion(string tenantId, string spaceId, string appId) {
        auto activeFile = buildPath(appDirectory(tenantId, spaceId, appId), "active-version.txt");
        if (!exists(activeFile)) {
            return "";
        }
        return strip(readText(activeFile));
    }

    string[] listFiles(string tenantId, string spaceId, string appId, string version) {
        string[] files;
        auto contentRoot = buildPath(versionDirectory(tenantId, spaceId, appId, version), "content");
        if (!exists(contentRoot)) {
            throw new HTML5RepoNotFoundException("Version", appId ~ ":" ~ version);
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

    RuntimeAsset loadAsset(string tenantId, string spaceId, string appId, string version, string assetPath, string consumerTenantId, string consumerSpaceId, bool allowPublicCrossSpace) {
        auto info = tryGetVersionInfo(tenantId, spaceId, appId, version);
        if (info.version.length == 0) {
            throw new HTML5RepoNotFoundException("Version", appId ~ ":" ~ version);
        }

        if (consumerTenantId.length > 0 && consumerTenantId != tenantId) {
            throw new HTML5RepoAuthorizationException("Cross-tenant consumption is not allowed");
        }

        auto privateAsset = info.visibility == Visibility.privateAccess;
        auto crossSpace = consumerSpaceId.length > 0 && consumerSpaceId != spaceId;

        if (privateAsset && crossSpace) {
            throw new HTML5RepoAuthorizationException("Private application cannot be consumed from another space");
        }

        if (!privateAsset && crossSpace && !allowPublicCrossSpace) {
            throw new HTML5RepoAuthorizationException("Cross-space public sharing is disabled");
        }

        auto cleanPath = normalizeAssetPath(assetPath);
        auto assetFile = buildPath(versionDirectory(tenantId, spaceId, appId, version), "content", cleanPath);
        if (!exists(assetFile)) {
            throw new HTML5RepoNotFoundException("Asset", cleanPath);
        }

        RuntimeAsset asset;
        asset.tenantId = tenantId;
        asset.spaceId = spaceId;
        asset.appId = appId;
        asset.version = version;
        asset.path = cleanPath;
        asset.isPublic = !privateAsset;
        asset.content = cast(ubyte[])read(assetFile);
        asset.contentType = mimeTypeFor(cleanPath);
        asset.etag = toEtag(info, cleanPath);
        return asset;
    }

    void deleteVersion(string tenantId, string spaceId, string appId, string version) {
        auto root = versionDirectory(tenantId, spaceId, appId, version);
        if (!exists(root)) {
            throw new HTML5RepoNotFoundException("Version", appId ~ ":" ~ version);
        }
        remove(root);

        auto active = activeVersion(tenantId, spaceId, appId);
        if (active == version) {
            auto activeFile = buildPath(appDirectory(tenantId, spaceId, appId), "active-version.txt");
            if (exists(activeFile)) {
                remove(activeFile);
            }
        }
    }

    private void writeVersionMetadata(AppVersionInfo info) {
        auto root = versionDirectory(info.tenantId, info.spaceId, info.appId, info.version);
        mkdirRecurse(root);
        auto file = buildPath(root, "metadata.json");
        write(file, info.toJson().toString());
    }

    private string toEtag(AppVersionInfo info, string path) {
        return info.appId ~ "-" ~ info.version ~ "-" ~ cast(string)info.sizeBytes ~ "-" ~ path;
    }

    private string normalizeAssetPath(string pathValue) {
        auto value = strip(pathValue);
        if (value.length == 0) {
            throw new HTML5RepoValidationException("asset path is required");
        }

        if (value[0] == '/') {
            value = value[1 .. $];
        }

        auto segments = split(value, "/");
        string[] clean;
        foreach (segment; segments) {
            if (segment.length == 0 || segment == "." || segment == "..") {
                throw new HTML5RepoValidationException("Invalid asset path");
            }
            clean ~= segment;
        }

        return clean.join("/");
    }

    private string mimeTypeFor(string assetPath) {
        auto ext = toLower(extension(assetPath));
        final switch (ext) {
            case ".html": return "text/html; charset=utf-8";
            case ".css": return "text/css; charset=utf-8";
            case ".js": return "application/javascript; charset=utf-8";
            case ".json": return "application/json; charset=utf-8";
            case ".svg": return "image/svg+xml";
            case ".png": return "image/png";
            case ".jpg":
            case ".jpeg": return "image/jpeg";
            case ".gif": return "image/gif";
            case ".ico": return "image/x-icon";
            case ".txt": return "text/plain; charset=utf-8";
            default: return "application/octet-stream";
        }
    }

    private string appDirectory(string tenantId, string spaceId, string appId) {
        return buildPath(spaceDirectory(tenantId, spaceId), "apps", safeIdentity(appId));
    }

    private string versionDirectory(string tenantId, string spaceId, string appId, string version) {
        return buildPath(appDirectory(tenantId, spaceId, appId), "versions", safeIdentity(version));
    }

    private string tenantDirectory(string tenantId) {
        return buildPath(_root, "tenants", safeIdentity(tenantId));
    }

    private string spaceDirectory(string tenantId, string spaceId) {
        return buildPath(tenantDirectory(tenantId), "spaces", safeIdentity(spaceId));
    }

    private string safeIdentity(string raw) {
        char[] out;
        foreach (ch; raw) {
            if ((ch >= 'a' && ch <= 'z') || (ch >= 'A' && ch <= 'Z') || (ch >= '0' && ch <= '9') || ch == '-' || ch == '_' || ch == '.') {
                out ~= ch;
            } else {
                out ~= '_';
            }
        }
        return out.idup;
    }

    private void validateIdentity(string value, string fieldName) {
        if (strip(value).length == 0) {
            throw new HTML5RepoValidationException(fieldName ~ " is required");
        }
    }
}
