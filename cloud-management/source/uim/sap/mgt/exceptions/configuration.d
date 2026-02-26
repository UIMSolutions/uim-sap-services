module uim.sap.mgt.exceptions.configuration;

import uim.sap.mgt;

mixin(ShowModule!());

@safe:
class MGTConfigurationException : MGTException {
    this(string msg) {
        super(msg);
    }
}