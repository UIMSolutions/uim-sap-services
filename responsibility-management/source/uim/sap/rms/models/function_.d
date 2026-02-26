struct FunctionDef {
    string code;
    string name;
    string description;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["code"] = code;
        payload["name"] = name;
        payload["description"] = description;
        return payload;
    }
}