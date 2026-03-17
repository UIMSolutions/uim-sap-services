module uim.sap.atp.models.catalog;

import uim.sap.atp;

mixin(ShowModule!());

@safe:

/**
  * Represents a catalog of ATP commands for a tenant. Contains metadata about the catalog and the list of command IDs it includes.
  *
  * This class is used to store and retrieve ATP catalog data, which defines the available commands and their organization for a tenant.
  *
  * Fields:
  * - catalogId: Unique identifier for the catalog.
  * - name: Name of the catalog.
  * - scenario: The scenario or context this catalog is associated with (e.g., "production", "testing").
  * - predefined: Indicates if this is a predefined system catalog or a custom one created by the tenant.
  * - commandIds: List of command IDs that are part of this catalog.
  *
  * Methods:
  * - toJson(): Serializes the catalog object to JSON format for storage or transmission.
  */
class ATPCatalog : SAPTenantObject {
  mixin(SAPObjectTemplate!ATPCatalog);
  
  UUID catalogId;
  string name;
  string scenario;
  bool predefined;
  UUID[] commandIds;

  override Json toJson()  {
    Json commands = commandIds.map!(id => id.toString()).array.toJson;

    return super.toJson()
      .set("catalog_id", catalogId)
      .set("name", name)
      .set("scenario", scenario)
      .set("predefined", predefined)
      .set("command_ids", commands);
  }
}
