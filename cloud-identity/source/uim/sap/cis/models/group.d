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
/// 
unittest {
  mixin(ShowTest!("Testing CISGroup toJson() method"));

  CISGroup group;
  group.tenantId = "tenant123";
  group.groupId = "group123";
  group.displayName = "Test Group";
  group.members = ["user1", "user2"].toJson;
  group.updatedAt = Clock.currTime();

  Json json = group.toJson();
  assert(json["id"] == "group123");
  assert(json["tenant_id"] == "tenant123");
  assert(json["displayName"] == "Test Group");
  assert(json["members"].type == Json.Type.array);
  assert(json["updated_at"].isString);
}

CISGroup groupFromJson(string tenantId, Json request) {
  CISGroup group;
  group.tenantId = tenantId;
  group.groupId = createId();
  group.updatedAt = Clock.currTime();
  group.members = Json.emptyArray;

  if ("id" in request && request["id"].isString)
    group.groupId = request["id"].get!string;
  if ("displayName" in request && request["displayName"].isString)
    group.displayName = request["displayName"].get!string;
  if ("members" in request && request["members"].type == Json.Type.array)
    group.members = request["members"];

  return group;
}
/// 
unittest {
  mixin(ShowTest!("Testing groupFromJson() function"));

  Json request = Json.emptyObject;
  request["id"] = "group123";
  request["displayName"] = "Test Group";
  request["members"] = ["user1", "user2"].toJson;

  CISGroup group = groupFromJson("tenant123", request);
  assert(group.tenantId == "tenant123");
  assert(group.groupId == "group123");
  assert(group.displayName == "Test Group");
  assert(group.members.type == Json.Type.array);
}
