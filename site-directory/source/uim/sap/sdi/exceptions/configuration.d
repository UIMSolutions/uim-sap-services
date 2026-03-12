module uim.sap.sdi.exceptions.configuration;

import uim.sap.sdi;

mixin(ShowModule!());

@safe:

class SDIConfigurationException : SDIException {
    this(string msg) { super(msg); }
}
