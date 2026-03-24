module uim.sap.html5repo.models.versioninfo;

struct AppVersionInfo {
  UUID tenantId;
  string spaceId;
  string appId;
  string versionId;
  Visibility visibility;
  bool active;
  string createdAt;
  string updatedAt;
  long sizeBytes;
  long fileCount;

  override Json toJson() {
    return super.toJson()
      .set("tenant_id", tenantId)
      .set("space_id", spaceId)
      .set("app_id", appId)
      .set("version", versionId)
      .set("visibility", visibilityToString(visibility))
      .set("active", active)
      .set("created_at", createdAt)
      .set("updated_at", updatedAt)
      .set("size_bytes", sizeBytes)
      .set("file_count", fileCount);
  }

  static AppVersionInfo fromJson(Json payload) {
    AppVersionInfo item = new AppVersionInfo(payload);
    item.tenantId = UUID(getString(payload, "tenant_id", ""));
    item.spaceId = UUID(getString(payload, "space_id", ""));
    item.appId = UUID(getString(payload, "app_id", ""));
    item.versionId = getString(payload, "version", "");
    item.visibility = visibilityFromString(getString(payload, "visibility", "private"));
    item.active = getBoolean(payload, "active", false);
    item.createdAt = getString(payload, "created_at", "");
    item.updatedAt = getString(payload, "updated_at", "");
    item.sizeBytes = getLong(payload, "size_bytes", 0L);
    item.fileCount = getLong(payload, "file_count", 0L);
    return item;
  }
}