module uim.sap.aas.exceptions.configuration;

import uim.sap.aas;
@safe:

class AASConfigurationException : AASException {
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
        super(msg, file, line, next);
    }
}