module uim.sap.ctm.exceptions.authorization;

import uim.sap.ctm;

mixin(ShowModule!());

@safe:

class CTMAuthorizationException : CTMException {
    this(string msg) { super(msg); }
}
