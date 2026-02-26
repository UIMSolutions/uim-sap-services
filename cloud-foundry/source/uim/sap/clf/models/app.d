struct CLFApp {
  string guid;
  string name;
  string spaceGuid;
  string state = "STOPPED";
  uint instances = 1;
  uint memoryMb = 256;
  SysTime createdAt;

  Json toJson() const {
    Json payload = Json.emptyObject;
    payload["guid"] = guid;
    payload["name"] = name;
    payload["space_guid"] = spaceGuid;
    payload["state"] = state;
    payload["instances"] = cast(long)instances;
    payload["memory_mb"] = cast(long)memoryMb;
    payload["created_at"] = createdAt.toISOExtString();
    return payload;
  }
}

CLFApp appFromJson(Json payload) {
  CLFApp app;
  app.guid = randomUUID().toString();
  app.createdAt = Clock.currTime();
  if ("name" in payload && payload["name"].type == Json.Type.string) {
    app.name = payload["name"].get!string;
  }
  if ("space_guid" in payload && payload["space_guid"].type == Json.Type.string) {
    app.spaceGuid = payload["space_guid"].get!string;
  }
  if ("state" in payload && payload["state"].type == Json.Type.string) {
    app.state = payload["state"].get!string;
  }
  if ("instances" in payload && payload["instances"].type == Json.Type.int_) {
    auto parsed = payload["instances"].get!long;
    if (parsed > 0) {
      app.instances = cast(uint)parsed;
    }
  }
  if ("memory_mb" in payload && payload["memory_mb"].type == Json.Type.int_) {
    auto parsed = payload["memory_mb"].get!long;
    if (parsed > 0) {
      app.memoryMb = cast(uint)parsed;
    }
  }
  return app;
}
