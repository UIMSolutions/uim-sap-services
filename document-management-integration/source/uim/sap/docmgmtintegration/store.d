module uim.sap.docmgmtintegration.store;

import core.sync.mutex : Mutex;
import std.algorithm.searching : canFind;
import std.datetime : Clock;

import uim.sap.docmgmtintegration.models;
import uim.sap.docmgmtintegration.exceptions;

/**
 * Tenant-aware in-memory store for documents, folders, versions,
 * repositories, UI component configs, and integration links.
 *
 * All public methods are synchronized via a Mutex to allow safe concurrent
 * access from multiple vibe.d request handler fibers. Every query that
 * returns domain objects filters by tenant ID so that data belonging to
 * different tenants is never intermixed.
 */
class DocMgmtIntegrationStore : SAPStore {
    // Tenants
    private Tenant[string] _tenants;

    // Repositories keyed by repositoryId
    private Repository[string] _repositories;

    // Folders keyed by folderId
    private Folder[string] _folders;

    // Documents keyed by documentId
    private Document[string] _documents;

    // Versions keyed by documentId → list of versions
    private DocumentVersion[][string] _versions;

    // Document content (simulated binary storage) keyed by versionId
    private string[string] _contentStore;

    // UI component configs keyed by tenantId
    private UIComponentConfig[string] _uiConfigs;

    // Integration links keyed by linkId
    private IntegrationLink[string] _links;

    private Mutex _lock;

    this() {
        _lock = new Mutex;
    }

    // -----------------------------------------------------------------------
    // Tenants
    // -----------------------------------------------------------------------

    Tenant addTenant(Tenant tenant) {
        synchronized (_lock) {
            _tenants[tenant.tenantId] = tenant;
            return tenant;
        }
    }

    Tenant getTenant(string tenantId) {
        synchronized (_lock) {
            if (auto t = tenantId in _tenants)
                return *t;
        }
        return Tenant.init;
    }

    Tenant updateTenant(Tenant tenant) {
        synchronized (_lock) {
            tenant.modifiedAt = Clock.currTime();
            _tenants[tenant.tenantId] = tenant;
            return tenant;
        }
    }

    bool removeTenant(string tenantId) {
        synchronized (_lock) {
            if (tenantId in _tenants) {
                _tenants.remove(tenantId);
                return true;
            }
            return false;
        }
    }

    Tenant[] listTenants() {
        synchronized (_lock) {
            Tenant[] result;
            foreach (t; _tenants.byValue())
                result ~= t;
            return result;
        }
    }

    // -----------------------------------------------------------------------
    // Repositories (tenant-scoped)
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

    Repository[] listRepositories(string tenantId) {
        synchronized (_lock) {
            Repository[] result;
            foreach (r; _repositories.byValue()) {
                if (r.tenantId == tenantId)
                    result ~= r;
            }
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
    // Folders (tenant-scoped)
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

    Folder[] listFolders(string tenantId, string repositoryId, string parentFolderId) {
        synchronized (_lock) {
            Folder[] result;
            foreach (f; _folders.byValue()) {
                if (f.tenantId == tenantId &&
                    f.repositoryId == repositoryId &&
                    f.parentFolderId == parentFolderId)
                    result ~= f;
            }
            return result;
        }
    }

    /// List all child folder IDs recursively (within a tenant).
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
    // Documents (tenant-scoped)
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

    Document[] listDocuments(string tenantId, string repositoryId, string folderId) {
        synchronized (_lock) {
            Document[] result;
            foreach (d; _documents.byValue()) {
                if (d.tenantId == tenantId &&
                    d.repositoryId == repositoryId &&
                    d.folderId == folderId)
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
        return [];
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

    // -----------------------------------------------------------------------
    // UI Component Configs (tenant-scoped, single config per tenant)
    // -----------------------------------------------------------------------

    UIComponentConfig setUIConfig(UIComponentConfig cfg) {
        synchronized (_lock) {
            _uiConfigs[cfg.tenantId] = cfg;
            return cfg;
        }
    }

    UIComponentConfig getUIConfig(string tenantId) {
        synchronized (_lock) {
            if (auto c = tenantId in _uiConfigs)
                return *c;
        }
        return UIComponentConfig.init;
    }

    bool removeUIConfig(string tenantId) {
        synchronized (_lock) {
            if (tenantId in _uiConfigs) {
                _uiConfigs.remove(tenantId);
                return true;
            }
            return false;
        }
    }

    // -----------------------------------------------------------------------
    // Integration Links (tenant-scoped)
    // -----------------------------------------------------------------------

    IntegrationLink addLink(IntegrationLink link) {
        synchronized (_lock) {
            _links[link.linkId] = link;
            return link;
        }
    }

    IntegrationLink getLink(string linkId) {
        synchronized (_lock) {
            if (auto l = linkId in _links)
                return *l;
        }
        return IntegrationLink.init;
    }

    bool removeLink(string linkId) {
        synchronized (_lock) {
            if (linkId in _links) {
                _links.remove(linkId);
                return true;
            }
            return false;
        }
    }

    IntegrationLink[] listLinks(string tenantId) {
        synchronized (_lock) {
            IntegrationLink[] result;
            foreach (l; _links.byValue()) {
                if (l.tenantId == tenantId)
                    result ~= l;
            }
            return result;
        }
    }

    /// List links matching a specific external business object.
    IntegrationLink[] listLinksByObject(string tenantId, string externalObjectType, string externalObjectId) {
        synchronized (_lock) {
            IntegrationLink[] result;
            foreach (l; _links.byValue()) {
                if (l.tenantId == tenantId &&
                    l.externalObjectType == externalObjectType &&
                    l.externalObjectId == externalObjectId)
                    result ~= l;
            }
            return result;
        }
    }

    /// List links pointing to a specific document.
    IntegrationLink[] listLinksByDocument(string tenantId, string documentId) {
        synchronized (_lock) {
            IntegrationLink[] result;
            foreach (l; _links.byValue()) {
                if (l.tenantId == tenantId && l.documentId == documentId)
                    result ~= l;
            }
            return result;
        }
    }
}
