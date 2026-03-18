module uim.sap.ctm.models.contentitem;

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

    override Json toJson()  {
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
