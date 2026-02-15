module uim.sap.clg.exceptions.exception;

import uim.sap.clg;

mixin(ShowModule!());

@safe:

// Enumeration for log levels
enum CLGLogLevel {
    TRACE,
    DEBUG,
    INFO,
    WARN,
    ERROR,
    FATAL
}