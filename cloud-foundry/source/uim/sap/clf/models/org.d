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

CLFOrg orgFromJson(Json payload) {
    CLFOrg org;
    org.guid = randomUUID().toString();
    org.createdAt = Clock.currTime();
    if ("name" in payload && payload["name"].type == Json.Type.string) {
        org.name = payload["name"].get!string;
    }
    return org;
}