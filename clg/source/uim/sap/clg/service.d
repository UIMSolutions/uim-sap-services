/**
 * Domain service for CLG cloud logging
 */
module uim.sap.clg.service;

import vibe.data.json : Json;

import uim.sap.clg.config;
import uim.sap.clg.exceptions;
import uim.sap.clg.models;
import uim.sap.clg.store;

class CLGService {
    private CLGConfig _config;
    private CLGLogStore _store;

    this(CLGConfig config) {
        config.validate();
        _config = config;
        _store = new CLGLogStore(config.maxEntries);
    }

    @property const(CLGConfig) config() const {
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
        auto entry = CLGLogEntry.fromJson(payload);
        validateEntry(entry);
        _store.append(entry);

        Json response = Json.emptyObject;
        response["accepted"] = 1;
        response["entryId"] = entry.id;
        return response;
    }

    Json ingestBatch(Json payload) {
        if (!("logs" in payload) || payload["logs"].type != Json.Type.array) {
            throw new CLGLogValidationException("Payload must contain 'logs' array");
        }

        CLGLogEntry[] logs;
        foreach (item; payload["logs"]) {
            auto entry = CLGLogEntry.fromJson(item);
            validateEntry(entry);
            logs ~= entry;
        }

        _store.appendBatch(logs);

        Json response = Json.emptyObject;
        response["accepted"] = cast(long)logs.length;
        return response;
    }

    Json query(Json payload) {
        auto queryRequest = CLGLogQuery.fromJson(payload, _config.defaultQueryLimit);
        auto logs = _store.query(queryRequest);

        Json response = Json.emptyObject;
        response["count"] = cast(long)logs.length;
        response["logs"] = logsToJsonArray(logs);
        return response;
    }

    Json metrics() {
        return _store.metrics().toJson();
    }

    private void validateEntry(scope const CLGLogEntry entry) {
        if (entry.message.length == 0) {
            throw new CLGLogValidationException("Log message cannot be empty");
        }

        if (entry.source.length == 0) {
            throw new CLGLogValidationException("Log source cannot be empty");
        }
    }
}
