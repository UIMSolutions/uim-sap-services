module uim.sap.sdi.exceptions.authorization;

import uim.sap.sdi;

mixin(ShowModule!());

@safe:

class SDIAuthorizationException : SDIException {
    this(string msg) { super(msg); }
}
