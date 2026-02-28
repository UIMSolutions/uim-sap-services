module uim.sap.cmg.exceptions.configuration;

import uim.sap.cmg;

mixin(ShowModule!());

@safe:

class CMGConfigurationException : CMGException {
    this(string msg) { super(msg); }
}
