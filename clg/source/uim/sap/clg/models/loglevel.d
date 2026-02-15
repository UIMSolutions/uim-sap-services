CLGLogLevel parseLevel(string input) {
    switch (toUpper(strip(input))) {
        case "TRACE": return CLGLogLevel.TRACE;
        case "DEBUG": return CLGLogLevel.DEBUG;
        case "INFO": return CLGLogLevel.INFO;
        case "WARN": return CLGLogLevel.WARN;
        case "ERROR": return CLGLogLevel.ERROR;
        case "FATAL": return CLGLogLevel.FATAL;
        default: return CLGLogLevel.INFO;
    }
}