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