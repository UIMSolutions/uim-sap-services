module uim.sap.bas.exceptions.configuration;

import uim.sap.bas;

module(ShowModule!());

@safe:
class BASConfigurationException : BASException {
    this(string message) {
        super(message);
    }
}