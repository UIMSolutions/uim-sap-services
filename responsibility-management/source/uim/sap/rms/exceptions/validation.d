module uim.sap.rms.exceptions.validation;

import uim.sap.rms;

mixin(ShowModule!());

@safe:

class RMSValidationException : RMSException {
    this(string message, string file = __FILE__, size_t line = __LINE__) {
        super(message, file, line);
    }
}
