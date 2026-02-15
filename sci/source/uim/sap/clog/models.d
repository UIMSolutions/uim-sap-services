/**
 * Models for SCI Cloud Logging service
 */
module uim.sap.sci.models;

import std.datetime : Clock, SysTime;
import std.string : strip, toUpper;
import std.typecons : Nullable;
import std.uuid : randomUUID;

import vibe.data.json : Json;

enum SCILogLevel {
    TRACE,
    DEBUG,
    INFO,
    WARN,
    ERROR,
    FATAL
}

SCILogLevel parseLevel(string input) {
    switch (toUpper(strip(input))) {
        case "TRACE": return SCILogLevel.TRACE;
        case "DEBUG": return SCILogLevel.DEBUG;
        case "INFO": return SCILogLevel.INFO;
        case "WARN": return SCILogLevel.WARN;
        case "ERROR": return SCILogLevel.ERROR;
        case "FATAL": return SCILogLevel.FATAL;
        default: return SCILogLevel.INFO;
    }
}

string formatLevel(SCILogLevel level) {
    final switch (level) {
        case SCILogLevel.TRACE: return "TRACE";
        case SCILogLevel.DEBUG: return "DEBUG";
        case SCILogLevel.INFO: return "INFO";
        case SCILogLevel.WARN: return "WARN";
        case SCILogLevel.ERROR: return "ERROR";
        case SCILogLevel.FATAL: return "FATAL";
    }
}

struct SCILogEntry {
    string id;
    SysTime timestamp;
    string tenant;
    string source;
    SCILogLevel level = SCILogLevel.INFO;
    string message;
    Json attributes = Json.emptyObject;

    static SCILogEntry fromJson(Json payload) {
        SCILogEntry entry;
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

struct SCILogQuery {
    string tenant;
    string source;
    string contains;
    Nullable!SCILogLevel level;
    size_t limit = 100;

    static SCILogQuery fromJson(Json payload, size_t fallbackLimit) {
        SCILogQuery query;
        query.limit = fallbackLimit;

        if ("tenant" in payload && payload["tenant"].type == Json.Type.string) {
            query.tenant = payload["tenant"].get!string;
        }
        if ("source" in payload && payload["source"].type == Json.Type.string) {
            query.source = payload["source"].get!string;
        }
        if ("contains" in payload && payload["contains"].type == Json.Type.string) {
            query.contains = payload["contains"].get!string;
        }
        if ("level" in payload && payload["level"].type == Json.Type.string) {
            query.level = Nullable!SCILogLevel(parseLevel(payload["level"].get!string));
        }
        if ("limit" in payload && payload["limit"].type == Json.Type.int_) {
            auto parsed = payload["limit"].get!long;
            if (parsed > 0) {
                query.limit = cast(size_t)parsed;
            }
        }

        return query;
    }
}

struct SCIMetrics {
    size_t totalEntries;
    long[SCILogLevel] entriesByLevel;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["totalEntries"] = cast(long)totalEntries;

        Json levels = Json.emptyObject;
        foreach (lvl; [SCILogLevel.TRACE, SCILogLevel.DEBUG, SCILogLevel.INFO, SCILogLevel.WARN, SCILogLevel.ERROR, SCILogLevel.FATAL]) {
            levels[formatLevel(lvl)] = entriesByLevel[lvl];
        }
        payload["entriesByLevel"] = levels;
        return payload;
    }
}

Json logsToJsonArray(scope const(SCILogEntry)[] logs) {
    Json arr = Json.emptyArray;
    foreach (logEntry; logs) {
        arr ~= logEntry.toJson();
    }
    return arr;
}
