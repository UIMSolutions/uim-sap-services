/**
 * Domain service for SCL cloud logging
 */
module uim.sap.scl.service;

import vibe.data.json : Json;

import uim.sap.scl.config;
import uim.sap.scl.exceptions;
import uim.sap.scl.models;
import uim.sap.scl.store;

class SCLService {
    private SCLConfig _config;
    private SCLLogStore _store;

    this(SCLConfig config) {
        config.validate();
        _config = config;
        _store = new SCLLogStore(config.maxEntries);
    }

    @property const(SCLConfig) config() const {
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
        auto entry = SCLLogEntry.fromJson(payload);
        validateEntry(entry);
        _store.append(entry);

        Json response = Json.emptyObject;
        response["accepted"] = 1;
        response["entryId"] = entry.id;
        return response;
    }

    Json ingestBatch(Json payload) {
        if (!("logs" in payload) || payload["logs"].type != Json.Type.array) {
            throw new SCLLogValidationException("Payload must contain 'logs' array");
        }

        SCLLogEntry[] logs;
        foreach (item; payload["logs"]) {
            auto entry = SCLLogEntry.fromJson(item);
            validateEntry(entry);
            logs ~= entry;
        }

        _store.appendBatch(logs);

        Json response = Json.emptyObject;
        response["accepted"] = cast(long)logs.length;
        return response;
    }

    Json query(Json payload) {
        auto queryRequest = SCLLogQuery.fromJson(payload, _config.defaultQueryLimit);
        auto logs = _store.query(queryRequest);

        Json response = Json.emptyObject;
        response["count"] = cast(long)logs.length;
        response["logs"] = logsToJsonArray(logs);
        return response;
    }

    Json metrics() {
        return _store.metrics().toJson();
    }

    private void validateEntry(scope const SCLLogEntry entry) {
        if (entry.message.length == 0) {
            throw new SCLLogValidationException("Log message cannot be empty");
        }

        if (entry.source.length == 0) {
            throw new SCLLogValidationException("Log source cannot be empty");
        }
    }
}
