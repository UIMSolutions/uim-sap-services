struct SCIMetrics {
    size_t totalEntries;
    long[ClogLogLevel] entriesByLevel;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["totalEntries"] = cast(long)totalEntries;

        Json levels = Json.emptyObject;
        foreach (lvl; [ClogLogLevel.TRACE, ClogLogLevel.DEBUG, ClogLogLevel.INFO, ClogLogLevel.WARN, ClogLogLevel.ERROR, ClogLogLevel.FATAL]) {
            levels[formatLevel(lvl)] = entriesByLevel[lvl];
        }
        payload["entriesByLevel"] = levels;
        return payload;
    }
}