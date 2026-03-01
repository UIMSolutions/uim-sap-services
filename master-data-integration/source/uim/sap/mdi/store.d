module uim.sap.mdi.store;

import core.sync.mutex : Mutex;

import uim.sap.mdi.models;

class MDIStore : SAPStore {
    private MDIReplicationClient[string] _clients;
    private MDIFilter[string] _filters;
    private MDIExtension[string] _extensions;
    private MDIReplicationJob[string] _jobs;
    private Mutex _lock;

    this() {
        _lock = new Mutex;
    }

    MDIReplicationClient upsertClient(MDIReplicationClient client) {
        synchronized (_lock) {
            _clients[scopedKey(client.tenantId, "client", client.clientId)] = client;
            return client;
        }
    }

    MDIReplicationClient getClient(string tenantId, string clientId) {
        synchronized (_lock) {
            auto key = scopedKey(tenantId, "client", clientId);
            if (auto value = key in _clients) return *value;
        }
        return MDIReplicationClient.init;
    }

    MDIReplicationClient[] listClients(string tenantId) {
        MDIReplicationClient[] values;
        synchronized (_lock) {
            foreach (key, value; _clients) if (belongsTo(key, tenantId)) values ~= value;
        }
        return values;
    }

    MDIFilter upsertFilter(MDIFilter filter) {
        synchronized (_lock) {
            _filters[scopedKey(filter.tenantId, "filter", filter.filterId)] = filter;
            return filter;
        }
    }

    MDIFilter[] listFilters(string tenantId) {
        MDIFilter[] values;
        synchronized (_lock) {
            foreach (key, value; _filters) if (belongsTo(key, tenantId)) values ~= value;
        }
        return values;
    }

    MDIExtension upsertExtension(MDIExtension extension) {
        synchronized (_lock) {
            _extensions[scopedKey(extension.tenantId, "extension", extension.extensionId)] = extension;
            return extension;
        }
    }

    MDIExtension[] listExtensions(string tenantId) {
        MDIExtension[] values;
        synchronized (_lock) {
            foreach (key, value; _extensions) if (belongsTo(key, tenantId)) values ~= value;
        }
        return values;
    }

    MDIReplicationJob upsertJob(MDIReplicationJob job) {
        synchronized (_lock) {
            _jobs[scopedKey(job.tenantId, "job", job.jobId)] = job;
            return job;
        }
    }

    MDIReplicationJob[] listJobs(string tenantId) {
        MDIReplicationJob[] values;
        synchronized (_lock) {
            foreach (key, value; _jobs) if (belongsTo(key, tenantId)) values ~= value;
        }
        return values;
    }

    private string scopedKey(string tenantId, string scopePart, string id) {
        return tenantId ~ ":" ~ scopePart ~ ":" ~ id;
    }

    private bool belongsTo(string key, string tenantId) {
        return key.length > tenantId.length + 1 && key[0 .. tenantId.length] == tenantId && key[tenantId.length] == ':';
    }
}
