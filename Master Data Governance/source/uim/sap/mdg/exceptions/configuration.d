module uim.sap.mdg.exceptions.configuration;

import uim.sap.mdg;
@safe:

class MDGConfigurationException : MDGException {
    this(string msg) {
        super(msg);
    }
}