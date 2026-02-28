module uim.sap.cis.exceptions.configuration;

import uim.sap.cis;

mixin(ShowModule!());

@safe:

class CISConfigurationException : CISException {
    this(string msg) {
        super(msg);
    }
}