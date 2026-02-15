struct CLGMetrics {
    size_t totalEntries;
    long[CLGLogLevel] entriesByLevel;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["totalEntries"] = cast(long)totalEntries;

        Json levels = Json.emptyObject;
        foreach (lvl; [CLGLogLevel.TRACE, CLGLogLevel.DEBUG, CLGLogLevel.INFO, CLGLogLevel.WARN, CLGLogLevel.ERROR, CLGLogLevel.FATAL]) {
            levels[formatLevel(lvl)] = entriesByLevel[lvl];
        }
        payload["entriesByLevel"] = levels;
        return payload;
    }
}