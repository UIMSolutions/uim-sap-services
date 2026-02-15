struct CLGLogEntry {
    string id;
    SysTime timestamp;
    string tenant;
    string source;
    CLGLogLevel level = CLGLogLevel.INFO;
    string message;
    Json attributes = Json.emptyObject;

    static CLGLogEntry fromJson(Json payload) {
        CLGLogEntry entry;
        entry.id = randomUUID().toString();
        entry.timestamp = Clock.currTime();

        if ("tenant" in payload && payload["tenant"].type == Json.Type.string) {
            entry.tenant = payload["tenant"].get!string;
        }
        if ("source" in payload && payload["source"].type == Json.Type.string) {
            entry.source = payload["source"].get!string;
        }
        if ("level" in payload && payload["level"].type == Json.Type.string) {
            entry.level = parseLevel(payload["level"].get!string);
        }
        if ("message" in payload && payload["message"].type == Json.Type.string) {
            entry.message = payload["message"].get!string;
        }
        if ("attributes" in payload) {
            entry.attributes = payload["attributes"];
        }
        return entry;
    }

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["id"] = id;
        payload["timestamp"] = timestamp.toISOExtString();
        payload["tenant"] = tenant;
        payload["source"] = source;
        payload["level"] = formatLevel(level);
        payload["message"] = message;
        payload["attributes"] = attributes;
        return payload;
    }
}
