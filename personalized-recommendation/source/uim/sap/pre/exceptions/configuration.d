module uim.sap.pre.exceptions.configuration;

import uim.sap.pre;

mixin(ShowModule!());

class PREConfigurationException : PREException {
    this(string msg, string file = __FILE__, size_t line = __LINE__) {
        super(msg, file, line);
    }
}
