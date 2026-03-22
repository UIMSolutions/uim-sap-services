module uim.sap.ctm.store;

import std.algorithm : sort;
import std.array     : array;
import std.conv      : to;
import std.string    : startsWith;

import uim.sap.ctm.models;

// ---------------------------------------------------------------------------
// CTMStore – thread-safe in-memory store for all transport entities
// ---------------------------------------------------------------------------
class CTMStore : SAPStore {
    private CTMNode[string]             _nodes;
    private CTMRoute[string]            _routes;
    private CTMTransportRequest[string] _requests;
    private CTMContentItem[string]      _content;
    private CTMImportQueueEntry[string] _queue;     // key: tenantId::nodeId::requestId
    private CTMTransportLog[string]     _logs;
    private long _counter = 0;

    // -----------------------------------------------------------------------
    // ID generation
    // -----------------------------------------------------------------------
    string nextId(string prefix) {
        _counter += 1;
        return prefix ~ "-" ~ to!string(_counter);
    }

    // -----------------------------------------------------------------------
    // Key helpers
    // -----------------------------------------------------------------------
    private static string tp(UUID tenantId) {
        return tenantId ~ "::";
    }

    private static string key(UUID tenantId, string id) {
        return tenantId ~ "::" ~ id;
    }

    private static string key3(UUID tenantId, string a, string b) {
        return tenantId ~ "::" ~ a ~ "::" ~ b;
    }

    // -----------------------------------------------------------------------
    // Nodes
    // -----------------------------------------------------------------------
    CTMNode upsertNode(CTMNode item) {
        _nodes[key(item.tenantId, item.nodeId)] = item;
        return item;
    }

    CTMNode[] listNodes(UUID tenantId) {
        CTMNode[] items;
        auto prefix = tp(tenantId);
        foreach (k, v; _nodes) if (k.startsWith(prefix)) items ~= v;
        return items;
    }

    bool tryGetNode(UUID tenantId, string nodeId, out CTMNode node) {
        auto k = key(tenantId, nodeId);
        if (k in _nodes) { node = _nodes[k]; return true; }
        return false;
    }

    // -----------------------------------------------------------------------
    // Routes
    // -----------------------------------------------------------------------
    CTMRoute upsertRoute(CTMRoute item) {
        _routes[key(item.tenantId, item.routeId)] = item;
        return item;
    }

    CTMRoute[] listRoutes(UUID tenantId) {
        CTMRoute[] items;
        auto prefix = tp(tenantId);
        foreach (k, v; _routes) if (k.startsWith(prefix)) items ~= v;
        return items;
    }

    /// Find all active routes whose sourceNodeId matches
    CTMRoute[] routesFromNode(UUID tenantId, string sourceNodeId) {
        CTMRoute[] items;
        auto prefix = tp(tenantId);
        foreach (k, v; _routes)
            if (k.startsWith(prefix) && v.sourceNodeId == sourceNodeId && v.active)
                items ~= v;
        return items;
    }

    // -----------------------------------------------------------------------
    // Transport Requests
    // -----------------------------------------------------------------------
    CTMTransportRequest upsertRequest(CTMTransportRequest item) {
        _requests[key(item.tenantId, item.requestId)] = item;
        return item;
    }

    CTMTransportRequest[] listRequests(UUID tenantId) {
        CTMTransportRequest[] items;
        auto prefix = tp(tenantId);
        foreach (k, v; _requests) if (k.startsWith(prefix)) items ~= v;
        return items;
    }

    bool tryGetRequest(UUID tenantId, UUID requestId, out CTMTransportRequest req) {
        auto k = key(tenantId, requestId);
        if (k in _requests) { req = _requests[k]; return true; }
        return false;
    }

    // -----------------------------------------------------------------------
    // Content Items
    // -----------------------------------------------------------------------
    CTMContentItem upsertContent(CTMContentItem item) {
        _content[item.contentId] = item;
        return item;
    }

    CTMContentItem[] listContent(UUID requestId) {
        CTMContentItem[] items;
        foreach (v; _content) if (v.requestId == requestId) items ~= v;
        return items;
    }

    // -----------------------------------------------------------------------
    // Import Queue
    // -----------------------------------------------------------------------
    CTMImportQueueEntry upsertQueueEntry(CTMImportQueueEntry item) {
        _queue[key3(item.tenantId, item.nodeId, item.requestId)] = item;
        return item;
    }

    CTMImportQueueEntry[] listQueue(UUID tenantId, string nodeId) {
        CTMImportQueueEntry[] items;
        auto prefix = key(tenantId, nodeId) ~ "::";
        foreach (k, v; _queue) if (k.startsWith(prefix)) items ~= v;
        items.sort!((a, b) => a.position < b.position);
        return items.array;
    }

    bool tryGetQueueEntry(UUID tenantId, string nodeId, UUID requestId,
                          out CTMImportQueueEntry entry) {
        auto k = key3(tenantId, nodeId, requestId);
        if (k in _queue) { entry = _queue[k]; return true; }
        return false;
    }

    int nextQueuePosition(UUID tenantId, string nodeId) {
        int maxPos = 0;
        auto prefix = key(tenantId, nodeId) ~ "::";
        foreach (k, v; _queue)
            if (k.startsWith(prefix) && v.position > maxPos) maxPos = v.position;
        return maxPos + 1;
    }

    // -----------------------------------------------------------------------
    // Logs
    // -----------------------------------------------------------------------
    CTMTransportLog upsertLog(CTMTransportLog item) {
        _logs[key(item.tenantId, item.logId)] = item;
        return item;
    }

    CTMTransportLog[] listLogs(UUID tenantId, UUID requestId) {
        CTMTransportLog[] items;
        auto prefix = tp(tenantId);
        foreach (k, v; _logs)
            if (k.startsWith(prefix) && v.requestId == requestId)
                items ~= v;
        items.sort!((a, b) => a.timestamp < b.timestamp);
        return items.array;
    }
}
