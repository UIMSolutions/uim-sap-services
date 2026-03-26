/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.pre.models.user_;

import uim.sap.pre;

mixin(ShowModule!());

@safe:

/// A user whose interactions are tracked for personalisation.
struct PREUser {
  UUID userId;
  UUID tenantId;
  string displayName;
  PREUserSegment segment = PREUserSegment.new_user;
  string[] preferences;
  string[string] context;
  string createdAt;
  string updatedAt;
}

Json userToJson(const ref PREUser u) {
  Json arr = Json.emptyArray;
  foreach (p; u.preferences)
    arr ~= Json(p);

  Json obj = Json.emptyObject;
  foreach (k, v; u.context)
    obj[k] = v;

  return Json.emptyObject
    .set("userId", u.userId)
    .set("tenantId", u.tenantId)
    .set("displayName", u.displayName)
    .set("segment", u.segment.to!string)
    .set("preferences", arr)
    .set("context", obj)
    .set("createdAt", u.createdAt)
    .set("updatedAt", u.updatedAt);
}

PREUser userFromJson(Json j) {
  PREUser u;
  u.userId = j["userId"].get!string;
  u.tenantId = j.getString("tenantId", "");
  u.displayName = j.getString("displayName", "");
  foreach (p; j["preferences"].toMap)
    u.preferences ~= p.get!string;
  foreach (string k, v; j["context"].toMap)
    u.context[k] = v.get!string;
  return u;
}
