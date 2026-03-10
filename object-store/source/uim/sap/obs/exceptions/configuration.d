module uim.sap.obs.exceptions.configuration;

import uim.sap.obs;

mixin(ShowModule!());

@safe:

class OBSConfigurationException : OBSException {
    this(string msg, string file = __FILE__, size_t line = __LINE__) {
        super("Configuration error: " ~ msg, file, line);
    }
}
