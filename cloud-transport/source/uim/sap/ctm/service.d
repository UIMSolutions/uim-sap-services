module uim.sap.ctm.service;

import std.algorithm : canFind;
import std.array : array;
import std.conv : to;
import std.datetime : Clock, SysTime;
import std.string : toLower;

import vibe.data.json : Json;

import uim.sap.ctm.config;
import uim.sap.ctm.exceptions;
import uim.sap.ctm.models;
import uim.sap.ctm.store;

// ---------------------------------------------------------------------------
// CTMService – business logic for Cloud Transport Management
// ---------------------------------------------------------------------------
class CTMService : SAPService {
  mixin(SAPServiceTemplate!CTMService);

  private CTMStore _store;

  this(CTMConfig config) {
    super(config);

    _store = new CTMStore;
  }

  // -----------------------------------------------------------------------
  // Health / readiness
  // -----------------------------------------------------------------------
  Json health() const {
    Json healthInfo = super.health();
    healthInfo["runtime"] = _config.runtime;
    healthInfo["multitenancy"] = true;
    healthInfo["domain"] = "cloud-transport";
    return healthInfo;
  }

  // -----------------------------------------------------------------------
  // Dashboard HTML
  // -----------------------------------------------------------------------
  string dashboardHtml() const {
    return import("dashboard.html");
  }

  // -----------------------------------------------------------------------
  // NODES
  // -----------------------------------------------------------------------
  Json listNodes(UUID tenantId) {
    return _store.listNodes(tenantId).map!(n => n.toJson()).array.toJson;
  }

  Json createNode(UUID tenantId, Json payload) {
    CTMNode n;
    n.tenantId = tenantId;
    n.nodeId = "node_id" in payload ? payload["node_id"].get!string : createId();
    n.name = payload["name"].get!string;
    n.description = jstr(payload, "description");
    n.runtime = jstr(payload, "runtime", "cloud-foundry");
    n.globalAccountId = jstr(payload, "global_account_id");
    n.subaccountId = jstr(payload, "subaccount_id");
    n.destination = jstr(payload, "destination");
    n.autoImport = jbool(payload, "auto_import", false);
    n.importSchedule = jstr(payload, "import_schedule");
    n.active = jbool(payload, "active", true);
    n.createdAt = Clock.currTime();
    n.updatedAt = n.createdAt;
    return _store.upsertNode(n).toJson();
  }

  Json getNode(UUID tenantId, string nodeId) {
    CTMNode n;
    if (!_store.tryGetNode(tenantId, nodeId, n))
      throw new CTMNotFoundException("Node", nodeId);

    auto j = n.toJson();
    // Embed the import queue
    j["import_queue"] = _queueJson(tenantId, nodeId);
    // Embed outgoing routes
    Json routes = _store.routesFromNode(tenantId, nodeId).map!(r => r.toJson()).array.toJson;
    j["outgoing_routes"] = routes;
    return j;
  }

  // -----------------------------------------------------------------------
  // ROUTES
  // -----------------------------------------------------------------------
  Json listRoutes(UUID tenantId) {
    return _store.listRoutes(tenantId).map!(r => r.toJson()).array.toJson;
  }

  Json createRoute(UUID tenantId, Json payload) {
    auto srcId = payload["source_node_id"].get!string;
    auto tgtId = payload["target_node_id"].get!string;
    _requireNode(tenantId, srcId);
    _requireNode(tenantId, tgtId);
    if (srcId == tgtId)
      throw new CTMValidationException("Source and target must be different nodes");

    CTMRoute r;
    r.tenantId = tenantId;
    r.routeId = "route_id" in payload ? payload["route_id"].get!string : createId();
    r.sourceNodeId = srcId;
    r.targetNodeId = tgtId;
    r.description = jstr(payload, "description");
    r.active = jbool(payload, "active", true);
    r.createdAt = Clock.currTime();
    return _store.upsertRoute(r).toJson();
  }

  // -----------------------------------------------------------------------
  // TRANSPORT REQUESTS
  // -----------------------------------------------------------------------
  Json listRequests(UUID tenantId) {
    return _store.listRequests(tenantId).map!(r => r.toJson()).array.toJson;
  }

  /// Create a new transport request (can be triggered from CI/CD)
  Json createRequest(UUID tenantId, Json payload) {
    auto srcNodeId = payload["source_node_id"].get!string;
    _requireNode(tenantId, srcNodeId);

    CTMTransportRequest req;
    req.tenantId = tenantId;
    req.requestId = "request_id" in payload ? payload["request_id"].get!string : createId();
    req.description = jstr(payload, "description");
    req.sourceNodeId = srcNodeId;
    req.currentNodeId = srcNodeId;
    req.status = "initial";
    req.createdBy = jstr(payload, "created_by", "api");
    req.createdAt = Clock.currTime();
    req.updatedAt = req.createdAt;
    _store.upsertRequest(req);

    _appendLog(tenantId, req.requestId, srcNodeId, "created", "info",
      "Transport request created at node " ~ srcNodeId);
    return _requestDetail(tenantId, req.requestId);
  }

  Json getRequest(UUID tenantId, UUID requestId) {
    return _requestDetail(tenantId, requestId);
  }

  /// Forward a transport request along all active routes from its current node
  Json forwardRequest(UUID tenantId, UUID requestId) {
    CTMTransportRequest req;
    if (!_store.tryGetRequest(tenantId, requestId, req))
      throw new CTMNotFoundException("Transport request", requestId);

    auto routes = _store.routesFromNode(tenantId, req.currentNodeId);
    if (routes.length == 0)
      throw new CTMValidationException(
        "No active routes from node " ~ req.currentNodeId);

    // For every target, add the request to the target's import queue
    foreach (route; routes) {
      auto pos = _store.nextQueuePosition(tenantId, route.targetNodeId);
      CTMImportQueueEntry entry;
      entry.tenantId = tenantId;
      entry.nodeId = route.targetNodeId;
      entry.requestId = requestId;
      entry.position = pos;
      entry.status = "waiting";
      entry.queuedAt = Clock.currTime();
      _store.upsertQueueEntry(entry);

      _appendLog(tenantId, requestId, route.targetNodeId, "forwarded", "info",
        "Request forwarded to node " ~ route.targetNodeId
          ~ " via route " ~ route.routeId);
    }

    req.status = "queued";
    req.updatedAt = Clock.currTime();
    _store.upsertRequest(req);

    return _requestDetail(tenantId, requestId);
  }

  /// Reset a failed request so it can be re-imported
  Json resetRequest(UUID tenantId, UUID requestId) {
    CTMTransportRequest req;
    if (!_store.tryGetRequest(tenantId, requestId, req))
      throw new CTMNotFoundException("Transport request", requestId);
    if (req.status != "error")
      throw new CTMTransportStateException("Only requests in 'error' status can be reset");

    req.status = "queued";
    req.updatedAt = Clock.currTime();
    _store.upsertRequest(req);
    _appendLog(tenantId, requestId, req.currentNodeId, "reset", "info",
      "Transport request reset for re-import");
    return _requestDetail(tenantId, requestId);
  }

  // -----------------------------------------------------------------------
  // IMPORT QUEUE
  // -----------------------------------------------------------------------
  Json listQueue(UUID tenantId, string nodeId) {
    _requireNode(tenantId, nodeId);
    return _queueJson(tenantId, nodeId);
  }

  /// Import requests in a node's queue.  If requestIds is empty, import all.
  Json importQueue(UUID tenantId, string nodeId, Json payload) {
    _requireNode(tenantId, nodeId);

    // Gather which request IDs to import
    string[] selectedIds;
    if ("request_ids" in payload && payload["request_ids"].isArray)
      foreach (v; payload["request_ids"].toArray)
        selectedIds ~= v.get!string;

    auto queue = _store.listQueue(tenantId, nodeId);
    int imported = 0;
    foreach (ref entry; queue) {
      if (entry.status != "waiting")
        continue;
      if (selectedIds.length > 0 && !canFind(selectedIds, entry.requestId))
        continue;

      // Mark queue entry as importing → imported
      entry.status = "importing";
      _store.upsertQueueEntry(entry);
      _appendLog(tenantId, entry.requestId, nodeId, "import-started", "info",
        "Import started on node " ~ nodeId);

      // Simulate import success
      entry.status = "imported";
      entry.importedAt = Clock.currTime();
      _store.upsertQueueEntry(entry);

      // Update request: move current node forward
      CTMTransportRequest req;
      if (_store.tryGetRequest(tenantId, entry.requestId, req)) {
        req.currentNodeId = nodeId;
        req.status = "imported";
        req.updatedAt = Clock.currTime();
        _store.upsertRequest(req);
      }

      _appendLog(tenantId, entry.requestId, nodeId, "import-success", "info",
        "Import completed on node " ~ nodeId);
      imported++;
    }

    Json result = Json.emptyObject;
    result["node_id"] = nodeId;
    result["imported_count"] = imported;
    result["queue"] = _queueJson(tenantId, nodeId);
    return result;
  }

  /// Set an import schedule on a node
  Json setImportSchedule(UUID tenantId, string nodeId, Json payload) {
    CTMNode n;
    if (!_store.tryGetNode(tenantId, nodeId, n))
      throw new CTMNotFoundException("Node", nodeId);

    n.autoImport = jbool(payload, "auto_import", true);
    n.importSchedule = jstr(payload, "schedule", "");
    n.updatedAt = Clock.currTime();
    _store.upsertNode(n);

    _appendLog(tenantId, "", nodeId, "scheduled", "info",
      "Import schedule set: auto=" ~ (n.autoImport ? "true" : "false")
        ~ " schedule=" ~ n.importSchedule);
    return n.toJson();
  }

  // -----------------------------------------------------------------------
  // CONTENT
  // -----------------------------------------------------------------------
  Json listContent(UUID tenantId, UUID requestId) {
    _requireRequest(tenantId, requestId);
    Json arr = Json.emptyArray;
    foreach (c; _store.listContent(requestId))
      arr ~= c.toJson();
    return arr;
  }

  Json attachContent(UUID tenantId, UUID requestId, Json payload) {
    _requireRequest(tenantId, requestId);
    CTMContentItem ci;
    ci.contentId = "content_id" in payload ? payload["content_id"].get!string : createId();
    ci.requestId = requestId;
    ci.contentType = jstr(payload, "content_type", "mta");
    ci.name = payload["name"].get!string;
    ci.version = jstr(payload, "version", "1.0.0");
    ci.description = jstr(payload, "description");
    ci.reference = jstr(payload, "reference");
    ci.attachedAt = Clock.currTime();
    _store.upsertContent(ci);

    _appendLog(tenantId, requestId, "", "content-attached", "info",
      "Content attached: " ~ ci.name ~ " (" ~ ci.contentType ~ ")");
    return ci.toJson();
  }

  // -----------------------------------------------------------------------
  // LOGS (monitoring)
  // -----------------------------------------------------------------------
  Json listLogs(UUID tenantId, UUID requestId) {
    _requireRequest(tenantId, requestId);
    Json arr = Json.emptyArray;
    foreach (l; _store.listLogs(tenantId, requestId))
      arr ~= l.toJson();
    return arr;
  }

  // -----------------------------------------------------------------------
  // Private helpers
  // -----------------------------------------------------------------------
  private CTMNode _requireNode(UUID tenantId, string nodeId) {
    CTMNode n;
    if (!_store.tryGetNode(tenantId, nodeId, n))
      throw new CTMNotFoundException("Node", nodeId);
    return n;
  }

  private CTMTransportRequest _requireRequest(UUID tenantId, UUID requestId) {
    CTMTransportRequest req;
    if (!_store.tryGetRequest(tenantId, requestId, req))
      throw new CTMNotFoundException("Transport request", requestId);
    return req;
  }

  private Json _requestDetail(UUID tenantId, UUID requestId) {
    CTMTransportRequest req;
    if (!_store.tryGetRequest(tenantId, requestId, req))
      throw new CTMNotFoundException("Transport request", requestId);
    auto j = req.toJson();
    // Attach content list
    Json content = Json.emptyArray;
    foreach (c; _store.listContent(requestId))
      content ~= c.toJson();
    j["content"] = content;
    return j;
  }

  private Json _queueJson(UUID tenantId, string nodeId) {
    Json arr = Json.emptyArray;
    foreach (e; _store.listQueue(tenantId, nodeId))
      arr ~= e.toJson();
    return arr;
  }

  private void _appendLog(UUID tenantId, UUID requestId, string nodeId,
    string action, string level, string message) {
    CTMTransportLog log;
    log.tenantId = tenantId;
    log.logId = _store.nextId("log");
    log.requestId = requestId;
    log.nodeId = nodeId;
    log.action = action;
    log.message = message;
    log.level = level;
    log.timestamp = Clock.currTime();
    _store.upsertLog(log);
  }

  // -----------------------------------------------------------------------
  // JSON helpers
  // -----------------------------------------------------------------------
  private static string jstr(Json j, string key, string fallback = "") {
    if (key in j && j[key].isString)
      return j[key].get!string;
    return fallback;
  }

  private static bool jbool(Json j, string key, bool fallback = false) {
    if (key in j) {
      auto v = j[key];
      if (v.isBoolean)
        return v.get!bool;
      if (v.type == Json.Type.true_)
        return true;
      if (v.type == Json.Type.false_)
        return false;
    }
    return fallback;
  }
}
