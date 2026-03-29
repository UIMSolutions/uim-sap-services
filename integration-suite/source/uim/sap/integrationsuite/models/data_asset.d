/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.integrationsuite.models.data_asset;

import uim.sap.integrationsuite;

mixin(ShowModule!());

@safe:

/**
  * Represents a data asset in the SAP Integration Suite.
  * A data asset can be a dataset, an API, or a data stream that is used in integration scenarios.
  *
  * Fields:
  * - tenantId: The ID of the tenant that owns this data asset.
  * - assetId: A unique identifier for the data asset.
  * - name: The name of the data asset.
  * - description: A brief description of the data asset.
  * - assetType: The type of the data asset (e.g., dataset, api, stream).
  * - format: The data format (e.g., json, csv, parquet, xml).
  * - accessPolicy: The access policy for the data asset (e.g., open, restricted, contractual).
  * - provider: The provider of the data asset.
  * - dataSpaceName: The name of the data space this asset belongs to.
  * - contractId: The ID of the contract governing access to this data asset.
  * - status: The current status of the data asset (e.g., available, consumed, retired).
  * - accessCount: The number of times this data asset has been accessed.
  * - createdAt: The timestamp when the data asset was created.
  * - updatedAt: The timestamp when the data asset was last updated.
  *
  * Methods:
  * - toJson(): Converts the data asset instance into a JSON representation.
  * - dataAssetFromJson(UUID tenantId, Json request): Creates a new data asset instance from a JSON request, generating a unique assetId and setting the createdAt and updatedAt timestamps
  * 
  * Statuses:
  * - available: The data asset is available for use.
  * - consumed: The data asset has been consumed in an integration scenario.
  * - retired: The data asset is retired and should not be used for new scenarios.
  *
  * For more information on data assets and their management, refer to the SAP Integration Suite documentation.
  */
class INTDataAsset : SAPTenantEntity {
  mixin(SAPTenantEntity!INTDataAsset);

  UUID assetId;
  string name;
  string description;
  string assetType = "dataset"; // dataset | api | stream
  string format = "json"; // json | csv | parquet | xml
  string accessPolicy = "open"; // open | restricted | contractual
  string provider;
  string dataSpaceName;
  string contractId;
  string status = "available"; // available | consumed | retired
  long accessCount = 0;

  override Json toJson() {
    return super.toJson()
      .set("asset_id", assetId)
      .set("name", name)
      .set("description", description)
      .set("asset_type", assetType)
      .set("format", format)
      .set("access_policy", accessPolicy)
      .set("provider", provider)
      .set("data_space_name", dataSpaceName)
      .set("contract_id", contractId)
      .set("status", status)
      .set("access_count", accessCount);
  }

  static INTDataAsset dataAssetFromJson(UUID tenantId, Json request) {
  INTDataAsset a = new INTDataAsset(request);
  a.tenantId = tenantId;
  a.assetId = randomUUID();

  if ("name" in request && request["name"].isString)
    a.name = request["name"].getString;
  if ("description" in request && request["description"].isString)
    a.description = request["description"].getString;
  if ("asset_type" in request && request["asset_type"].isString)
    a.assetType = request["asset_type"].getString;
  if ("format" in request && request["format"].isString)
    a.format = request["format"].getString;
  if ("access_policy" in request && request["access_policy"].isString)
    a.accessPolicy = request["access_policy"].getString;
  if ("provider" in request && request["provider"].isString)
    a.provider = request["provider"].getString;
  if ("data_space_name" in request && request["data_space_name"].isString)
    a.dataSpaceName = request["data_space_name"].getString;
  if ("contract_id" in request && request["contract_id"].isString)
    a.contractId = request["contract_id"].getString;

  a.createdAt = Clock.currTime().toINTOExtString();
  a.updatedAt = a.createdAt;
  return a;
}
}


