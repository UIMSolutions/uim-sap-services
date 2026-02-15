SCLLogLevel parseLevel(string input) {
    switch (toUpper(strip(input))) {
        case "TRACE": return SCLLogLevel.TRACE;
        case "DEBUG": return SCLLogLevel.DEBUG;
        case "INFO": return SCLLogLevel.INFO;
        case "WARN": return SCLLogLevel.WARN;
        case "ERROR": return SCLLogLevel.ERROR;
        case "FATAL": return SCLLogLevel.FATAL;
        default: return SCLLogLevel.INFO;
    }
}