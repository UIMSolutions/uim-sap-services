module uim.sap.scl.exceptions.configuration;

import uim.sap.scl;

mixin(ShowModule!());

@safe:

class SCLConfigurationException : SCLException {
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
        super(msg, file, line, next);
    }
}