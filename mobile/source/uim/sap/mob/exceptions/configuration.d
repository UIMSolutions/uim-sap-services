module uim.sap.mob.exceptions.configuration;

import uim.sap.mob;

mixin(ShowModule!());

@safe:

class MOBConfigurationException : MOBException {
    this(string msg, string file = __FILE__, size_t line = __LINE__) {
        super("Configuration error: " ~ msg, file, line);
    }
}
