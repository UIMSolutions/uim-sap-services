struct Team {
    string id;
    string name;
    string typeCode;
    string categoryCode;
    string description;
    TeamMember[] members;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["id"] = id;
        payload["name"] = name;
        payload["type_code"] = typeCode;
        payload["category_code"] = categoryCode;
        payload["description"] = description;

        Json memberList = Json.emptyArray;
        foreach (member; members) {
            memberList ~= member.toJson();
        }
        payload["members"] = memberList;
        return payload;
    }
}
