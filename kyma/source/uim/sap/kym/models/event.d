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
        Json payload = Json.emptyObject;
        payload["id"] = id;
        payload["event_type"] = eventType;
        payload["source"] = source;
        payload["namespace"] = namespace;
        payload["data"] = data;
        payload["timestamp"] = timestamp.toISOExtString();
        return payload;
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
