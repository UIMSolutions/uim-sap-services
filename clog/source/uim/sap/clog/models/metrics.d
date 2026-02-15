struct SCLMetrics {
    size_t totalEntries;
    long[SCLLogLevel] entriesByLevel;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["totalEntries"] = cast(long)totalEntries;

        Json levels = Json.emptyObject;
        foreach (lvl; [SCLLogLevel.TRACE, SCLLogLevel.DEBUG, SCLLogLevel.INFO, SCLLogLevel.WARN, SCLLogLevel.ERROR, SCLLogLevel.FATAL]) {
            levels[formatLevel(lvl)] = entriesByLevel[lvl];
        }
        payload["entriesByLevel"] = levels;
        return payload;
    }
}