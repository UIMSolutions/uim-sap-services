module uim.sap.kst.exceptions.configuration;

import uim.sap.kst;

mixin(ShowModule!());

@safe:

class KSTConfigurationException : KSTException {
    this(string msg) {
        super(msg);
    }
}
