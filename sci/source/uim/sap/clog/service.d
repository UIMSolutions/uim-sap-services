/**
 * Domain service for SCI cloud logging
 */
module uim.sap.clog.service;

import vibe.data.json : Json;

import uim.sap.clog.config;
import uim.sap.clog.exceptions;
import uim.sap.clog.models;
import uim.sap.clog.store;

class SCIService {
    private SCIConfig _config;
    private SCILogStore _store;

    this(SCIConfig config) {
        config.validate();
        _config = config;
        _store = new SCILogStore(config.maxEntries);
    }

    @property const(SCIConfig) config() const {
        return _config;
    }

    Json health() {
        Json payload = Json.emptyObject;
        payload["ok"] = true;
        payload["serviceName"] = _config.serviceName;
        payload["serviceVersion"] = _config.serviceVersion;
        payload["storedEntries"] = cast(long)_store.count();
        return payload;
    }

    Json ready() {
        Json payload = Json.emptyObject;
        payload["ready"] = true;
        payload["storedEntries"] = cast(long)_store.count();
        return payload;
    }

    Json ingest(Json payload) {
        auto entry = SCILogEntry.fromJson(payload);
        validateEntry(entry);
        _store.append(entry);

        Json response = Json.emptyObject;
        response["accepted"] = 1;
        response["entryId"] = entry.id;
        return response;
    }

    Json ingestBatch(Json payload) {
        if (!("logs" in payload) || payload["logs"].type != Json.Type.array) {
            throw new SCILogValidationException("Payload must contain 'logs' array");
        }

        SCILogEntry[] logs;
        foreach (item; payload["logs"]) {
            auto entry = SCILogEntry.fromJson(item);
            validateEntry(entry);
            logs ~= entry;
        }

        _store.appendBatch(logs);

        Json response = Json.emptyObject;
        response["accepted"] = cast(long)logs.length;
        return response;
    }

    Json query(Json payload) {
        auto queryRequest = SCILogQuery.fromJson(payload, _config.defaultQueryLimit);
        auto logs = _store.query(queryRequest);

        Json response = Json.emptyObject;
        response["count"] = cast(long)logs.length;
        response["logs"] = logsToJsonArray(logs);
        return response;
    }

    Json metrics() {
        return _store.metrics().toJson();
    }

    private void validateEntry(scope const SCILogEntry entry) {
        if (entry.message.length == 0) {
            throw new SCILogValidationException("Log message cannot be empty");
        }

        if (entry.source.length == 0) {
            throw new SCILogValidationException("Log source cannot be empty");
        }
    }
}
