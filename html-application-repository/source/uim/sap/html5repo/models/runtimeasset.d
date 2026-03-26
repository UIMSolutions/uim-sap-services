module uim.sap.html5repo.models.runtimeasset;

struct RuntimeAsset {
  UUID tenantId;
  UUID spaceId;
  UUID appId;
  UUID versionId;
  string path;
  string contentType;
  bool isPublic;
  string etag;
  ubyte[] content;
}
