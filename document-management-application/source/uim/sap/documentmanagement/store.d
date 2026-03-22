module uim.sap.documentmanagement.store;

import core.sync.mutex : Mutex;
import std.algorithm.searching : canFind;
import std.datetime : Clock;

import uim.sap.documentmanagement.models;
import uim.sap.documentmanagement.exceptions;

/**
 * In-memory store for documents, folders, versions, and repositories.
 *
 * All public methods are synchronized via a Mutex to allow safe concurrent
 * access from multiple vibe.d request handler fibers.
 */
class DMAStore : SAPStore {
    // Repositories
    private Repository[string] _repositories;

    // Folders keyed by folderId
    private Folder[string] _folders;

    // Documents keyed by documentId
    private Document[string] _documents;

    // Versions keyed by documentId → list of versions
    private DocumentVersion[][string] _versions;

    // Document content (simulated binary storage) keyed by versionId
    private string[string] _contentStore;

    private Mutex _lock;

    this() {
        _lock = new Mutex;
    }

    // -----------------------------------------------------------------------
    // Repositories
    // -----------------------------------------------------------------------

    Repository addRepository(Repository repo) {
        synchronized (_lock) {
            _repositories[repo.repositoryId] = repo;
            return repo;
        }
    }

    Repository getRepository(string repositoryId) {
        synchronized (_lock) {
            if (auto r = repositoryId in _repositories)
                return *r;
        }
        return Repository.init;
    }

    Repository[] listRepositories() {
        synchronized (_lock) {
            Repository[] result;
            foreach (r; _repositories.byValue())
                result ~= r;
            return result;
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

    Folder addFolder(Folder folder) {
        synchronized (_lock) {
            _folders[folder.folderId] = folder;
            return folder;
        }
    }

    Folder getFolder(string folderId) {
        synchronized (_lock) {
            if (auto f = folderId in _folders)
                return *f;
        }
        return Folder.init;
    }

    Folder updateFolder(Folder folder) {
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

    Folder[] listFolders(string repositoryId, string parentFolderId) {
        synchronized (_lock) {
            Folder[] result;
            foreach (f; _folders.byValue()) {
                if (f.repositoryId == repositoryId && f.parentFolderId == parentFolderId)
                    result ~= f;
            }
            return result;
        }
    }

    /// List all child folder IDs recursively.
    string[] getDescendantFolderIds(string folderId) {
        synchronized (_lock) {
            string[] result;
            collectDescendants(folderId, result);
            return result;
        }
    }

    private void collectDescendants(string parentId, ref string[] result) {
        foreach (f; _folders.byValue()) {
            if (f.parentFolderId == parentId) {
                result ~= f.folderId;
                collectDescendants(f.folderId, result);
            }
        }
    }

    /// Build breadcrumb path from a folder up to the root.
    Breadcrumb[] buildBreadcrumbs(string folderId) {
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
            for (long i = cast(long) crumbs.length - 1; i >= 0; i--) {
                reversed ~= crumbs[cast(size_t) i];
            }
            return reversed;
        }
    }

    // -----------------------------------------------------------------------
    // Documents
    // -----------------------------------------------------------------------

    Document addDocument(Document doc) {
        synchronized (_lock) {
            _documents[doc.documentId] = doc;
            return doc;
        }
    }

    Document getDocument(string documentId) {
        synchronized (_lock) {
            if (auto d = documentId in _documents)
                return *d;
        }
        return Document.init;
    }

    Document updateDocument(Document doc) {
        synchronized (_lock) {
            doc.modifiedAt = Clock.currTime();
            _documents[doc.documentId] = doc;
            return doc;
        }
    }

    bool removeDocument(string documentId) {
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

    Document[] listDocuments(string repositoryId, string folderId) {
        synchronized (_lock) {
            Document[] result;
            foreach (d; _documents.byValue()) {
                if (d.repositoryId == repositoryId && d.folderId == folderId)
                    result ~= d;
            }
            return result;
        }
    }

    /// Move a document to a different folder.
    Document moveDocument(string documentId, string targetFolderId) {
        synchronized (_lock) {
            if (auto d = documentId in _documents) {
                d.folderId = targetFolderId;
                d.modifiedAt = Clock.currTime();
                return *d;
            }
        }
        return Document.init;
    }

    /// Copy a document to a different folder (creates a new document entry).
    Document copyDocument(string documentId, string targetFolderId) {
        synchronized (_lock) {
            if (auto d = documentId in _documents) {
                import std.uuid : randomUUID;
                Document copy = *d;
                copy.documentId = randomUUID().toString();
                copy.folderId = targetFolderId;
                copy.createdAt = Clock.currTime();
                copy.modifiedAt = copy.createdAt;
                copy.status = DocumentStatus.draft;
                copy.checkedOutBy = "";
                _documents[copy.documentId] = copy;
                return copy;
            }
        }
        return Document.init;
    }

    // -----------------------------------------------------------------------
    // Versions
    // -----------------------------------------------------------------------

    DocumentVersion addVersion(DocumentVersion ver) {
        synchronized (_lock) {
            _versions[ver.documentId] ~= ver;
            return ver;
        }
    }

    DocumentVersion[] listVersions(string documentId) {
        synchronized (_lock) {
            if (auto vers = documentId in _versions)
                return (*vers).dup;
        }
        return null;
    }

    DocumentVersion getVersion(string documentId, string versionId) {
        synchronized (_lock) {
            if (auto vers = documentId in _versions) {
                foreach (v; *vers) {
                    if (v.versionId == versionId)
                        return v;
                }
            }
        }
        return DocumentVersion.init;
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

    void storeContent(string versionId, string content) {
        synchronized (_lock) {
            _contentStore[versionId] = content;
        }
    }

    string getContent(string versionId) {
        synchronized (_lock) {
            if (auto c = versionId in _contentStore)
                return *c;
        }
        return "";
    }

    bool hasContent(string versionId) {
        synchronized (_lock) {
            return (versionId in _contentStore) !is null;
        }
    }
}
