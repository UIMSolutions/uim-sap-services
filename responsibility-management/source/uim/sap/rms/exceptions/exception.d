module uim.sap.rms.exceptions.exception;

import uim.sap.rms;

mixin(ShowModule!());

@safe:


class RMSException : Exception {
    this(string message, string file = __FILE__, size_t line = __LINE__) {
        super(message, file, line);
    }
}
