module uim.sap.cmg.exceptions.authorization;

import uim.sap.cmg;

mixin(ShowModule!());

@safe:

class CMGAuthorizationException : CMGException {
    this(string msg) { super(msg); }
}