module uim.sap.rms.exceptions.authorization;

import uim.sap.rms;

mixin(ShowModule!());

@safe:

class RMSAuthorizationException : RMSException {
    this(string message, string file = __FILE__, size_t line = __LINE__) {
        super(message, file, line);
    }
}
