string formatLevel(SCLLogLevel level) {
    final switch (level) {
        case SCLLogLevel.TRACE: return "TRACE";
        case SCLLogLevel.DEBUG: return "DEBUG";
        case SCLLogLevel.INFO: return "INFO";
        case SCLLogLevel.WARN: return "WARN";
        case SCLLogLevel.ERROR: return "ERROR";
        case SCLLogLevel.FATAL: return "FATAL";
    }
}

Json logsToJsonArray(scope const(SCLEntry)[] logs) {
    Json arr = Json.emptyArray;
    foreach (logEntry; logs) {
        arr ~= logEntry.toJson();
    }
    return arr;
}
