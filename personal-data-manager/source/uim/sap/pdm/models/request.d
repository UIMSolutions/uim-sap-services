module uim.sap.pdm.models.request;

import uim.sap.pdm;

mixin(ShowModule!());

@safe:

/// Data subject request — a formal request regarding personal data (GDPR Art. 15-22)
struct PDMDataRequest {
    string requestId;
    string subjectId;
    string tenantId;

    PDMRequestType requestType = PDMRequestType.access;
    PDMRequestStatus status = PDMRequestStatus.draft;

    string description;
    string requestedBy;      // who created the request (operator or subject)
    string assignedTo;       // processor handling the request
    string resolution;       // outcome description

    string[] affectedApplications; // applications that hold the subject's data

    SysTime createdAt;
    SysTime updatedAt;
    SysTime deadline;        // regulatory deadline for completion
    SysTime completedAt;

    Json toJson() const {
        Json j = Json.emptyObject;
        j["request_id"] = requestId;
        j["subject_id"] = subjectId;
        j["tenant_id"] = tenantId;
        j["request_type"] = cast(string) requestType;
        j["status"] = cast(string) status;
        j["description"] = description;
        j["requested_by"] = requestedBy;
        j["assigned_to"] = assignedTo;
        j["resolution"] = resolution;

        Json apps = Json.emptyArray;
        foreach (a; affectedApplications) apps ~= Json(a);
        j["affected_applications"] = apps;

        j["created_at"] = createdAt.toISOExtString();
        j["updated_at"] = updatedAt.toISOExtString();
        j["deadline"] = deadline.toISOExtString();
        if (status == PDMRequestStatus.completed)
            j["completed_at"] = completedAt.toISOExtString();
        return j;
    }
}

PDMDataRequest requestFromJson(string requestId, string subjectId, string tenantId, Json req) {
    PDMDataRequest r;
    r.requestId = requestId;
    r.subjectId = subjectId;
    r.tenantId = tenantId;
    r.createdAt = Clock.currTime();
    r.updatedAt = r.createdAt;

    if ("request_type" in req && req["request_type"].isString)
        r.requestType = parseRequestType(req["request_type"].get!string);
    if ("description" in req && req["description"].isString)
        r.description = req["description"].get!string;
    if ("requested_by" in req && req["requested_by"].isString)
        r.requestedBy = req["requested_by"].get!string;
    if ("assigned_to" in req && req["assigned_to"].isString)
        r.assignedTo = req["assigned_to"].get!string;
    if ("affected_applications" in req && req["affected_applications"].type == Json.Type.array) {
        foreach (v; req["affected_applications"])
            if (v.isString) r.affectedApplications ~= v.get!string;
    }

    // Default deadline: 30 days from creation (GDPR requirement)
    import std.datetime : dur;
    r.deadline = r.createdAt + dur!"days"(30);

    return r;
}

private PDMRequestType parseRequestType(string s) {
    switch (s) {
        case "access": return PDMRequestType.access;
        case "rectification": return PDMRequestType.rectification;
        case "erasure": return PDMRequestType.erasure;
        case "restriction": return PDMRequestType.restriction;
        case "portability": return PDMRequestType.portability;
        case "objection": return PDMRequestType.objection;
        case "information": return PDMRequestType.information;
        default: return PDMRequestType.access;
    }
}
