module uim.sap.kym.models.event;

import uim.sap.kym;

mixin(ShowModule!());

@safe:

/// An event published to the event mesh
struct KYMEvent {
    string id;
    string eventType;
    string source;
    string namespace;
    Json data;
    SysTime timestamp;

    override Json toJson()  {
        return super.toJson()
        .set("id", id)
        .set("event_type", eventType)
        .set("source", source)
        .set("namespace", namespace)
        .set("data", data)
        .set("timestamp", timestamp.toISOExtString());
    }
}

KYMEvent eventFromJson(string namespace, Json request) {
    KYMEvent ev;
    ev.id = randomUUID().toString();
    ev.namespace = namespace;
    ev.timestamp = Clock.currTime();

    if ("event_type" in request && request["event_type"].isString)
        ev.eventType = request["event_type"].get!string;
    if ("source" in request && request["source"].isString)
        ev.source = request["source"].get!string;
    if ("data" in request)
        ev.data = request["data"];
    else
        ev.data = Json.emptyObject;
    return ev;
}
