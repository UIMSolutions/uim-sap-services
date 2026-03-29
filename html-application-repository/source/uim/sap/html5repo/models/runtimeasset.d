module uim.sap.html5repo.models.runtimeasset;

class RuntimeAsset : SAPTenantEntity {
  mixin(SAPTenantEntityTemplate!RuntimeAsset);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    spaceId = initData.getUUID("space_id", NULLUUID);
    appId = initData.getUUID("app_id", NULLUUID);
    versionId = initData.getUUID("version_id", NULLUUID);
    path = initData.getString("path", "");
    contentType = initData.getString("content_type", "");
    isPublic = initData.getBool("is_public", false);
    etag = initData.getString("etag", "");
    content = initData.getBytes("content", null);

    return true;
  }

  UUID spaceId;
  UUID appId;
  UUID versionId;
  string path;
  string contentType;
  bool isPublic;
  string etag;
  ubyte[] content;

  override Json toJson() {
    return super.toJson()
      .set("space_id", spaceId)
      .set("app_id", appId)
      .set("version_id", versionId)
      .set("path", path)
      .set("content_type", contentType)
      .set("is_public", isPublic)
      .set("etag", etag)
      .set("content", content);
  }
}
