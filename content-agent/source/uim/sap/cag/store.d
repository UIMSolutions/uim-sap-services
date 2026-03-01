module uim.sap.cag.store;

import std.array : array;
import std.conv : to;
import std.string : startsWith;

import uim.sap.cag.models;

class CAGStore : SAPStore {
    private CAGContentProvider[string] _providers;
    private CAGContentItem[string] _content;
    private CAGAssembly[string] _assemblies;
    private CAGTransportQueue[string] _queues;
    private CAGTransportActivity[string] _activities;
    private long _counter = 0;

    string nextId(string prefix) {
        _counter += 1;
        return prefix ~ "-" ~ to!string(_counter);
    }

    CAGContentProvider upsertProvider(CAGContentProvider item) {
        _providers[key(item.tenantId, item.providerId)] = item;
        return item;
    }

    CAGContentItem upsertContent(CAGContentItem item) {
        _content[key(item.tenantId, item.contentId)] = item;
        return item;
    }

    CAGAssembly upsertAssembly(CAGAssembly item) {
        _assemblies[key(item.tenantId, item.assemblyId)] = item;
        return item;
    }

    CAGTransportQueue upsertQueue(CAGTransportQueue item) {
        _queues[key(item.tenantId, item.queueId)] = item;
        return item;
    }

    CAGTransportActivity upsertActivity(CAGTransportActivity item) {
        _activities[key(item.tenantId, item.activityId)] = item;
        return item;
    }

    CAGContentProvider[] listProviders(string tenantId) {
        CAGContentProvider[] items;
        auto prefix = tenantPrefix(tenantId);
        foreach (k, v; _providers) if (k.startsWith(prefix)) items ~= v;
        return items.array;
    }

    CAGContentItem[] listContent(string tenantId) {
        CAGContentItem[] items;
        auto prefix = tenantPrefix(tenantId);
        foreach (k, v; _content) if (k.startsWith(prefix)) items ~= v;
        return items.array;
    }

    CAGAssembly[] listAssemblies(string tenantId) {
        CAGAssembly[] items;
        auto prefix = tenantPrefix(tenantId);
        foreach (k, v; _assemblies) if (k.startsWith(prefix)) items ~= v;
        return items.array;
    }

    CAGTransportQueue[] listQueues(string tenantId) {
        CAGTransportQueue[] items;
        auto prefix = tenantPrefix(tenantId);
        foreach (k, v; _queues) if (k.startsWith(prefix)) items ~= v;
        return items.array;
    }

    CAGTransportActivity[] listActivities(string tenantId) {
        CAGTransportActivity[] items;
        auto prefix = tenantPrefix(tenantId);
        foreach (k, v; _activities) if (k.startsWith(prefix)) items ~= v;
        return items.array;
    }

    bool tryGetProvider(string tenantId, string providerId, out CAGContentProvider provider) {
        auto k = key(tenantId, providerId);
        if (k in _providers) {
            provider = _providers[k];
            return true;
        }
        return false;
    }

    bool tryGetContent(string tenantId, string contentId, out CAGContentItem item) {
        auto k = key(tenantId, contentId);
        if (k in _content) {
            item = _content[k];
            return true;
        }
        return false;
    }

    bool tryGetAssembly(string tenantId, string assemblyId, out CAGAssembly item) {
        auto k = key(tenantId, assemblyId);
        if (k in _assemblies) {
            item = _assemblies[k];
            return true;
        }
        return false;
    }

    bool tryGetQueue(string tenantId, string queueId, out CAGTransportQueue item) {
        auto k = key(tenantId, queueId);
        if (k in _queues) {
            item = _queues[k];
            return true;
        }
        return false;
    }

    private string key(string tenantId, string id) const {
        return tenantId ~ ":" ~ id;
    }

    private string tenantPrefix(string tenantId) const {
        return tenantId ~ ":";
    }
}
