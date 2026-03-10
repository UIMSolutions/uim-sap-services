/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
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

Json logsToJsonArray(scope const(CLGLogEntry)[] logs) {
    Json arr = Json.emptyArray;
    foreach (logEntry; logs) {
        arr ~= logEntry.toJson();
    }
    return arr;
}
