module uim.sap.cis.models.group;

import uim.sap.cis;

mixin(ShowModule!());

@safe:

struct CISGroup {
  string tenantId;
  string groupId;
  string displayName;
  Json members;
  SysTime updatedAt;

  Json toJson() const {
    Json payload = Json.emptyObject;
    payload["id"] = groupId;
    payload["tenant_id"] = tenantId;
    payload["displayName"] = displayName;
    payload["members"] = members;
    payload["updated_at"] = updatedAt.toISOExtString();
    return payload;
  }
}

CISGroup groupFromJson(string tenantId, Json request) {
  CISGroup group;
  group.tenantId = tenantId;
  group.groupId = createId();
  group.updatedAt = Clock.currTime();
  group.members = Json.emptyArray;

  if ("id" in request && request["id"].type == Json.Type.string)
    group.groupId = request["id"].get!string;
  if ("displayName" in request && request["displayName"].type == Json.Type.string)
    group.displayName = request["displayName"].get!string;
  if ("members" in request && request["members"].type == Json.Type.array)
    group.members = request["members"];

  return group;
}
