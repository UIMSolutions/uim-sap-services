module uim.sap.mdi.exceptions.authorization;

import uim.sap.mdi;

mixin(ShowModule!());

@safe:
class MDIAuthorizationException : MDIException {
    this(string msg) { super(msg); }
}