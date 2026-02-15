module uim.sap.clg.exceptions.helpers.functions;

import uim.sap.clg;

mixin(ShowModule!());

@safe:

string formatLevel(CLGLogLevel level) {
    final switch (level) {
        case CLGLogLevel.TRACE: return "TRACE";
        case CLGLogLevel.DEBUG: return "DEBUG";
        case CLGLogLevel.INFO: return "INFO";
        case CLGLogLevel.WARN: return "WARN";
        case CLGLogLevel.ERROR: return "ERROR";
        case CLGLogLevel.FATAL: return "FATAL";
    }
}

Json logsToJsonArray(scope const(CLGEntry)[] logs) {
    Json arr = Json.emptyArray;
    foreach (logEntry; logs) {
        arr ~= logEntry.toJson();
    }
    return arr;
}
