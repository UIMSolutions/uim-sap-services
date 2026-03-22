/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.pdm.models.request;

import uim.sap.pdm;

mixin(ShowModule!());

@safe:

/// Data subject request — a formal request regarding personal data (GDPR Art. 15-22)
class PDMDataRequest : SAPTenantObject {
  mixin(SAPObjectTemplate!PDMDataRequest);

  UUID requestId;
  UUID subjectId;

  PDMRequestType requestType = PDMRequestType.access;
  PDMRequestStatus status = PDMRequestStatus.draft;

  string description;
  string requestedBy; // who created the request (operator or subject)
  string assignedTo; // processor handling the request
  string resolution; // outcome description

  string[] affectedApplications; // applications that hold the subject's data

  SysTime deadline; // regulatory deadline for completion
  SysTime completedAt;

  override Json toJson() {
    Json apps = affectedApplications.map!(app => app.toJson).array.toJson;

    Json json = super.toJson
      .set("request_id", requestId)
      .set("subject_id", subjectId)
      .set("request_type", cast(string)requestType)
      .set("status", cast(string)status)
      .set("description", description)
      .set("requested_by", requestedBy)
      .set("assigned_to", assignedTo)
      .set("resolution", resolution)
      .set("affected_applications", apps)
      .set("deadline", deadline.toISOExtString());

    return status == PDMRequestStatus.completed
      ? json.set("completed_at", completedAt.toISOExtString()) : json;
  }

  static PDMDataRequest opCall(UUID requestId, UUID subjectId, UUID tenantId, Json req) {
    PDMDataRequest r = new PDMDataRequest(req);
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
        if (v.isString)
          r.affectedApplications ~= v.get!string;
    }

    // Default deadline: 30 days from creation (GDPR requirement)
    import std.datetime : dur;

    r.deadline = r.createdAt + dur!"days"(30);

    return r;
  }
}

private PDMRequestType parseRequestType(string s) {
  switch (s) {
  case "access":
    return PDMRequestType.access;
  case "rectification":
    return PDMRequestType.rectification;
  case "erasure":
    return PDMRequestType.erasure;
  case "restriction":
    return PDMRequestType.restriction;
  case "portability":
    return PDMRequestType.portability;
  case "objection":
    return PDMRequestType.objection;
  case "information":
    return PDMRequestType.information;
  default:
    return PDMRequestType.access;
  }
}
