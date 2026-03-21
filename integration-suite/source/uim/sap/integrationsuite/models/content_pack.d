/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.integrationsuite.models.content_pack;

import uim.sap.integrationsuite;

mixin(ShowModule!());

@safe:

/**
  * Represents a content pack in the SAP Integration Suite, which is a collection of pre-built integration artifacts like iFlows, mappings, and APIs that can be easily deployed to accelerate integration projects.
  * Each content pack is associated with a specific tenant and can contain multiple iFlows and mappings. The content pack also includes metadata such as name, description, vendor, version, category, and status.
  * The toJson method converts the content pack instance into a JSON representation for API responses or storage.
  * The contentPackFromJson function creates a new content pack instance from a JSON request, generating a unique packId and setting the createdAt and updatedAt timestamps.
  * Example usage:
  * Json request = ...; // JSON payload from API request
  * INTContentPack pack = contentPackFromJson("tenant123", request);
  * Json response = pack.toJson(); // Convert content pack to JSON for API response
  * For more information on content packs and their management, refer to the SAP Integration Suite documentation.
  *
  * Fields:
  * - tenantId: The ID of the tenant that owns this content pack.
  * - packId: Unique identifier for the content pack.
  * - name: Human-readable name of the content pack.
  * - description: Optional description of the content pack.
  * - vendor: The provider or creator of the content pack.
  * - version_: The version of the content pack, following semantic versioning (e.g., 1.0.0).
  * - category: The category of the content pack (e.g., procurement, finance, hr).
  * - iflowIds: A list of iFlow IDs included in the content pack.
  * - mappingIds: A list of mapping IDs included in the content pack.
  * - status: The current status of the content pack (e.g., available, installed, deprecated).
  * - installedAt: The timestamp when the content pack was installed.
  * - createdAt: The timestamp when the content pack was created.
  * - updatedAt: The timestamp when the content pack was last updated.
  *
  * Methods:
  * - toJson(): Converts the content pack instance into a JSON representation.
  * - contentPackFromJson(UUID tenantId, Json request): Creates a new content pack instance from a JSON request, generating a unique packId and setting the createdAt and updatedAt timestamps
  * 
  * Statuses:
  * - available: The content pack is available for installation.
  * - installed: The content pack has been installed in the tenant.
  * - deprecated: The content pack is deprecated and should not be used for new installations.
  *
  * Categories:
  * - procurement: Content packs related to procurement processes and systems.
  * - finance: Content packs related to financial processes and systems.
  * - hr: Content packs related to human resources processes and systems.
  * - logistics: Content packs related to logistics processes and systems.
  * - customer_engagement: Content packs related to customer engagement processes and systems.
  * - other: Content packs that do not fit into the above categories.
  *
  * For more information on content packs and their management, refer to the SAP Integration Suite documentation.
  */
struct INTContentPack {
  UUID tenantId;
  string packId;
  string name;
  string description;
  string vendor;
  string version_ = "1.0.0";
  string category; // e.g. procurement, finance, hr
  string[] iflowIds;
  string[] mappingIds;
  string status = "available"; // available | installed | deprecated
  string installedAt;
  string createdAt;
  string updatedAt;

  override Json toJson()  {
    Json j = Json.emptyObject;
    j["tenant_id"] = tenantId;
    j["pack_id"] = packId;
    j["name"] = name;
    j["description"] = description;
    j["vendor"] = vendor;
    j["version"] = version_;
    j["category"] = category;

    Json flows = Json.emptyArray;
    foreach (id; iflowIds)
      flows ~= Json(id);
    j["iflow_ids"] = flows;

    Json maps = Json.emptyArray;
    foreach (id; mappingIds)
      maps ~= Json(id);
    j["mapping_ids"] = maps;

    j["status"] = status;
    j["installed_at"] = installedAt;
    j["created_at"] = createdAt;
    j["updated_at"] = updatedAt;
    return j;
  }
}

INTContentPack contentPackFromJson(UUID tenantId, Json request) {
  INTContentPack p;
  p.tenantId = UUID(tenantId);
  p.packId = randomUUID().toString();

  if ("name" in request && request["name"].isString)
    p.name = request["name"].get!string;
  if ("description" in request && request["description"].isString)
    p.description = request["description"].get!string;
  if ("vendor" in request && request["vendor"].isString)
    p.vendor = request["vendor"].get!string;
  if ("version" in request && request["version"].isString)
    p.version_ = request["version"].get!string;
  if ("category" in request && request["category"].isString)
    p.category = request["category"].get!string;
  if ("iflow_ids" in request && request["iflow_ids"].isArray) {
    foreach (item; request["iflow_ids"]) {
      if (item.isString)
        p.iflowIds ~= item.get!string;
    }
  }
  if ("mapping_ids" in request && request["mapping_ids"].isArray) {
    foreach (item; request["mapping_ids"]) {
      if (item.isString)
        p.mappingIds ~= item.get!string;
    }
  }

  p.createdAt = Clock.currTime().toINTOExtString();
  p.updatedAt = p.createdAt;
  return p;
}
