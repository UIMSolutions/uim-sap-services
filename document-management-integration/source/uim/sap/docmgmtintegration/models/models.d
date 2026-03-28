module uim.sap.docmgmtintegration.models.models;

import std.algorithm.searching : canFind;
import std.array : appender;
import std.conv : to;
import std.datetime : Clock, SysTime;
import std.string : replace, toLower, endsWith;
import std.uuid : randomUUID;

import vibe.data.json : Json;



// ---------------------------------------------------------------------------
// Tenant
// ---------------------------------------------------------------------------

/// Represents a tenant in the multi-tenant system.
class Tenant : SAPTenantObject {
  mixin(SAPObjectTemplate!Tenant);

  UUID tenantId;
  string name;
  string description;
  bool active = true;
  SysTime createdAt;
  SysTime modifiedAt;

  override Json toJson() {
    return super.toJson()
      .set("tenant_id", tenantId)
      .set("name", name)
      .set("description", description)
      .set("active", active)
      .set("created_at", createdAt.toISOExtString())
      .set("modified_at", modifiedAt.toISOExtString());
  }

  Tenant tenantFromJson(Json request) {
  Tenant t;
  t.tenantId = randomUUID();
  t.createdAt = Clock.currTime();
  t.modifiedAt = t.createdAt;
  t.active = true;

  if ("name" in request && request["name"].isString)
    t.name = request["name"].getString;
  if ("description" in request && request["description"].isString)
    t.description = request["description"].getString;

  return t;
}
}



// ---------------------------------------------------------------------------
// Repository (tenant-scoped)
// ---------------------------------------------------------------------------

/// Describes a connected CMIS-compliant repository, scoped to a tenant.
class Repository : SAPTenantObject {
  mixin(SAPObjectTemplate!Repository);

  UUID repositoryId;
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

  Repository repositoryFromJson(UUID tenantId, Json request) {
  Repository repo;
  repo.repositoryId = randomUUID();
  repo.tenantId = tenantId;
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





// ---------------------------------------------------------------------------
// Breadcrumb
// ---------------------------------------------------------------------------

struct Breadcrumb {
  string folderId;
  string name;

  override Json toJson() {
    Json r = Json.emptyObject;
    r["folder_id"] = folderId;
    r["name"] = name;
    return r;
  }
}
