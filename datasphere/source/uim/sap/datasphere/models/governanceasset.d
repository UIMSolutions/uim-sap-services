/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.datasphere.models.governanceasset;

import uim.sap.datasphere;

mixin(ShowModule!());

@safe:
/** 
 * Represents a governance asset in the Datasphere context, such as a catalog entry or glossary term.
 * This struct is designed to be flexible to accommodate various types of governance assets by including
  * common properties such as tenantId, assetId, title, assetType, quality, published status, and updatedAt timestamp.
  * The toJson method allows for easy serialization of the governance asset into a JSON format, which can be useful for API responses or storage.
  * Fields:
  * - tenantId: The ID of the tenant this asset belongs to.
  * - assetId: A unique identifier for the asset.
  * - title: The title or name of the asset.  
  * - assetType: The type of the asset (e.g., "catalog_entry", "glossary_term").
  * - quality: A string representing the quality of the asset (e.g., "high", "medium", "low").
  * - published: A boolean indicating whether the asset is published or not.
  * - updatedAt: The timestamp of the last update to this asset.  
  * 
  * Note: This struct is a simplified representation and may need to be extended with additional fields or methods depending on the specific requirements of the governance assets being modeled.
 */
struct DATGovernanceAsset {
  string tenantId;
  string assetId;
  string title;
  string assetType;
  string quality;
  bool published;
  SysTime updatedAt;

  Json toJson() const {
    Json payload = Json.emptyObject;
    payload["tenant_id"] = tenantId;
    payload["asset_id"] = assetId;
    payload["title"] = title;
    payload["asset_type"] = assetType;
    payload["quality"] = quality;
    payload["published"] = published;
    payload["updated_at"] = updatedAt.toISOExtString();
    return payload;
  }
}
