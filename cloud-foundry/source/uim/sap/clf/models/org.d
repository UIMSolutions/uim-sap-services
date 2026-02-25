struct CLFOrg {
    string guid;
    string name;
    SysTime createdAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["guid"] = guid;
        payload["name"] = name;
        payload["created_at"] = createdAt.toISOExtString();
        return payload;
    }
}