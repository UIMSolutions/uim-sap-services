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