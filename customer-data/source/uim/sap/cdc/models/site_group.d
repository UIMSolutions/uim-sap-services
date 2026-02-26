module uim.sap.cdc.models.site_group;

import std.datetime : SysTime;

import vibe.data.json : Json;

@safe:

struct CDCSiteGroup {
  string tenantId;
  string groupId;
  string name;
  string[] sites;
  string[] regions;
  SysTime createdAt;
  SysTime updatedAt;

  Json toJson() const {
    Json payload = Json.emptyObject;
    payload["tenant_id"] = tenantId;
    payload["group_id"] = groupId;
    payload["name"] = name;

    Json siteValues = Json.emptyArray;
    foreach (value; sites) siteValues ~= value;
    payload["sites"] = siteValues;

    Json regionValues = Json.emptyArray;
    foreach (value; regions) regionValues ~= value;
    payload["regions"] = regionValues;

    payload["created_at"] = createdAt.toISOExtString();
    payload["updated_at"] = updatedAt.toISOExtString();
    return payload;
  }
}
