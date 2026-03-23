module uim.sap.documentmanagement.store;

import uim.sap.documentmanagement;

mixin(ShowModule!());

@safe:

/**
 * In-memory store for documents, folders, versions, and repositories.
 *
 * All public methods are synchronized via a Mutex to allow safe concurrent
 * access from multiple vibe.d request handler fibers.
 */
class DMAStore : SAPStore {
  // Repositories
  private DMARepository[string] _repositories;

  // Folders keyed by folderId
  private DMAFolder[string] _folders;

  // Documents keyed by documentId
  private DMADocument[string] _documents;

  // Versions keyed by documentId → list of versions
  private DMADocumentVersion[][string] _versions;

  // Document content (simulated binary storage) keyed by versionId
  private string[string] _contentStore;

  private Mutex _lock;

  this() {
    _lock = new Mutex;
  }

  // -----------------------------------------------------------------------
  // Repositories
  // -----------------------------------------------------------------------

  DMARepository addRepository(DMARepository repo) {
    synchronized (_lock) {
      _repositories[repo.repositoryId] = repo;
      return repo;
    }
  }

  DMARepository getRepository(string repositoryId) {
    synchronized (_lock) {
      return _repositories.get(repositoryId, null);
    }
    return null;
  }

  DMARepository[] listRepositories() {
    synchronized (_lock) {
      return _repositories.byValue().map!(repo => cast(DMARepository)repo).array;
    }
  }

  bool removeRepository(string repositoryId) {
    synchronized (_lock) {
      if (repositoryId in _repositories) {
        _repositories.remove(repositoryId);
        return true;
      }
      return false;
    }
  }

  // -----------------------------------------------------------------------
  // Folders
  // -----------------------------------------------------------------------

  DMAFolder addFolder(DMAFolder folder) {
    synchronized (_lock) {
      _folders[folder.folderId] = folder;
      return folder;
    }
  }

  DMAFolder getFolder(string folderId) {
    synchronized (_lock) {
      if (auto f = folderId in _folders)
        return *f;
    }
    return DMAFolder.init;
  }

  DMAFolder updateFolder(DMAFolder folder) {
    synchronized (_lock) {
      folder.modifiedAt = Clock.currTime();
      _folders[folder.folderId] = folder;
      return folder;
    }
  }

  bool removeFolder(string folderId) {
    synchronized (_lock) {
      if (folderId in _folders) {
        _folders.remove(folderId);
        return true;
      }
      return false;
    }
  }

  DMAFolder[] listFolders(UUID repositoryId, UUID parentFolderId) {
    synchronized (_lock) {
      return _folders.byValue()
        .filter!(f => f.repositoryId == repositoryId && f.parentFolderId == parentFolderId)
        .array;
    }
  }

  /// List all child folder IDs recursively.
  string[] getDescendantFolderIds(UUID folderId) {
    synchronized (_lock) {
      string[] result;
      collectDescendants(folderId, result);
      return result;
    }
  }

  private void collectDescendants(UUID parentId, ref string[] result) {
    foreach (f; _folders.byValue()) {
      if (f.parentFolderId == parentId) {
        result ~= f.folderId;
        collectDescendants(f.folderId, result);
      }
    }
  }

  /// Build breadcrumb path from a folder up to the root.
  Breadcrumb[] buildBreadcrumbs(UUID folderId) {
    synchronized (_lock) {
      Breadcrumb[] crumbs;
      string current = folderId;
      while (current.length > 0) {
        if (auto f = current in _folders) {
          Breadcrumb bc;
          bc.folderId = f.folderId;
          bc.name = f.name;
          crumbs ~= bc;
          current = f.parentFolderId;
        } else {
          break;
        }
      }
      // Reverse to get root-first order
      Breadcrumb[] reversed;
      for (long i = cast(long)crumbs.length - 1; i >= 0; i--) {
        reversed ~= crumbs[cast(size_t)i];
      }
      return reversed;
    }
  }

  // -----------------------------------------------------------------------
  // Documents
  // -----------------------------------------------------------------------

  DMADocument addDocument(DMADocument doc) {
    synchronized (_lock) {
      _documents[doc.documentId] = doc;
      return doc;
    }
  }

  DMADocument getDocument(UUID documentId) {
    synchronized (_lock) {
      return _documents.get(documentId, null);
    }
    return null;
  }

  DMADocument updateDocument(DMADocument doc) {
    synchronized (_lock) {
      doc.modifiedAt = Clock.currTime();
      _documents[doc.documentId] = doc;
      return doc;
    }
  }

  bool removeDocument(UUID documentId) {
    synchronized (_lock) {
      if (documentId in _documents) {
        _documents.remove(documentId);
        // Also remove all versions and content
        if (auto vers = documentId in _versions) {
          foreach (v; *vers) {
            _contentStore.remove(v.versionId);
          }
          _versions.remove(documentId);
        }
        return true;
      }
      return false;
    }
  }

  DMADocument[] listDocuments(UUID repositoryId, UUID folderId) {
    synchronized (_lock) {
      return _documents.byValue().filter!(d => d.repositoryId == repositoryId && d.folderId == folderId).array;
    }
  }

  /// Move a document to a different folder.
  DMADocument moveDocument(UUID documentId, UUID targetFolderId) {
    synchronized (_lock) {
      if (documentId in _documents) {
        auto d = _documents[documentId];
        d.folderId = targetFolderId;
        d.modifiedAt = Clock.currTime();
        return *d;
      }
    }
    return null;
  }

  /// Copy a document to a different folder (creates a new document entry).
  DMADocument copyDocument(UUID documentId, UUID targetFolderId) {
    synchronized (_lock) {
      if (auto d = documentId in _documents) {
        import std.uuid : randomUUID;

        DMADocument copy = *d;
        copy.documentId = randomUUID();
        copy.folderId = targetFolderId;
        copy.createdAt = Clock.currTime();
        copy.modifiedAt = copy.createdAt;
        copy.status = DocumentStatus.draft;
        copy.checkedOutBy = "";
        _documents[copy.documentId] = copy;
        return copy;
      }
    }
    return DMADocument.init;
  }

  // -----------------------------------------------------------------------
  // Versions
  // -----------------------------------------------------------------------

  DMADocumentVersion addVersion(DMADocumentVersion ver) {
    synchronized (_lock) {
      _versions[ver.documentId] ~= ver;
      return ver;
    }
  }

  DMADocumentVersion[] listVersions(string documentId) {
    synchronized (_lock) {
      if (auto vers = documentId in _versions)
        return (*vers).dup;
    }
    return null;
  }

  DMADocumentVersion getVersion(string documentId, string versionId) {
    synchronized (_lock) {
      if (auto vers = documentId in _versions) {
        foreach (v; *vers) {
          if (v.versionId == versionId)
            return v;
        }
      }
    }
    return null;
  }

  int nextVersionNumber(string documentId) {
    synchronized (_lock) {
      if (auto vers = documentId in _versions)
        return cast(int)((*vers).length) + 1;
    }
    return 1;
  }

  // -----------------------------------------------------------------------
  // Content storage (simulated)
  // -----------------------------------------------------------------------

  void storeContent(UUID versionId, string content) {
    synchronized (_lock) {
      _contentStore[versionId.toString()] = content;
    }
  }

  string getContent(UUID versionId) {
    synchronized (_lock) {
      return _contentStore.get(versionId.toString(), null);)
    }
    return "";
  }

  bool hasContent(UUID versionId) {
    synchronized (_lock) {
      return (versionId.toString() in _contentStore) ? true : false;
    }
  }
}
