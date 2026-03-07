module uim.sap.atm.exceptions.configuration;

import uim.sap.atm;

mixin(ShowModule!());

@safe:

class ATMConfigurationException : ATMException {
    this(string message) {
        super("Configuration error: " ~ message);
    }
}
