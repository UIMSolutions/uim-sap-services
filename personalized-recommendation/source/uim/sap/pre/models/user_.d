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
  string userId;
  string tenantId;
  string displayName;
  PREUserSegment segment = PREUserSegment.new_user;
  string[] preferences;
  string[string] context;
  string createdAt;
  string updatedAt;
}

Json userToJson(const ref PREUser u) {
  Json j = Json.emptyObject;
  j["userId"] = u.userId;
  j["tenantId"] = u.tenantId;
  j["displayName"] = u.displayName;
  j["segment"] = u.segment.to!string;
  {
    Json arr = Json.emptyArray;
    foreach (p; u.preferences)
      arr ~= Json(p);
    j["preferences"] = arr;
  }
  {
    Json obj = Json.emptyObject;
    foreach (k, v; u.context)
      obj[k] = v;
    j["context"] = obj;
  }
  j["createdAt"] = u.createdAt;
  j["updatedAt"] = u.updatedAt;
  return j;
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
