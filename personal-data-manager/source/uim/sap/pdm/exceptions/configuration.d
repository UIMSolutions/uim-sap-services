module uim.sap.pdm.exceptions.configuration;

import uim.sap.pdm;

mixin(ShowModule!());

@safe:

class PDMConfigurationException : PDMException {
    this(string msg, string file = __FILE__, size_t line = __LINE__) {
        super("Configuration error: " ~ msg, file, line);
    }
}
