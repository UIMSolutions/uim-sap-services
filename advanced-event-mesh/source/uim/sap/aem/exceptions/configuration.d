module uim.sap.aem.exceptions.configuration;

import uim.sap.aem;

mixin(ShowModule!());

@safe:


class AEMConfigurationException : AEMException {
    this(string message) {
        super("Configuration error: " ~ message);
    }
}
