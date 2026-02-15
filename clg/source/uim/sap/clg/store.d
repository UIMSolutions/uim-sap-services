/**
 * In-memory store for CLG logs
 */
module uim.sap.clg.store;

import core.sync.mutex : Mutex;
import std.algorithm.searching : canFind;
import std.algorithm.comparison : min;
import std.string : toLower;

import uim.sap.clg.models;

class CLGLogStore {
    private CLGLogEntry[] _entries;
    private size_t _maxEntries;
    private Mutex _lock;

    this(size_t maxEntries) {
        _maxEntries = maxEntries;
        _lock = new Mutex;
    }

    size_t count() {
        synchronized (_lock) {
            return _entries.length;
        }
    }

    void append(CLGLogEntry entry) {
        synchronized (_lock) {
            _entries ~= entry;
            trimIfNeeded();
        }
    }

    void appendBatch(scope const(CLGLogEntry)[] logs) {
        synchronized (_lock) {
            foreach (entry; logs) {
                _entries ~= entry;
            }
            trimIfNeeded();
        }
    }

    CLGLogEntry[] query(CLGLogQuery queryRequest) {
        CLGLogEntry[] result;

        synchronized (_lock) {
            foreach_reverse (entry; _entries) {
                if (queryRequest.tenant.length > 0 && entry.tenant != queryRequest.tenant) {
                    continue;
                }

                if (queryRequest.source.length > 0 && entry.source != queryRequest.source) {
                    continue;
                }

                if (!queryRequest.level.isNull && entry.level != queryRequest.level.get()) {
                    continue;
                }

                if (queryRequest.contains.length > 0) {
                    auto haystack = toLower(entry.message);
                    auto needle = toLower(queryRequest.contains);
                    if (!canFind(haystack, needle)) {
                        continue;
                    }
                }

                result ~= entry;
                if (result.length >= queryRequest.limit) {
                    break;
                }
            }
        }

        return result;
    }

    CLGMetrics metrics() {
        CLGMetrics metrics;
        synchronized (_lock) {
            metrics.totalEntries = _entries.length;
            foreach (entry; _entries) {
                metrics.entriesByLevel[entry.level]++;
            }
        }
        return metrics;
    }

    private void trimIfNeeded() {
        if (_entries.length <= _maxEntries) {
            return;
        }

        auto overflow = _entries.length - _maxEntries;
        auto keep = min(_entries.length, _maxEntries);
        if (keep > 0) {
            _entries = _entries[overflow .. $].dup;
        } else {
            _entries.length = 0;
        }
    }
}
