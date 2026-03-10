module uim.sap.kym.exceptions.configuration;

import uim.sap.kym;

mixin(ShowModule!());

@safe:

class KYMConfigurationException : KYMException {
    this(string msg) {
        super(msg);
    }
}
