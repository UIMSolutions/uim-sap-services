/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.clg.models.logentry;

import uim.sap.clg;

mixin(ShowModule!());

@safe:

/** 
  * Represents a log entry in the CLG system.
  * This struct is used to encapsulate all relevant information about a log entry, including its ID, timestamp, tenant, source, log level, message, and any additional attributes.
  * It provides methods for converting to and from JSON format, which is useful for API interactions and storage.
  *
  * The `fromJson` method allows creating a `CLGLogEntry` instance from a JSON payload, while the `toJson` method converts an instance back to JSON format.
  */
struct CLGLogEntry {
    UUID id;
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
