module uim.sap.cps.exceptions.configuration;

import uim.sap.cps;

mixin(ShowModule!());

@safe:

class CPSConfigurationException : CPSException {
    this(string msg) { super(msg); }
}