module uim.sap.docmgmtintegration.service;

import std.algorithm.sorting : sort;
import std.conv : to;
import std.datetime : Clock;
import std.string : toLower;
import std.uuid : randomUUID;

import vibe.data.json : Json;

import uim.sap.docmgmtintegration.config;
import uim.sap.docmgmtintegration.encryption;
import uim.sap.docmgmtintegration.exceptions;
import uim.sap.docmgmtintegration.models;
import uim.sap.docmgmtintegration.repositories;
import uim.sap.docmgmtintegration.store;

/**
 * Core business logic for the Document Management Integration Service.
 *
 * All document-management operations are tenant-scoped. The service
 * enforces tenant isolation when multitenancy is enabled.
 *
 * Provides operations for:
 *  - Tenant management (register / deactivate / list)
 *  - Repository management (connect CMIS-compliant repos per tenant)
 *  - Folder CRUD and hierarchy navigation (breadcrumbs)
 *  - Document CRUD, move, copy
 *  - Version management (create versions, check-out / check-in)
 *  - Metadata management (view / edit properties)
 *  - Document viewing and download
 *  - Encryption support for internal repositories
 *  - Embeddable UI5 component configuration
 *  - Integration links (bind external business objects to documents)
 */
class DocMgmtIntegrationService : SAPService {
  private DocMgmtIntegrationConfig _config;
  private DocMgmtIntegrationStore _store;
  private EncryptionManager _encryption;
  private RepositoryRegistry _registry;

  this(DocMgmtIntegrationConfig config) {
    config.validate();
    _config = config;
    _store = new DocMgmtIntegrationStore;
    _encryption = new EncryptionManager(config.encryptionEnabled, config.encryptionKey);
    _registry = new RepositoryRegistry;
  }

  @property const(DocMgmtIntegrationConfig) config() const {
    return _config;
  }

  // ===================================================================
  // Platform
  // ===================================================================

  override Json health() {
    Json healthInfo = super.health();
    healthInfo["ok"] = true;
    healthInfo["serviceName"] = _config.serviceName;
    healthInfo["serviceVersion"] = _config.serviceVersion;
    healthInfo["multitenancy_enabled"] = _config.multitenancyEnabled;
    healthInfo["repositories_connected"] = cast(long)_registry.count();
    return healthInfo;
  }

  // ===================================================================
  // Tenants
  // ===================================================================

  Json createTenant(Json request) {
    auto tenant = tenantFromJson(request);
    if (tenant.name.length == 0)
      throw new DocMgmtIntegrationValidationException("Tenant name is required");

    auto saved = _store.addTenant(tenant);

    // Bootstrap a default internal repository for the new tenant
    auto internal = new InternalRepositoryConnector(
      saved.tenantId, _config.defaultRepository, _config.encryptionEnabled);
    _registry.register(internal);
    _store.addRepository(internal.info());

    Json r = Json.emptyObject;
    r["success"] = true;
    r["tenant"] = saved.toJson();
    return r;
  }

  Json getTenant(UUID tenantId) {
    validateId(tenantId, "Tenant ID");
    auto tenant = _store.getTenant(tenantId);
    if (tenant.tenantId.length == 0)
      throw new DocMgmtIntegrationNotFoundException("Tenant", tenantId);
    Json r = Json.emptyObject;
    r["tenant"] = tenant.toJson();
    return r;
  }

  Json listTenants() {
    Json resources = Json.emptyArray;
    foreach (t; _store.listTenants())
      resources ~= t.toJson();

    return Json.emptyObject
      .set("resources", resources)
      .set("total_results", cast(long)resources.length);
  }

  Json updateTenant(UUID tenantId, Json request) {
    validateId(tenantId, "Tenant ID");
    auto tenant = _store.getTenant(tenantId);
    if (tenant.tenantId.length == 0)
      throw new DocMgmtIntegrationNotFoundException("Tenant", tenantId);

    if ("name" in request && request["name"].isString)
      tenant.name = request["name"].get!string;
    if ("description" in request && request["description"].isString)
      tenant.description = request["description"].get!string;
    if ("active" in request && request["active"].isBoolean)
      tenant.active = request["active"].get!bool;

    auto saved = _store.updateTenant(tenant);
    Json r = Json.emptyObject;
    r["success"] = true;
    r["tenant"] = saved.toJson();
    return r;
  }

  Json deleteTenant(UUID tenantId) {
    validateId(tenantId, "Tenant ID");
    auto tenant = _store.getTenant(tenantId);
    if (tenant.tenantId.length == 0)
      throw new DocMgmtIntegrationNotFoundException("Tenant", tenantId);

    _store.removeTenant(tenantId);
    // Clean up repositories, UI config, and links belonging to tenant
    foreach (repo; _store.listRepositories(tenantId)) {
      _registry.remove(repo.repositoryId);
      _store.removeRepository(repo.repositoryId);
    }
    _store.removeUIConfig(tenantId);
    foreach (link; _store.listLinks(tenantId))
      _store.removeLink(link.linkId);

    Json r = Json.emptyObject;
    r["success"] = true;
    r["message"] = "Tenant deleted: " ~ tenant.name;
    return r;
  }

  // ===================================================================
  // Repositories (tenant-scoped)
  // ===================================================================

  Json listRepositories(UUID tenantId) {
    ensureTenant(tenantId);
    Json resources = Json.emptyArray;
    foreach (repo; _store.listRepositories(tenantId))
      resources ~= repo.toJson();
    Json r = Json.emptyObject;
    r["resources"] = resources;
    r["total_results"] = cast(long)resources.length;
    return r;
  }

  Json getRepository(UUID tenantId, string repositoryId) {
    ensureTenant(tenantId);
    validateId(repositoryId, "Repository ID");
    auto repo = _store.getRepository(repositoryId);
    if (repo.repositoryId.length == 0 || repo.tenantId != tenantId)
      throw new DocMgmtIntegrationNotFoundException("Repository", repositoryId);
    Json r = Json.emptyObject;
    r["repository"] = repo.toJson();
    return r;
  }

  Json connectRepository(UUID tenantId, Json request) {
    ensureTenant(tenantId);
    auto repo = repositoryFromJson(tenantId, request);
    if (repo.name.length == 0)
      throw new DocMgmtIntegrationValidationException("Repository name is required");

    auto connector = new ExternalCmisConnector(repo);
    if (!connector.ping())
      throw new DocMgmtIntegrationValidationException(
        "Cannot reach repository: " ~ repo.name);

    _registry.register(connector);
    auto saved = _store.addRepository(repo);

    Json r = Json.emptyObject;
    r["success"] = true;
    r["repository"] = saved.toJson();
    return r;
  }

  Json disconnectRepository(UUID tenantId, string repositoryId) {
    ensureTenant(tenantId);
    validateId(repositoryId, "Repository ID");
    auto repo = _store.getRepository(repositoryId);
    if (repo.repositoryId.length == 0 || repo.tenantId != tenantId)
      throw new DocMgmtIntegrationNotFoundException("Repository", repositoryId);

    _registry.remove(repositoryId);
    _store.removeRepository(repositoryId);

    Json r = Json.emptyObject;
    r["success"] = true;
    r["message"] = "Repository disconnected: " ~ repo.name;
    return r;
  }

  // ===================================================================
  // Folders (tenant-scoped)
  // ===================================================================

  Json createFolder(UUID tenantId, string repositoryId,
    string parentFolderId, Json request) {
    ensureTenant(tenantId);
    validateId(repositoryId, "Repository ID");
    ensureRepository(tenantId, repositoryId);

    if (parentFolderId.length > 0)
      ensureFolder(parentFolderId);

    auto folder = folderFromJson(tenantId, repositoryId, parentFolderId, request);
    if (folder.name.length == 0)
      throw new DocMgmtIntegrationValidationException("Folder name is required");

    auto saved = _store.addFolder(folder);

    Json r = Json.emptyObject;
    r["success"] = true;
    r["folder"] = saved.toJson();
    return r;
  }

  Json getFolder(UUID tenantId, string folderId) {
    ensureTenant(tenantId);
    validateId(folderId, "Folder ID");
    auto folder = _store.getFolder(folderId);
    if (folder.folderId.length == 0 || folder.tenantId != tenantId)
      throw new DocMgmtIntegrationNotFoundException("Folder", folderId);

    return Json.emptyObject
      .set("folder", folder.toJson())
      .set("breadcrumbs", breadcrumbsJson(folderId));
  }

  Json updateFolder(UUID tenantId, string folderId, Json request) {
    ensureTenant(tenantId);
    validateId(folderId, "Folder ID");
    auto folder = _store.getFolder(folderId);
    if (folder.folderId.length == 0 || folder.tenantId != tenantId)
      throw new DocMgmtIntegrationNotFoundException("Folder", folderId);

    if ("name" in request && request["name"].isString)
      folder.name = request["name"].get!string;
    if ("description" in request && request["description"].isString)
      folder.description = request["description"].get!string;
    if ("properties" in request && request["properties"].isObject)
      folder.properties = request["properties"];

    auto saved = _store.updateFolder(folder);

    Json r = Json.emptyObject;
    r["success"] = true;
    r["folder"] = saved.toJson();
    return r;
  }

  Json deleteFolder(UUID tenantId, string folderId) {
    ensureTenant(tenantId);
    validateId(folderId, "Folder ID");
    auto folder = _store.getFolder(folderId);
    if (folder.folderId.length == 0 || folder.tenantId != tenantId)
      throw new DocMgmtIntegrationNotFoundException("Folder", folderId);

    // Remove all descendant folders and their documents
    auto descendants = _store.getDescendantFolderIds(folderId);
    foreach (childId; descendants) {
      removeDocumentsInFolder(tenantId, folder.repositoryId, childId);
      _store.removeFolder(childId);
    }
    removeDocumentsInFolder(tenantId, folder.repositoryId, folderId);
    _store.removeFolder(folderId);

    Json r = Json.emptyObject;
    r["success"] = true;
    r["message"] = "Folder deleted: " ~ folder.name;
    return r;
  }

  Json listFolderContents(UUID tenantId, string repositoryId, string folderId) {
    ensureTenant(tenantId);
    validateId(repositoryId, "Repository ID");
    ensureRepository(tenantId, repositoryId);

    Json folders = Json.emptyArray;
    foreach (f; _store.listFolders(tenantId, repositoryId, folderId))
      folders ~= f.toJson();

    Json documents = Json.emptyArray;
    foreach (d; _store.listDocuments(tenantId, repositoryId, folderId))
      documents ~= d.toJson();

    Json r = Json.emptyObject;
    r["tenant_id"] = tenantId;
    r["repository_id"] = repositoryId;
    r["folder_id"] = folderId;
    r["folders"] = folders;
    r["documents"] = documents;
    r["total_folders"] = cast(long)folders.length;
    r["total_documents"] = cast(long)documents.length;
    if (folderId.length > 0)
      r["breadcrumbs"] = breadcrumbsJson(folderId);
    return r;
  }

  Json moveFolder(UUID tenantId, string folderId, Json request) {
    ensureTenant(tenantId);
    validateId(folderId, "Folder ID");
    auto folder = _store.getFolder(folderId);
    if (folder.folderId.length == 0 || folder.tenantId != tenantId)
      throw new DocMgmtIntegrationNotFoundException("Folder", folderId);

    string targetParentId = "";
    if ("target_folder_id" in request && request["target_folder_id"].isString)
      targetParentId = request["target_folder_id"].get!string;

    if (targetParentId.length > 0) {
      ensureFolder(targetParentId);
      auto descendants = _store.getDescendantFolderIds(folderId);
      import std.algorithm.searching : canFind;

      if (descendants.canFind(targetParentId))
        throw new DocMgmtIntegrationValidationException(
          "Cannot move a folder into its own subtree");
    }

    folder.parentFolderId = targetParentId;
    auto saved = _store.updateFolder(folder);

    Json r = Json.emptyObject;
    r["success"] = true;
    r["folder"] = saved.toJson();
    return r;
  }

  Json copyFolder(UUID tenantId, string folderId, Json request) {
    ensureTenant(tenantId);
    validateId(folderId, "Folder ID");
    auto folder = _store.getFolder(folderId);
    if (folder.folderId.length == 0 || folder.tenantId != tenantId)
      throw new DocMgmtIntegrationNotFoundException("Folder", folderId);

    string targetParentId = "";
    if ("target_folder_id" in request && request["target_folder_id"].isString)
      targetParentId = request["target_folder_id"].get!string;
    if (targetParentId.length > 0)
      ensureFolder(targetParentId);

    Folder copy = folder;
    copy.folderId = randomUUID();
    copy.parentFolderId = targetParentId;
    copy.createdAt = Clock.currTime();
    copy.modifiedAt = copy.createdAt;
    auto saved = _store.addFolder(copy);

    foreach (doc; _store.listDocuments(tenantId, folder.repositoryId, folderId)) {
      _store.copyDocument(doc.documentId, saved.folderId);
    }

    return Json.emptyObject
      .set("success", true)
      .set("folder", saved.toJson());
  }

  // ===================================================================
  // Documents (tenant-scoped)
  // ===================================================================

  Json createDocument(UUID tenantId, string repositoryId, string folderId, Json request) {
    ensureTenant(tenantId);
    validateId(repositoryId, "Repository ID");
    ensureRepository(tenantId, repositoryId);

    if (folderId.length > 0)
      ensureFolder(folderId);

    auto doc = documentFromJson(tenantId, repositoryId, folderId, request);
    if (doc.name.length == 0)
      throw new DocMgmtIntegrationValidationException("Document name is required");

    // Handle encryption for internal repositories
    auto repo = _store.getRepository(repositoryId);
    if (repo.encryptionEnabled || _encryption.enabled) {
      doc.encrypted = true;
    }

    auto saved = _store.addDocument(doc);

    // Create initial version (v1)
    if (_config.versioningEnabled) {
      auto ver = versionFromJson(tenantId, saved.documentId, 1, request);
      ver.sizeBytes = saved.sizeBytes;
      ver.mimeType = saved.mimeType;
      ver.createdBy = saved.createdBy;
      ver.isMajor = true;
      ver.versionLabel = "1.0";
      ver.encrypted = saved.encrypted;
      _store.addVersion(ver);

      // Store initial content if provided
      if ("content" in request && request["content"].isString) {
        auto content = request["content"].get!string;
        if (saved.encrypted) {
          import std.string : representation;

          content = _encryption.encrypt(cast(const(ubyte)[])content.representation);
        }
        _store.storeContent(ver.versionId, content);
      }

      saved.latestVersionId = ver.versionId;
      saved = _store.updateDocument(saved);
    }

    return Json.emptyObject
      .set("success", true)
      .set("document", saved.toJson());
  }

  Json getDocument(UUID tenantId, string documentId) {
    ensureTenant(tenantId);
    validateId(documentId, "Document ID");
    auto doc = _store.getDocument(documentId);
    if (doc.documentId.length == 0 || doc.tenantId != tenantId)
      throw new DocMgmtIntegrationNotFoundException("Document", documentId);

    return Json.emptyObject
      .set("document", doc.toJson())
      .set("viewable", isViewableExtension(doc.name))
      .set("breadcrumbs", breadcrumbsJson(doc.folderId));
  }

  Json updateDocument(UUID tenantId, string documentId, Json request) {
    ensureTenant(tenantId);
    validateId(documentId, "Document ID");
    auto doc = _store.getDocument(documentId);
    if (doc.documentId.length == 0 || doc.tenantId != tenantId)
      throw new DocMgmtIntegrationNotFoundException("Document", documentId);

    // Cannot edit if checked out by someone else
    if (doc.status == DocumentStatus.checkedOut) {
      string actor = "system";
      if ("modified_by" in request && request["modified_by"].isString)
        actor = request["modified_by"].get!string;
      if (doc.checkedOutBy != actor)
        throw new DocMgmtIntegrationConflictException(
          "Document is checked out by " ~ doc.checkedOutBy);
    }

    if ("name" in request && request["name"].isString)
      doc.name = request["name"].get!string;
    if ("description" in request && request["description"].isString)
      doc.description = request["description"].get!string;
    if ("mime_type" in request && request["mime_type"].isString)
      doc.mimeType = request["mime_type"].get!string;
    if ("modified_by" in request && request["modified_by"].isString)
      doc.modifiedBy = request["modified_by"].get!string;

    auto saved = _store.updateDocument(doc);

    Json r = Json.emptyObject;
    r["success"] = true;
    r["document"] = saved.toJson();
    return r;
  }

  Json deleteDocument(UUID tenantId, string documentId) {
    ensureTenant(tenantId);
    validateId(documentId, "Document ID");
    auto doc = _store.getDocument(documentId);
    if (doc.documentId.length == 0 || doc.tenantId != tenantId)
      throw new DocMgmtIntegrationNotFoundException("Document", documentId);

    if (doc.status == DocumentStatus.checkedOut)
      throw new DocMgmtIntegrationConflictException(
        "Cannot delete a checked-out document. Check it in first.");

    // Remove any integration links pointing to this document
    foreach (link; _store.listLinksByDocument(tenantId, documentId))
      _store.removeLink(link.linkId);

    _store.removeDocument(documentId);

    Json r = Json.emptyObject;
    r["success"] = true;
    r["message"] = "Document deleted: " ~ doc.name;
    return r;
  }

  Json moveDocument(UUID tenantId, string documentId, Json request) {
    ensureTenant(tenantId);
    validateId(documentId, "Document ID");
    auto doc = _store.getDocument(documentId);
    if (doc.documentId.length == 0 || doc.tenantId != tenantId)
      throw new DocMgmtIntegrationNotFoundException("Document", documentId);

    string targetFolderId = "";
    if ("target_folder_id" in request && request["target_folder_id"].isString)
      targetFolderId = request["target_folder_id"].get!string;
    if (targetFolderId.length > 0)
      ensureFolder(targetFolderId);

    auto moved = _store.moveDocument(documentId, targetFolderId);

    Json r = Json.emptyObject;
    r["success"] = true;
    r["document"] = moved.toJson();
    return r;
  }

  Json copyDocument(UUID tenantId, string documentId, Json request) {
    ensureTenant(tenantId);
    validateId(documentId, "Document ID");
    auto doc = _store.getDocument(documentId);
    if (doc.documentId.length == 0 || doc.tenantId != tenantId)
      throw new DocMgmtIntegrationNotFoundException("Document", documentId);

    string targetFolderId = "";
    if ("target_folder_id" in request && request["target_folder_id"].isString)
      targetFolderId = request["target_folder_id"].get!string;
    if (targetFolderId.length > 0)
      ensureFolder(targetFolderId);

    auto copied = _store.copyDocument(documentId, targetFolderId);

    Json r = Json.emptyObject;
    r["success"] = true;
    r["document"] = copied.toJson();
    return r;
  }

  // ===================================================================
  // Document Viewing & Download
  // ===================================================================

  Json viewDocument(UUID tenantId, string documentId) {
    ensureTenant(tenantId);
    validateId(documentId, "Document ID");
    auto doc = _store.getDocument(documentId);
    if (doc.documentId.length == 0 || doc.tenantId != tenantId)
      throw new DocMgmtIntegrationNotFoundException("Document", documentId);

    bool viewable = isViewableExtension(doc.name);

    Json r = Json.emptyObject;
    r["document_id"] = documentId;
    r["tenant_id"] = tenantId;
    r["name"] = doc.name;
    r["mime_type"] = doc.mimeType;
    r["size_bytes"] = doc.sizeBytes;
    r["viewable"] = viewable;
    r["viewer_type"] = viewable ? viewerType(doc.name) : "download";

    if (viewable && doc.latestVersionId.length > 0) {
      auto content = _store.getContent(doc.latestVersionId);
      if (content.length > 0 && doc.encrypted) {
        auto decrypted = _encryption.decrypt(content);
        r["content_available"] = true;
      } else {
        r["content_available"] = content.length > 0;
      }
    } else {
      r["content_available"] = false;
      r["download_url"] = "/api/docmgmt-integration/v1/tenants/" ~ tenantId
        ~ "/documents/" ~ documentId ~ "/download";
    }
    return r;
  }

  Json downloadDocument(UUID tenantId, string documentId) {
    ensureTenant(tenantId);
    validateId(documentId, "Document ID");
    auto doc = _store.getDocument(documentId);
    if (doc.documentId.length == 0 || doc.tenantId != tenantId)
      throw new DocMgmtIntegrationNotFoundException("Document", documentId);

    string content = "";
    if (doc.latestVersionId.length > 0) {
      content = _store.getContent(doc.latestVersionId);
      if (content.length > 0 && doc.encrypted) {
        auto decrypted = _encryption.decrypt(content);
        import std.base64 : Base64;

        content = Base64.encode(decrypted);
      }
    }

    Json r = Json.emptyObject;
    r["document_id"] = documentId;
    r["tenant_id"] = tenantId;
    r["name"] = doc.name;
    r["mime_type"] = doc.mimeType;
    r["size_bytes"] = doc.sizeBytes;
    r["encrypted"] = doc.encrypted;
    r["content"] = content;
    return r;
  }

  // ===================================================================
  // Metadata Management
  // ===================================================================

  Json getDocumentMetadata(UUID tenantId, string documentId) {
    ensureTenant(tenantId);
    validateId(documentId, "Document ID");
    auto doc = _store.getDocument(documentId);
    if (doc.documentId.length == 0 || doc.tenantId != tenantId)
      throw new DocMgmtIntegrationNotFoundException("Document", documentId);

    Json r = Json.emptyObject;
    r["document_id"] = documentId;
    r["tenant_id"] = tenantId;
    r["name"] = doc.name;
    r["description"] = doc.description;
    r["mime_type"] = doc.mimeType;
    r["size_bytes"] = doc.sizeBytes;
    r["created_by"] = doc.createdBy;
    r["modified_by"] = doc.modifiedBy;
    r["created_at"] = doc.createdAt.toISOExtString();
    r["modified_at"] = doc.modifiedAt.toISOExtString();
    r["status"] = cast(string)doc.status;
    r["encrypted"] = doc.encrypted;
    r["current_version"] = doc.currentVersion;
    r["properties"] = doc.properties;
    return r;
  }

  Json updateDocumentMetadata(UUID tenantId, string documentId, Json request) {
    ensureTenant(tenantId);
    validateId(documentId, "Document ID");
    auto doc = _store.getDocument(documentId);
    if (doc.documentId.length == 0 || doc.tenantId != tenantId)
      throw new DocMgmtIntegrationNotFoundException("Document", documentId);

    if ("properties" in request && request["properties"].isObject)
      doc.properties = request["properties"];
    if ("description" in request && request["description"].isString)
      doc.description = request["description"].get!string;

    auto saved = _store.updateDocument(doc);

    Json r = Json.emptyObject;
    r["success"] = true;
    r["document_id"] = documentId;
    r["properties"] = saved.properties;
    r["description"] = saved.description;
    return r;
  }

  Json getFolderProperties(UUID tenantId, string folderId) {
    ensureTenant(tenantId);
    validateId(folderId, "Folder ID");
    auto folder = _store.getFolder(folderId);
    if (folder.folderId.length == 0 || folder.tenantId != tenantId)
      throw new DocMgmtIntegrationNotFoundException("Folder", folderId);

    Json r = Json.emptyObject;
    r["folder_id"] = folderId;
    r["tenant_id"] = tenantId;
    r["name"] = folder.name;
    r["description"] = folder.description;
    r["created_by"] = folder.createdBy;
    r["created_at"] = folder.createdAt.toISOExtString();
    r["modified_at"] = folder.modifiedAt.toISOExtString();
    r["properties"] = folder.properties;
    return r;
  }

  Json updateFolderProperties(UUID tenantId, string folderId, Json request) {
    ensureTenant(tenantId);
    validateId(folderId, "Folder ID");
    auto folder = _store.getFolder(folderId);
    if (folder.folderId.length == 0 || folder.tenantId != tenantId)
      throw new DocMgmtIntegrationNotFoundException("Folder", folderId);

    if ("properties" in request && request["properties"].isObject)
      folder.properties = request["properties"];
    if ("description" in request && request["description"].isString)
      folder.description = request["description"].get!string;

    auto saved = _store.updateFolder(folder);

    Json r = Json.emptyObject;
    r["success"] = true;
    r["folder_id"] = folderId;
    r["properties"] = saved.properties;
    r["description"] = saved.description;
    return r;
  }

  // ===================================================================
  // Versioning (tenant-scoped)
  // ===================================================================

  Json listVersions(UUID tenantId, string documentId) {
    ensureTenant(tenantId);
    validateId(documentId, "Document ID");
    ensureDocument(tenantId, documentId);

    Json resources = Json.emptyArray;
    foreach (v; _store.listVersions(documentId))
      resources ~= v.toJson();

    Json r = Json.emptyObject;
    r["document_id"] = documentId;
    r["tenant_id"] = tenantId;
    r["resources"] = resources;
    r["total_results"] = cast(long)resources.length;
    return r;
  }

  Json createVersion(UUID tenantId, string documentId, Json request) {
    ensureTenant(tenantId);
    validateId(documentId, "Document ID");
    auto doc = _store.getDocument(documentId);
    if (doc.documentId.length == 0 || doc.tenantId != tenantId)
      throw new DocMgmtIntegrationNotFoundException("Document", documentId);

    if (!_config.versioningEnabled)
      throw new DocMgmtIntegrationValidationException("Versioning is disabled");

    if (doc.status == DocumentStatus.checkedOut) {
      string actor = "system";
      if ("created_by" in request && request["created_by"].isString)
        actor = request["created_by"].get!string;
      if (doc.checkedOutBy != actor)
        throw new DocMgmtIntegrationConflictException(
          "Document is checked out by " ~ doc.checkedOutBy);
    }

    int nextVer = _store.nextVersionNumber(documentId);
    auto ver = versionFromJson(tenantId, documentId, nextVer, request);
    ver.encrypted = doc.encrypted;

    if ("content" in request && request["content"].isString) {
      auto content = request["content"].get!string;
      if (doc.encrypted) {
        import std.string : representation;

        content = _encryption.encrypt(cast(const(ubyte)[])content.representation);
      }
      _store.storeContent(ver.versionId, content);
    }

    auto savedVer = _store.addVersion(ver);

    doc.currentVersion = nextVer;
    doc.latestVersionId = savedVer.versionId;
    doc.modifiedAt = Clock.currTime();
    if ("size_bytes" in request && request["size_bytes"].isInteger)
      doc.sizeBytes = request["size_bytes"].get!long;
    _store.updateDocument(doc);

    Json r = Json.emptyObject;
    r["success"] = true;
    r["version"] = savedVer.toJson();
    r["document"] = doc.toJson();
    return r;
  }

  Json getVersion(UUID tenantId, string documentId, string versionId) {
    ensureTenant(tenantId);
    validateId(documentId, "Document ID");
    validateId(versionId, "Version ID");
    ensureDocument(tenantId, documentId);

    auto ver = _store.getVersion(documentId, versionId);
    if (ver.versionId.length == 0)
      throw new DocMgmtIntegrationNotFoundException("Version", versionId);

    Json r = Json.emptyObject;
    r["version"] = ver.toJson();
    return r;
  }

  // ===================================================================
  // Check-out / Check-in Workflow
  // ===================================================================

  Json checkOutDocument(UUID tenantId, string documentId, Json request) {
    ensureTenant(tenantId);
    validateId(documentId, "Document ID");
    auto doc = _store.getDocument(documentId);
    if (doc.documentId.length == 0 || doc.tenantId != tenantId)
      throw new DocMgmtIntegrationNotFoundException("Document", documentId);

    if (doc.status == DocumentStatus.checkedOut)
      throw new DocMgmtIntegrationConflictException(
        "Document is already checked out by " ~ doc.checkedOutBy);

    string actor = "system";
    if ("user" in request && request["user"].isString)
      actor = request["user"].get!string;

    doc.status = DocumentStatus.checkedOut;
    doc.checkedOutBy = actor;
    auto saved = _store.updateDocument(doc);

    Json r = Json.emptyObject;
    r["success"] = true;
    r["document"] = saved.toJson();
    r["message"] = "Document checked out by " ~ actor;
    return r;
  }

  Json checkInDocument(UUID tenantId, string documentId, Json request) {
    ensureTenant(tenantId);
    validateId(documentId, "Document ID");
    auto doc = _store.getDocument(documentId);
    if (doc.documentId.length == 0 || doc.tenantId != tenantId)
      throw new DocMgmtIntegrationNotFoundException("Document", documentId);

    if (doc.status != DocumentStatus.checkedOut)
      throw new DocMgmtIntegrationConflictException(
        "Document is not currently checked out");

    string actor = "system";
    if ("user" in request && request["user"].isString)
      actor = request["user"].get!string;
    if (doc.checkedOutBy != actor)
      throw new DocMgmtIntegrationConflictException(
        "Document was checked out by " ~ doc.checkedOutBy ~ ", not " ~ actor);

    doc.status = DocumentStatus.checkedIn;
    doc.checkedOutBy = "";

    if (_config.versioningEnabled) {
      int nextVer = _store.nextVersionNumber(documentId);
      auto ver = versionFromJson(tenantId, documentId, nextVer, request);
      ver.encrypted = doc.encrypted;
      ver.createdBy = actor;

      if ("content" in request && request["content"].isString) {
        auto content = request["content"].get!string;
        if (doc.encrypted) {
          import std.string : representation;

          content = _encryption.encrypt(cast(const(ubyte)[])content.representation);
        }
        _store.storeContent(ver.versionId, content);
      }

      auto savedVer = _store.addVersion(ver);
      doc.currentVersion = nextVer;
      doc.latestVersionId = savedVer.versionId;
    }

    auto saved = _store.updateDocument(doc);

    Json r = Json.emptyObject;
    r["success"] = true;
    r["document"] = saved.toJson();
    r["message"] = "Document checked in by " ~ actor;
    return r;
  }

  Json cancelCheckOut(UUID tenantId, string documentId, Json request) {
    ensureTenant(tenantId);
    validateId(documentId, "Document ID");
    auto doc = _store.getDocument(documentId);
    if (doc.documentId.length == 0 || doc.tenantId != tenantId)
      throw new DocMgmtIntegrationNotFoundException("Document", documentId);

    if (doc.status != DocumentStatus.checkedOut)
      throw new DocMgmtIntegrationConflictException(
        "Document is not currently checked out");

    doc.status = DocumentStatus.draft;
    doc.checkedOutBy = "";
    auto saved = _store.updateDocument(doc);

    Json r = Json.emptyObject;
    r["success"] = true;
    r["document"] = saved.toJson();
    r["message"] = "Check-out cancelled";
    return r;
  }

  // ===================================================================
  // Sorting / Personalization
  // ===================================================================

  Json listDocumentsSorted(UUID tenantId, string repositoryId,
    string folderId, Json request) {
    ensureTenant(tenantId);
    validateId(repositoryId, "Repository ID");
    ensureRepository(tenantId, repositoryId);

    auto docs = _store.listDocuments(tenantId, repositoryId, folderId);

    string sortBy = "name";
    if ("sort_by" in request && request["sort_by"].isString)
      sortBy = toLower(request["sort_by"].get!string);

    bool descending = false;
    if ("descending" in request && request["descending"].isBoolean)
      descending = request["descending"].get!bool;

    if (sortBy == "name") {
      sort!((a, b) => descending ? a.name > b.name : a.name < b.name)(docs);
    } else if (sortBy == "size_bytes" || sortBy == "size") {
      sort!((a, b) => descending ? a.sizeBytes > b.sizeBytes : a.sizeBytes < b.sizeBytes)(docs);
    } else if (sortBy == "created_at") {
      sort!((a, b) => descending ? a.createdAt > b.createdAt : a.createdAt < b.createdAt)(docs);
    } else if (sortBy == "modified_at") {
      sort!((a, b) => descending ? a.modifiedAt > b.modifiedAt : a.modifiedAt < b.modifiedAt)(docs);
    } else if (sortBy == "mime_type") {
      sort!((a, b) => descending ? a.mimeType > b.mimeType : a.mimeType < b.mimeType)(docs);
    }

    Json resources = Json.emptyArray;
    foreach (d; docs)
      resources ~= d.toJson();

    Json r = Json.emptyObject;
    r["tenant_id"] = tenantId;
    r["repository_id"] = repositoryId;
    r["folder_id"] = folderId;
    r["sort_by"] = sortBy;
    r["descending"] = descending;
    r["resources"] = resources;
    r["total_results"] = cast(long)resources.length;
    return r;
  }

  // ===================================================================
  // Encryption info
  // ===================================================================

  Json encryptionStatus() {
    Json r = Json.emptyObject;
    r["encryption_enabled"] = _encryption.enabled;
    r["algorithm"] = _encryption.enabled ? "XOR-SHA256-derived" : "none";
    r["note"] = _encryption.enabled
      ? "Data is encrypted at rest using service-managed keys"
      : "Encryption is not enabled for this deployment";
    return r;
  }

  // ===================================================================
  // UI Component Configuration (tenant-scoped)
  // ===================================================================

  Json getUIComponentConfig(UUID tenantId) {
    ensureTenant(tenantId);
    auto cfg = _store.getUIConfig(tenantId);
    // Return defaults if none configured
    if (cfg.tenantId.length == 0) {
      cfg.tenantId = tenantId;
    }

    Json r = Json.emptyObject;
    r["ui_component"] = cfg.toJson();
    return r;
  }

  Json setUIComponentConfig(UUID tenantId, Json request) {
    ensureTenant(tenantId);
    auto cfg = uiConfigFromJson(tenantId, request);
    auto saved = _store.setUIConfig(cfg);

    Json r = Json.emptyObject;
    r["success"] = true;
    r["ui_component"] = saved.toJson();
    return r;
  }

  Json deleteUIComponentConfig(UUID tenantId) {
    ensureTenant(tenantId);
    _store.removeUIConfig(tenantId);

    Json r = Json.emptyObject;
    r["success"] = true;
    r["message"] = "UI component configuration removed for tenant " ~ tenantId;
    return r;
  }

  // ===================================================================
  // Integration Links (tenant-scoped)
  // ===================================================================

  Json createLink(UUID tenantId, Json request) {
    ensureTenant(tenantId);
    auto link = linkFromJson(tenantId, request);

    if (link.externalObjectId.length == 0)
      throw new DocMgmtIntegrationValidationException(
        "external_object_id is required");
    if (link.externalObjectType.length == 0)
      throw new DocMgmtIntegrationValidationException(
        "external_object_type is required");
    if (link.documentId.length == 0)
      throw new DocMgmtIntegrationValidationException(
        "document_id is required");

    // Verify the target document exists in this tenant
    ensureDocument(tenantId, link.documentId);

    auto saved = _store.addLink(link);

    Json r = Json.emptyObject;
    r["success"] = true;
    r["link"] = saved.toJson();
    return r;
  }

  Json getLink(UUID tenantId, string linkId) {
    ensureTenant(tenantId);
    validateId(linkId, "Link ID");
    auto link = _store.getLink(linkId);
    if (link.linkId.length == 0 || link.tenantId != tenantId)
      throw new DocMgmtIntegrationNotFoundException("IntegrationLink", linkId);

    Json r = Json.emptyObject;
    r["link"] = link.toJson();
    return r;
  }

  Json deleteLink(UUID tenantId, string linkId) {
    ensureTenant(tenantId);
    validateId(linkId, "Link ID");
    auto link = _store.getLink(linkId);
    if (link.linkId.length == 0 || link.tenantId != tenantId)
      throw new DocMgmtIntegrationNotFoundException("IntegrationLink", linkId);

    _store.removeLink(linkId);

    Json r = Json.emptyObject;
    r["success"] = true;
    r["message"] = "Integration link deleted";
    return r;
  }

  Json listLinks(UUID tenantId) {
    ensureTenant(tenantId);
    Json resources = Json.emptyArray;
    foreach (l; _store.listLinks(tenantId))
      resources ~= l.toJson();
    Json r = Json.emptyObject;
    r["resources"] = resources;
    r["total_results"] = cast(long)resources.length;
    return r;
  }

  Json listLinksByObject(UUID tenantId, string objectType, string objectId) {
    ensureTenant(tenantId);
    Json resources = Json.emptyArray;
    foreach (l; _store.listLinksByObject(tenantId, objectType, objectId))
      resources ~= l.toJson();
    Json r = Json.emptyObject;
    r["external_object_type"] = objectType;
    r["external_object_id"] = objectId;
    r["resources"] = resources;
    r["total_results"] = cast(long)resources.length;
    return r;
  }

  Json listLinksByDocument(UUID tenantId, string documentId) {
    ensureTenant(tenantId);
    ensureDocument(tenantId, documentId);
    Json resources = Json.emptyArray;
    foreach (l; _store.listLinksByDocument(tenantId, documentId))
      resources ~= l.toJson();
    Json r = Json.emptyObject;
    r["document_id"] = documentId;
    r["resources"] = resources;
    r["total_results"] = cast(long)resources.length;
    return r;
  }

  // ===================================================================
  // Private helpers
  // ===================================================================

  private void ensureTenant(UUID tenantId) {
    if (_config.multitenancyEnabled) {
      if (tenantId.length == 0)
        throw new DocMgmtIntegrationTenantRequiredException(
          "Tenant ID is required when multitenancy is enabled");
      auto tenant = _store.getTenant(tenantId);
      if (tenant.tenantId.length == 0)
        throw new DocMgmtIntegrationNotFoundException("Tenant", tenantId);
      if (!tenant.active)
        throw new DocMgmtIntegrationValidationException(
          "Tenant is deactivated: " ~ tenantId);
    }
  }

  private void ensureRepository(UUID tenantId, string repositoryId) {
    auto repo = _store.getRepository(repositoryId);
    if (repo.repositoryId.length == 0 || repo.tenantId != tenantId)
      throw new DocMgmtIntegrationNotFoundException("Repository", repositoryId);
  }

  private void ensureFolder(string folderId) {
    auto folder = _store.getFolder(folderId);
    if (folder.folderId.length == 0)
      throw new DocMgmtIntegrationNotFoundException("Folder", folderId);
  }

  private void ensureDocument(UUID tenantId, string documentId) {
    auto doc = _store.getDocument(documentId);
    if (doc.documentId.length == 0 || doc.tenantId != tenantId)
      throw new DocMgmtIntegrationNotFoundException("Document", documentId);
  }

  private void removeDocumentsInFolder(UUID tenantId, string repositoryId, string folderId) {
    foreach (d; _store.listDocuments(tenantId, repositoryId, folderId))
      _store.removeDocument(d.documentId);
  }

  private Json breadcrumbsJson(string folderId) {
    Json crumbs = Json.emptyArray;
    if (folderId.length > 0) {
      foreach (bc; _store.buildBreadcrumbs(folderId))
        crumbs ~= bc.toJson();
    }
    return crumbs;
  }

  private string viewerType(string fileName) {
    import std.string : endsWith;

    auto lower = toLower(fileName);
    if (lower.endsWith(".pdf"))
      return "pdf";
    if (lower.endsWith(".svg"))
      return "svg";
    if (lower.endsWith(".png") || lower.endsWith(".jpg") ||
      lower.endsWith(".jpeg") || lower.endsWith(".gif") ||
      lower.endsWith(".bmp") || lower.endsWith(".webp"))
      return "image";
    return "download";
  }
}
