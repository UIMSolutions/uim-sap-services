module uim.sap.html5repo.models.runtimeasset;

struct RuntimeAsset {
  UUID tenantId;
  string spaceId;
  string appId;
  string versionId;
  string path;
  string contentType;
  bool isPublic;
  string etag;
  ubyte[] content;
}
