struct CLFServiceInstance {
    string guid;
    string name;
    string serviceGuid;
    string spaceGuid;
    string status = "create succeeded";
    SysTime createdAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["guid"] = guid;
        payload["name"] = name;
        payload["service_guid"] = serviceGuid;
        payload["space_guid"] = spaceGuid;
        payload["status"] = status;
        payload["created_at"] = createdAt.toISOExtString();
        return payload;
    }
}
