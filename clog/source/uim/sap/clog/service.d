/**
 * Domain service for SCI cloud logging
 */
module uim.sap.clog.service;

import vibe.data.json : Json;

import uim.sap.clog.config;
import uim.sap.clog.exceptions;
import uim.sap.clog.models;
import uim.sap.clog.store;

class ClogService {
    private ClogConfig _config;
    private ClogLogStore _store;

    this(ClogConfig config) {
        config.validate();
        _config = config;
        _store = new ClogLogStore(config.maxEntries);
    }

    @property const(ClogConfig) config() const {
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
        auto entry = ClogLogEntry.fromJson(payload);
        validateEntry(entry);
        _store.append(entry);

        Json response = Json.emptyObject;
        response["accepted"] = 1;
        response["entryId"] = entry.id;
        return response;
    }

    Json ingestBatch(Json payload) {
        if (!("logs" in payload) || payload["logs"].type != Json.Type.array) {
            throw new ClogLogValidationException("Payload must contain 'logs' array");
        }

        ClogLogEntry[] logs;
        foreach (item; payload["logs"]) {
            auto entry = ClogLogEntry.fromJson(item);
            validateEntry(entry);
            logs ~= entry;
        }

        _store.appendBatch(logs);

        Json response = Json.emptyObject;
        response["accepted"] = cast(long)logs.length;
        return response;
    }

    Json query(Json payload) {
        auto queryRequest = ClogLogQuery.fromJson(payload, _config.defaultQueryLimit);
        auto logs = _store.query(queryRequest);

        Json response = Json.emptyObject;
        response["count"] = cast(long)logs.length;
        response["logs"] = logsToJsonArray(logs);
        return response;
    }

    Json metrics() {
        return _store.metrics().toJson();
    }

    private void validateEntry(scope const ClogLogEntry entry) {
        if (entry.message.length == 0) {
            throw new ClogLogValidationException("Log message cannot be empty");
        }

        if (entry.source.length == 0) {
            throw new ClogLogValidationException("Log source cannot be empty");
        }
    }
}
