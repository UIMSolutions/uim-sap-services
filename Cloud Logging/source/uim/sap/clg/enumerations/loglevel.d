module uim.sap.clg.enumerations.loglevel;

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