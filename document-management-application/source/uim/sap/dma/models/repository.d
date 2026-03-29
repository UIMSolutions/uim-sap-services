module uim.sap.dma.models.repository;

import uim.sap.dma;

mixin(ShowModule!());

@safe:

/// Describes a connected CMIS-compliant repository.
class DMARepository : SAPEntity {
  string repositoryId;
  string name;
  string description;
  string vendorName;
  string productName;
  string productVersion;
  UUID rootFolderId;
  bool cmisCompliant = true;
  bool encryptionEnabled = false;
  SysTime connectedAt;

  override Json toJson() {
    return super.toJson()
      .set("repository_id", repositoryId)
      .set("name", name)
      .set("description", description)
      .set("vendor_name", vendorName)
      .set("product_name", productName)
      .set("product_version", productVersion)
      .set("root_folder_id", rootFolderId)
      .set("cmis_compliant", cmisCompliant)
      .set("encryption_enabled", encryptionEnabled)
      .set("connected_at", connectedAt.toISOExtString());
  }

  static DMARepository repositoryFromJson(Json request) {
  DMARepository repo = new DMARepository(request);
  repo.repositoryId = randomUUID();
  repo.connectedAt = Clock.currTime();
  repo.rootFolderId = randomUUID();

  if ("name" in request && request["name"].isString)
    repo.name = request["name"].getString;
  if ("description" in request && request["description"].isString)
    repo.description = request["description"].getString;
  if ("vendor_name" in request && request["vendor_name"].isString)
    repo.vendorName = request["vendor_name"].getString;
  if ("product_name" in request && request["product_name"].isString)
    repo.productName = request["product_name"].getString;
  if ("product_version" in request && request["product_version"].isString)
    repo.productVersion = request["product_version"].getString;
  if ("cmis_compliant" in request && request["cmis_compliant"].isBoolean)
    repo.cmisCompliant = request["cmis_compliant"].get!bool;
  if ("encryption_enabled" in request && request["encryption_enabled"].isBoolean)
    repo.encryptionEnabled = request["encryption_enabled"].get!bool;

  return repo;
}

}
