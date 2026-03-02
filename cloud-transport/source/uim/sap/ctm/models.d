module uim.sap.ctm.models;

import std.datetime : Clock, SysTime;
import std.uuid     : randomUUID;

import vibe.data.json : Json;

string createId() {
    return randomUUID().toString();
}

// ---------------------------------------------------------------------------
// CTMNode – a logical environment in the transport landscape
// ---------------------------------------------------------------------------
struct CTMNode {
    string tenantId;
    string nodeId;
    string name;
    string description;
    /// Runtime: "cloud-foundry" | "abap" | "neo"
    string runtime;
    /// Global account / subaccount identifiers
    string globalAccountId;
    string subaccountId;
    /// Destination name for deployment (optional)
    string destination;
    /// Whether requests to this node are imported automatically
    bool   autoImport;
    /// Cron expression for scheduled imports (empty = disabled)
    string importSchedule;
    bool   active;
    SysTime createdAt;
    SysTime updatedAt;

    Json toJson() const {
        Json j = Json.emptyObject;
        j["tenant_id"]         = tenantId;
        j["node_id"]           = nodeId;
        j["name"]              = name;
        j["description"]       = description;
        j["runtime"]           = runtime;
        j["global_account_id"] = globalAccountId;
        j["subaccount_id"]     = subaccountId;
        j["destination"]       = destination;
        j["auto_import"]       = autoImport;
        j["import_schedule"]   = importSchedule;
        j["active"]            = active;
        j["created_at"]        = createdAt.toISOExtString();
        j["updated_at"]        = updatedAt.toISOExtString();
        return j;
    }
}

// ---------------------------------------------------------------------------
// CTMRoute – a directional connection between two nodes
// ---------------------------------------------------------------------------
struct CTMRoute {
    string tenantId;
    string routeId;
    string sourceNodeId;
    string targetNodeId;
    string description;
    bool   active;
    SysTime createdAt;

    Json toJson() const {
        Json j = Json.emptyObject;
        j["tenant_id"]      = tenantId;
        j["route_id"]       = routeId;
        j["source_node_id"] = sourceNodeId;
        j["target_node_id"] = targetNodeId;
        j["description"]    = description;
        j["active"]         = active;
        j["created_at"]     = createdAt.toISOExtString();
        return j;
    }
}

// ---------------------------------------------------------------------------
// CTMContentItem – a content attachment on a transport request
// ---------------------------------------------------------------------------
struct CTMContentItem {
    string contentId;
    string requestId;
    /// Type: "mta" | "iflow" | "abap-transport" | "destination-config" | "role" | "other"
    string contentType;
    string name;
    string version;
    string description;
    /// Opaque reference (file path, archive URL, etc.)
    string reference;
    SysTime attachedAt;

    Json toJson() const {
        Json j = Json.emptyObject;
        j["content_id"]   = contentId;
        j["request_id"]   = requestId;
        j["content_type"] = contentType;
        j["name"]         = name;
        j["version"]      = version;
        j["description"]  = description;
        j["reference"]    = reference;
        j["attached_at"]  = attachedAt.toISOExtString();
        return j;
    }
}

// ---------------------------------------------------------------------------
// CTMTransportRequest – a transport request moving through the landscape
// ---------------------------------------------------------------------------
struct CTMTransportRequest {
    string tenantId;
    string requestId;
    string description;
    /// Owning (source) node
    string sourceNodeId;
    /// Current location node (changes when forwarded)
    string currentNodeId;
    /// Status: "initial" | "queued" | "importing" | "imported" | "error" | "reset"
    string status;
    /// User / pipeline that created the request
    string createdBy;
    SysTime createdAt;
    SysTime updatedAt;

    Json toJson() const {
        Json j = Json.emptyObject;
        j["tenant_id"]       = tenantId;
        j["request_id"]      = requestId;
        j["description"]     = description;
        j["source_node_id"]  = sourceNodeId;
        j["current_node_id"] = currentNodeId;
        j["status"]          = status;
        j["created_by"]      = createdBy;
        j["created_at"]      = createdAt.toISOExtString();
        j["updated_at"]      = updatedAt.toISOExtString();
        return j;
    }
}

// ---------------------------------------------------------------------------
// CTMImportQueueEntry – an entry in a node's import queue
// ---------------------------------------------------------------------------
struct CTMImportQueueEntry {
    string tenantId;
    string nodeId;
    string requestId;
    /// Position in the queue (lower = earlier)
    int    position;
    /// Status: "waiting" | "importing" | "imported" | "error"
    string status;
    SysTime queuedAt;
    SysTime importedAt;

    Json toJson() const {
        Json j = Json.emptyObject;
        j["tenant_id"]   = tenantId;
        j["node_id"]     = nodeId;
        j["request_id"]  = requestId;
        j["position"]    = position;
        j["status"]      = status;
        j["queued_at"]   = queuedAt.toISOExtString();
        j["imported_at"] = importedAt.toISOExtString();
        return j;
    }
}

// ---------------------------------------------------------------------------
// CTMTransportLog – an audit/monitoring log entry
// ---------------------------------------------------------------------------
struct CTMTransportLog {
    string tenantId;
    string logId;
    string requestId;
    string nodeId;
    string action;     // e.g. "created", "forwarded", "queued", "import-started",
                       //      "import-success", "import-error", "reset", "scheduled"
    string message;
    /// Level: "info" | "warning" | "error"
    string level;
    SysTime timestamp;

    Json toJson() const {
        Json j = Json.emptyObject;
        j["tenant_id"]  = tenantId;
        j["log_id"]     = logId;
        j["request_id"] = requestId;
        j["node_id"]    = nodeId;
        j["action"]     = action;
        j["message"]    = message;
        j["level"]      = level;
        j["timestamp"]  = timestamp.toISOExtString();
        return j;
    }
}
