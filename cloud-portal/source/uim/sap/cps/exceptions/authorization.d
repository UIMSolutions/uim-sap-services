module uim.sap.cps.exceptions.authorization;

import uim.sap.cps;

mixin(ShowModule!());

@safe:

class CPSAuthorizationException : CPSException {
    this(string msg) { super(msg); }
}