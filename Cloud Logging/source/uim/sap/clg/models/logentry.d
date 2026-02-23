module uim.sap.clg.models.logentry;

import uim.sap.clg;

mixin(ShowModule!());

@safe:

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

        if ("tenant" in payload && payload["tenant"].isString) {
            entry.tenant = payload["tenant"].get!string;
        }
        if ("source" in payload && payload["source"].isString) {
            entry.source = payload["source"].get!string;
        }
        if ("level" in payload && payload["level"].isString) {
            entry.level = parseLevel(payload["level"].get!string);
        }
        if ("message" in payload && payload["message"].isString) {
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
