string formatLevel(CLOGLogLevel level) {
    final switch (level) {
        case CLOGLogLevel.TRACE: return "TRACE";
        case CLOGLogLevel.DEBUG: return "DEBUG";
        case CLOGLogLevel.INFO: return "INFO";
        case CLOGLogLevel.WARN: return "WARN";
        case CLOGLogLevel.ERROR: return "ERROR";
        case CLOGLogLevel.FATAL: return "FATAL";
    }
}

Json logsToJsonArray(scope const(CLogEntry)[] logs) {
    Json arr = Json.emptyArray;
    foreach (logEntry; logs) {
        arr ~= logEntry.toJson();
    }
    return arr;
}
