module uim.sap.dma.service;

import uim.sap.dma;

mixin(ShowModule!());

@safe:

/**
 * Core business logic for the Document Management Service.
 *
 * Provides operations for:
 *  - Repository management (connect CMIS-compliant repos)
 *  - Folder CRUD and hierarchy navigation (breadcrumbs)
 *  - Document CRUD, move, copy
 *  - Version management (create versions, check-out/check-in)
 *  - Metadata management (view/edit properties)
 *  - Document viewing and download
 *  - Encryption support for internal repositories
 */
class DMAService : SAPService {
  mixin(SAPServiceTemplate!DMAService);

  private DMAStore _store;
  private EncryptionManager _encryption;
  private RepositoryRegistry _registry;

  this(DMAConfig config) {
    super(config);

    _store = new DMAStore;
    _encryption = new EncryptionManager(config.encryptionEnabled, config.encryptionKey);
    _registry = new RepositoryRegistry;

    // Bootstrap the default internal repository
    auto internal = new InternalRepositoryConnector(
      _config.defaultRepository, _config.encryptionEnabled);
    _registry.register(internal);
    _store.addRepository(internal.info());
  }

  // ===================================================================
  // Platform
  // ===================================================================

  override Json health() {
    Json healthInfo = super.health();
    healthInfo["repositories_connected"] = cast(long)_registry.count();
    return healthInfo;
  }

  // ===================================================================
  // Repositories
  // ===================================================================

  Json listRepositories() {
    Json resources = _store.listRepositories().map!(repo => repo.toJson()).array.toJson();

    return Json.emptyObject
      .set("resources", resources)
      .set("total_results", cast(long)resources.length) ;
  }

  Json getRepository(string repositoryId) {
    validateId(repositoryId, "Repository ID");
    auto repo = _store.getRepository(repositoryId);
    if (repo.repositoryId.length == 0)
      throw new DMANotFoundException("Repository", repositoryId);
    
    return Json.emptyObject
      .set("repository", repo.toJson());
  }

  Json connectRepository(Json request) {
    auto repo = repositoryFromJson(request);
    if (repo.name.length == 0)
      throw new DMAValidationException("Repository name is required");

    auto connector = new ExternalCmisConnector(repo);
    if (!connector.ping())
      throw new DMAValidationException(
        "Cannot reach repository: " ~ repo.name);

    _registry.register(connector);
    auto saved = _store.addRepository(repo);

    return Json.emptyObject
      .set("success", true)
      .set("repository", saved.toJson());
  }

  Json disconnectRepository(string repositoryId) {
    validateId(repositoryId, "Repository ID");
    auto repo = _store.getRepository(repositoryId);
    if (repo.repositoryId.length == 0)
      throw new DMANotFoundException("Repository", repositoryId);

    _registry.remove(repositoryId);
    _store.removeRepository(repositoryId);

    return Json.emptyObject
      .set("success", true)
      .set("message", "Repository disconnected: " ~ repo.name);
  }

  // ===================================================================
  // Folders
  // ===================================================================

  Json createFolder(string repositoryId, string parentFolderId, Json request) {
    validateId(repositoryId, "Repository ID");
    ensureRepository(repositoryId);

    if (parentFolderId.length > 0)
      ensureFolder(parentFolderId);

    auto folder = folderFromJson(repositoryId, parentFolderId, request);
    if (folder.name.length == 0)
      throw new DMAValidationException("Folder name is required");

    auto saved = _store.addFolder(folder);

    return Json.emptyObject
      .set("success", true)
      .set("folder", saved.toJson());
  }

  Json getFolder(string folderId) {
    validateId(folderId, "Folder ID");
    auto folder = _store.getFolder(folderId);
    if (folder.folderId.length == 0)
      throw new DMANotFoundException("Folder", folderId);

    return Json.emptyObject
      .set("folder", folder.toJson())
      .set("breadcrumbs", breadcrumbsJson(folderId));
  }

  Json updateFolder(string folderId, Json request) {
    validateId(folderId, "Folder ID");
    auto folder = _store.getFolder(folderId);
    if (folder.folderId.length == 0)
      throw new DMANotFoundException("Folder", folderId);

    if ("name" in request && request["name"].isString)
      folder.name = request["name"].getString;
    if ("description" in request && request["description"].isString)
      folder.description = request["description"].getString;
    if ("properties" in request && request["properties"].isObject)
      folder.properties = request["properties"];

    auto saved = _store.updateFolder(folder);

    return Json.emptyObject
      .set("success", true)
      .set("folder", saved.toJson());
  }

  Json deleteFolder(string folderId) {
    validateId(folderId, "Folder ID");
    auto folder = _store.getFolder(folderId);
    if (folder.folderId.length == 0)
      throw new DMANotFoundException("Folder", folderId);

    // Remove all descendant folders and their documents
    auto descendants = _store.getDescendantFolderIds(folderId);
    foreach (childId; descendants) {
      removeDocumentsInFolder(folder.repositoryId, childId);
      _store.removeFolder(childId);
    }
    removeDocumentsInFolder(folder.repositoryId, folderId);
    _store.removeFolder(folderId);

    return Json.emptyObject
      .set("success", true)
      .set("message", "Folder deleted: " ~ folder.name);
  }

  Json listFolderContents(string repositoryId, string folderId) {
    validateId(repositoryId, "Repository ID");
    ensureRepository(repositoryId);

    // folderId may be empty for root-level listing
    Json folders = Json.emptyArray;
    foreach (f; _store.listFolders(repositoryId, folderId))
      folders ~= f.toJson();

    Json documents = Json.emptyArray;
    foreach (d; _store.listDocuments(repositoryId, folderId))
      documents ~= d.toJson();

    return Json.emptyObject
      .set("repository_id", repositoryId)
      .set("folder_id", folderId)
      .set("folders", folders)
      .set("documents", documents)
      .set("total_folders", cast(long)folders.length)
      .set("total_documents", cast(long)documents.length)
      .set("breadcrumbs", folderId.length > 0 ? breadcrumbsJson(folderId) : Json.null);
  }

  Json moveFolder(string folderId, Json request) {
    validateId(folderId, "Folder ID");
    auto folder = _store.getFolder(folderId);
    if (folder.folderId.length == 0)
      throw new DMANotFoundException("Folder", folderId);

    string targetParentId = "";
    if ("target_folder_id" in request && request["target_folder_id"].isString)
      targetParentId = request["target_folder_id"].getString;

    if (targetParentId.length > 0) {
      ensureFolder(targetParentId);
      // Prevent moving into own subtree
      auto descendants = _store.getDescendantFolderIds(folderId);
      import std.algorithm.searching : canFind;

      if (descendants.canFind(targetParentId))
        throw new DMAValidationException(
          "Cannot move a folder into its own subtree");
    }

    folder.parentFolderId = targetParentId;
    auto saved = _store.updateFolder(folder);

    return Json.emptyObject
      .set("success", true)
      .set("folder", saved.toJson());
  }

  Json copyFolder(string folderId, Json request) {
    validateId(folderId, "Folder ID");
    auto folder = _store.getFolder(folderId);
    if (folder.folderId.length == 0)
      throw new DMANotFoundException("Folder", folderId);

    string targetParentId = "";
    if ("target_folder_id" in request && request["target_folder_id"].isString)
      targetParentId = request["target_folder_id"].getString;
    if (targetParentId.length > 0)
      ensureFolder(targetParentId);

    // Create a copy of the folder
    Folder copy = folder;
    copy.folderId = randomUUID();
    copy.parentFolderId = targetParentId;
    copy.createdAt = Clock.currTime();
    copy.modifiedAt = copy.createdAt;
    auto saved = _store.addFolder(copy);

    // Also copy documents in the source folder
    foreach (doc; _store.listDocuments(folder.repositoryId, folderId)) {
      _store.copyDocument(doc.documentId, saved.folderId);
    }

    return Json.emptyObject
      .set("success", true)
      .set("folder", saved.toJson());
  }

  // ===================================================================
  // Documents
  // ===================================================================

  Json createDocument(string repositoryId, string folderId, Json request) {
    validateId(repositoryId, "Repository ID");
    ensureRepository(repositoryId);

    if (folderId.length > 0)
      ensureFolder(folderId);

    auto doc = documentFromJson(repositoryId, folderId, request);
    if (doc.name.length == 0)
      throw new DMAValidationException("Document name is required");

    // Handle encryption for internal repositories
    auto repo = _store.getRepository(repositoryId);
    if (repo.encryptionEnabled || _encryption.enabled) {
      doc.encrypted = true;
    }

    auto saved = _store.addDocument(doc);

    // Create initial version (v1)
    if (_config.versioningEnabled) {
      auto ver = versionFromJson(saved.documentId, 1, request);
      ver.sizeBytes = saved.sizeBytes;
      ver.mimeType = saved.mimeType;
      ver.createdBy = saved.createdBy;
      ver.isMajor = true;
      ver.versionLabel = "1.0";
      ver.encrypted = saved.encrypted;
      _store.addVersion(ver);

      // Store initial content if provided
      if ("content" in request && request["content"].isString) {
        auto content = request["content"].getString;
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

  Json getDocument(string documentId) {
    validateId(documentId, "Document ID");
    auto doc = _store.getDocument(documentId);
    if (doc.documentId.length == 0)
      throw new DMANotFoundException("Document", documentId);

    return Json.emptyObject
      .set("document", doc.toJson())
      .set("viewable", isViewableExtension(doc.name))
      .set("breadcrumbs", breadcrumbsJson(doc.folderId));
  }

  Json updateDocument(string documentId, Json request) {
    validateId(documentId, "Document ID");
    auto doc = _store.getDocument(documentId);
    if (doc.documentId.length == 0)
      throw new DMANotFoundException("Document", documentId);

    // Cannot edit if checked out by someone else
    if (doc.status == DocumentStatus.checkedOut) {
      string actor = "system";
      if ("modified_by" in request && request["modified_by"].isString)
        actor = request["modified_by"].getString;
      if (doc.checkedOutBy != actor)
        throw new DMAConflictException(
          "Document is checked out by " ~ doc.checkedOutBy);
    }

    if ("name" in request && request["name"].isString)
      doc.name = request["name"].getString;
    if ("description" in request && request["description"].isString)
      doc.description = request["description"].getString;
    if ("mime_type" in request && request["mime_type"].isString)
      doc.mimeType = request["mime_type"].getString;
    if ("modified_by" in request && request["modified_by"].isString)
      doc.modifiedBy = request["modified_by"].getString;

    auto saved = _store.updateDocument(doc);

    return Json.emptyObject
      .set("success", true)
      .set("document", saved.toJson());
  }

  Json deleteDocument(string documentId) {
    validateId(documentId, "Document ID");
    auto doc = _store.getDocument(documentId);
    if (doc.documentId.length == 0)
      throw new DMANotFoundException("Document", documentId);

    if (doc.status == DocumentStatus.checkedOut)
      throw new DMAConflictException(
        "Cannot delete a checked-out document. Check it in first.");

    _store.removeDocument(documentId);

    return Json.emptyObject
      .set("success", true)
      .set("message", "Document deleted: " ~ doc.name);
  }

  Json moveDocument(string documentId, Json request) {
    validateId(documentId, "Document ID");
    auto doc = _store.getDocument(documentId);
    if (doc.documentId.length == 0)
      throw new DMANotFoundException("Document", documentId);

    string targetFolderId = "";
    if ("target_folder_id" in request && request["target_folder_id"].isString)
      targetFolderId = request["target_folder_id"].getString;
    if (targetFolderId.length > 0)
      ensureFolder(targetFolderId);

    auto moved = _store.moveDocument(documentId, targetFolderId);

    return Json.emptyObject
      .set("success", true)
      .set("document", moved.toJson());
  }

  Json copyDocument(string documentId, Json request) {
    validateId(documentId, "Document ID");
    auto doc = _store.getDocument(documentId);
    if (doc.documentId.length == 0)
      throw new DMANotFoundException("Document", documentId);

    string targetFolderId = "";
    if ("target_folder_id" in request && request["target_folder_id"].isString)
      targetFolderId = request["target_folder_id"].getString;
    if (targetFolderId.length > 0)
      ensureFolder(targetFolderId);

    auto copied = _store.copyDocument(documentId, targetFolderId);

    return Json.emptyObject
      .set("success", true)
      .set("document", copied.toJson());
  }

  // ===================================================================
  // Document Viewing & Download
  // ===================================================================

  Json viewDocument(string documentId) {
    validateId(documentId, "Document ID");
    auto doc = _store.getDocument(documentId);
    if (doc.documentId.length == 0)
      throw new DMANotFoundException("Document", documentId);

    bool viewable = isViewableExtension(doc.name);

    Json r = Json.emptyObject
      .set("document_id", documentId)
      .set("name", doc.name)
      .set("mime_type", doc.mimeType)
      .set("size_bytes", doc.sizeBytes)
      .set("viewable", viewable)
      .set("viewer_type", viewable ? viewerType(doc.name) : "download");

    // Retrieve content if viewable
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
      r["download_url"] = "/api/docmgmt/v1/documents/" ~ documentId ~ "/download";
    }
    return r;
  }

  Json downloadDocument(string documentId) {
    validateId(documentId, "Document ID");
    auto doc = _store.getDocument(documentId);
    if (doc.documentId.length == 0)
      throw new DMANotFoundException("Document", documentId);

    string content = "";
    if (doc.latestVersionId.length > 0) {
      content = _store.getContent(doc.latestVersionId);
      if (content.length > 0 && doc.encrypted) {
        auto decrypted = _encryption.decrypt(content);
        import std.base64 : Base64;

        content = Base64.encode(decrypted);
      }
    }

    return Json.emptyObject
      .set("document_id", documentId)
      .set("name", doc.name)
      .set("mime_type", doc.mimeType)
      .set("size_bytes", doc.sizeBytes)
      .set("encrypted", doc.encrypted)
      .set("content", content);
  }

  // ===================================================================
  // Metadata Management
  // ===================================================================

  Json getDocumentMetadata(string documentId) {
    validateId(documentId, "Document ID");
    auto doc = _store.getDocument(documentId);
    if (doc.documentId.length == 0)
      throw new DMANotFoundException("Document", documentId);

    return Json.emptyObject
      .set("document_id", documentId)
      .set("name", doc.name)
      .set("description", doc.description)
      .set("mime_type", doc.mimeType)
      .set("size_bytes", doc.sizeBytes)
      .set("created_by", doc.createdBy)
      .set("modified_by", doc.modifiedBy)
      .set("created_at", doc.createdAt.toISOExtString())
      .set("modified_at", doc.modifiedAt.toISOExtString())
      .set("status", cast(string)doc.status)
      .set("encrypted", doc.encrypted)
      .set("current_version", doc.currentVersion)
      .set("properties", doc.properties);
  }

  Json updateDocumentMetadata(string documentId, Json request) {
    validateId(documentId, "Document ID");
    auto doc = _store.getDocument(documentId);
    if (doc.documentId.length == 0)
      throw new DMANotFoundException("Document", documentId);

    if ("properties" in request && request["properties"].isObject)
      doc.properties = request["properties"];
    if ("description" in request && request["description"].isString)
      doc.description = request["description"].getString;

    auto saved = _store.updateDocument(doc);

    return Json.emptyObject
      .set("success", true)
      .set("document_id", documentId)
      .set("properties", saved.properties)
      .set("description", saved.description);
  }

  Json getFolderProperties(string folderId) {
    validateId(folderId, "Folder ID");
    auto folder = _store.getFolder(folderId);
    if (folder.folderId.length == 0)
      throw new DMANotFoundException("Folder", folderId);

    Json r = Json.emptyObject;
    r["folder_id"] = folderId;
    r["name"] = folder.name;
    r["description"] = folder.description;
    r["created_by"] = folder.createdBy;
    r["created_at"] = folder.createdAt.toISOExtString();
    r["modified_at"] = folder.modifiedAt.toISOExtString();
    r["properties"] = folder.properties;
    return r;
  }

  Json updateFolderProperties(string folderId, Json request) {
    validateId(folderId, "Folder ID");
    auto folder = _store.getFolder(folderId);
    if (folder.folderId.length == 0)
      throw new DMANotFoundException("Folder", folderId);

    if ("properties" in request && request["properties"].isObject)
      folder.properties = request["properties"];
    if ("description" in request && request["description"].isString)
      folder.description = request["description"].getString;

    auto saved = _store.updateFolder(folder);

    return Json.emptyObject
      .set("success", true)
      .set("folder_id", folderId)
      .set("properties", saved.properties)
      .set("description", saved.description);
  }

  // ===================================================================
  // Versioning
  // ===================================================================

  Json listVersions(string documentId) {
    validateId(documentId, "Document ID");
    ensureDocument(documentId);

    Json resources = Json.emptyArray;
    foreach (v; _store.listVersions(documentId))
      resources ~= v.toJson();

    return Json.emptyObject
      .set("document_id", documentId)
      .set("resources", resources)
      .set("total_results", cast(long)resources.length);
  }

  Json createVersion(string documentId, Json request) {
    validateId(documentId, "Document ID");
    auto doc = _store.getDocument(documentId);
    if (doc.documentId.length == 0)
      throw new DMANotFoundException("Document", documentId);

    if (!_config.versioningEnabled)
      throw new DMAValidationException("Versioning is disabled");

    if (doc.status == DocumentStatus.checkedOut) {
      string actor = "system";
      if ("created_by" in request && request["created_by"].isString)
        actor = request["created_by"].getString;
      if (doc.checkedOutBy != actor)
        throw new DMAConflictException(
          "Document is checked out by " ~ doc.checkedOutBy);
    }

    int nextVer = _store.nextVersionNumber(documentId);
    auto ver = versionFromJson(documentId, nextVer, request);
    ver.encrypted = doc.encrypted;

    // Store content if provided
    if ("content" in request && request["content"].isString) {
      auto content = request["content"].getString;
      if (doc.encrypted) {
        import std.string : representation;

        content = _encryption.encrypt(cast(const(ubyte)[])content.representation);
      }
      _store.storeContent(ver.versionId, content);
    }

    auto savedVer = _store.addVersion(ver);

    // Update document version tracking
    doc.currentVersion = nextVer;
    doc.latestVersionId = savedVer.versionId;
    doc.modifiedAt = Clock.currTime();
    if ("size_bytes" in request && request["size_bytes"].isInteger)
      doc.sizeBytes = request["size_bytes"].get!long;
    _store.updateDocument(doc);

    return Json.emptyObject
      .set("success", true)
      .set("version", savedVer.toJson())
      .set("document", doc.toJson());
  }

  Json getVersion(string documentId, string versionId) {
    validateId(documentId, "Document ID");
    validateId(versionId, "Version ID");
    ensureDocument(documentId);

    auto ver = _store.getVersion(documentId, versionId);
    if (ver.versionId.length == 0)
      throw new DMANotFoundException("Version", versionId);

    return Json.emptyObject
      .set("version", ver.toJson());
  }

  // ===================================================================
  // Check-out / Check-in Workflow
  // ===================================================================

  Json checkOutDocument(string documentId, Json request) {
    validateId(documentId, "Document ID");
    auto doc = _store.getDocument(documentId);
    if (doc.documentId.length == 0)
      throw new DMANotFoundException("Document", documentId);

    if (doc.status == DocumentStatus.checkedOut)
      throw new DMAConflictException(
        "Document is already checked out by " ~ doc.checkedOutBy);

    string actor = "system";
    if ("user" in request && request["user"].isString)
      actor = request["user"].getString;

    doc.status = DocumentStatus.checkedOut;
    doc.checkedOutBy = actor;
    auto saved = _store.updateDocument(doc);

    return Json.emptyObject
      .set("success", true)
      .set("document", saved.toJson())
      .set("message", "Document checked out by " ~ actor);
  }

  Json checkInDocument(string documentId, Json request) {
    validateId(documentId, "Document ID");
    auto doc = _store.getDocument(documentId);
    if (doc.documentId.length == 0)
      throw new DMANotFoundException("Document", documentId);

    if (doc.status != DocumentStatus.checkedOut)
      throw new DMAConflictException(
        "Document is not currently checked out");

    string actor = "system";
    if ("user" in request && request["user"].isString)
      actor = request["user"].getString;
    if (doc.checkedOutBy != actor)
      throw new DMAConflictException(
        "Document was checked out by " ~ doc.checkedOutBy ~ ", not " ~ actor);

    doc.status = DocumentStatus.checkedIn;
    doc.checkedOutBy = "";

    // Optionally create a new version on check-in
    if (_config.versioningEnabled) {
      int nextVer = _store.nextVersionNumber(documentId);
      auto ver = versionFromJson(documentId, nextVer, request);
      ver.encrypted = doc.encrypted;
      ver.createdBy = actor;

      if ("content" in request && request["content"].isString) {
        auto content = request["content"].getString;
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

  Json cancelCheckOut(string documentId, Json request) {
    validateId(documentId, "Document ID");
    auto doc = _store.getDocument(documentId);
    if (doc.documentId.length == 0)
      throw new DMANotFoundException("Document", documentId);

    if (doc.status != DocumentStatus.checkedOut)
      throw new DMAConflictException(
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

  Json listDocumentsSorted(string repositoryId, string folderId, Json request) {
    validateId(repositoryId, "Repository ID");
    ensureRepository(repositoryId);

    auto docs = _store.listDocuments(repositoryId, folderId);

    string sortBy = "name";
    if ("sort_by" in request && request["sort_by"].isString)
      sortBy = toLower(request["sort_by"].get!string);

    bool descending = false;
    if ("descending" in request && request["descending"].isBoolean)
      descending = request["descending"].get!bool;

    // Sort documents
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
  // Private helpers
  // ===================================================================

  private void ensureRepository(string repositoryId) {
    auto repo = _store.getRepository(repositoryId);
    if (repo.repositoryId.length == 0)
      throw new DMANotFoundException("Repository", repositoryId);
  }

  private void ensureFolder(string folderId) {
    auto folder = _store.getFolder(folderId);
    if (folder.folderId.length == 0)
      throw new DMANotFoundException("Folder", folderId);
  }

  private void ensureDocument(string documentId) {
    auto doc = _store.getDocument(documentId);
    if (doc.documentId.length == 0)
      throw new DMANotFoundException("Document", documentId);
  }

  private void removeDocumentsInFolder(string repositoryId, string folderId) {
    foreach (d; _store.listDocuments(repositoryId, folderId))
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
