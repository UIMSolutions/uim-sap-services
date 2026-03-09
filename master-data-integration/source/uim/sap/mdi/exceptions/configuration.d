module uim.sap.mdi.exceptions.configuration;

import uim.sap.mdi;

mixin(ShowModule!());

@safe:
class MDIConfigurationException : MDIException {
    this(string msg) { super(msg); }
}