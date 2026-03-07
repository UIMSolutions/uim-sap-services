module uim.sap.mon.exceptions.configuration;

import uim.sap.mon;

mixin(ShowModule!());

@safe:

class MONConfigurationException : MONException {
    this(string msg) {
        super(msg);
    }
}