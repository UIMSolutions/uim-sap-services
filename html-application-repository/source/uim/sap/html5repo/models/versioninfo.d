module uim.sap.html5repo.models.versioninfo;

class AppVersionInfo : SAPTenantObject {
  mixin(SAPtenantObject!AppVersionInfo);

  override bool initialize(Json[string] initData) {
    if (!super.initialize(initData)) {
      return false;
    }

    if ("space_id" in initData && initData["space_id"].isString) {
      spaceId = UUID(initData["space_id"].get!string);
    }
    if ("app_id" in initData && initData["app_id"].isString) {
      appId = UUID(initData["app_id"].get!string);
    }
    if ("version" in initData && initData["version"].isString) {
      versionId = UUID(initData["version"].get!string);
    }
    if ("visibility" in initData && initData["visibility"].isString) {
      visibility = stringToVisibility(initData["visibility"].getString);
    }
    if ("active" in initData && initData["active"].isBool) {
      active = initData["active"].getBool;
    }
    if ("size_bytes" in initData && initData["size_bytes"].isNumber) {
      sizeBytes = cast(long)initData["size_bytes"].getNumber;
    }
    if ("file_count" in initData && initData["file_count"].isNumber) {
      fileCount = cast(long)initData["file_count"].getNumber;
    }

    tenantId = UUID(getString(initData, "tenant_id", ""));
    spaceId = UUID(getString(initData, "space_id", ""));
    appId = UUID(getString(initData, "app_id", ""));
    versionId = getString(initData, "version", "");
    visibility = visibilityFromString(getString(initData, "visibility", "private"));
    active = getBoolean(initData, "active", false);
    createdAt = getString(initData, "created_at", "");
    updatedAt = getString(initData, "updated_at", "");
    sizeBytes = getLong(initData, "size_bytes", 0L);
    fileCount = getLong(initData, "file_count", 0L);

    return true;
  }

  UUID spaceId;
  UUID appId;
  UUID versionId;
  Visibility visibility;
  bool active;
  long sizeBytes;
  long fileCount;

  override Json toJson() {
    return super.toJson()
      .set("space_id", spaceId)
      .set("app_id", appId)
      .set("version", versionId)
      .set("visibility", visibilityToString(visibility))
      .set("active", active)
      .set("size_bytes", sizeBytes)
      .set("file_count", fileCount);
  }

  static AppVersionInfo fromJson(Json payload) {
    AppVersionInfo item = new AppVersionInfo(payload);
    return item;
  }
}