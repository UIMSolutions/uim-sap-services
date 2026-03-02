module uim.sap.rms.exceptions.configuration;

import uim.sap.rms;

mixin(ShowModule!());

@safe:

class RMSConfigurationException : RMSException {
    this(string message, string file = __FILE__, size_t line = __LINE__) {
        super(message, file, line);
    }
}
