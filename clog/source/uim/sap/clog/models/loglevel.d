ClogLogLevel parseLevel(string input) {
    switch (toUpper(strip(input))) {
        case "TRACE": return ClogLogLevel.TRACE;
        case "DEBUG": return ClogLogLevel.DEBUG;
        case "INFO": return ClogLogLevel.INFO;
        case "WARN": return ClogLogLevel.WARN;
        case "ERROR": return ClogLogLevel.ERROR;
        case "FATAL": return ClogLogLevel.FATAL;
        default: return ClogLogLevel.INFO;
    }
}