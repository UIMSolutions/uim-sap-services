struct CLFSpace {
  string guid;
  string name;
  string organizationGuid;
  SysTime createdAt;

  Json toJson() const {
    Json payload = Json.emptyObject;
    payload["guid"] = guid;
    payload["name"] = name;
    payload["organization_guid"] = organizationGuid;
    payload["created_at"] = createdAt.toISOExtString();
    return payload;
  }
}

CLFSpace spaceFromJson(Json payload) {
  CLFSpace space;
  space.guid = randomUUID().toString();
  space.createdAt = Clock.currTime();
  if ("name" in payload && payload["name"].isString) {
    space.name = payload["name"].get!string;
  }
  if ("organization_guid" in payload && payload["organization_guid"].isString) {
    space.organizationGuid = payload["organization_guid"].get!string;
  }
  return space;
}
