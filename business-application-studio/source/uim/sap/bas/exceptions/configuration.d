module uim.sap.bas.exceptions.configuration;

import uim.sap.bas;

mixin(ShowModule!());

@safe:


class BASConfigurationException : BASException {
    this(string message) {
        super(message);
    }
}