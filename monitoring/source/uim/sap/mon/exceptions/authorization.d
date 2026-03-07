module uim.sap.mon.exceptions.authorization;

import uim.sap.mon;

mixin(ShowModule!());

@safe:

class MONAuthorizationException : MONException {
    this(string msg) {
        super(msg);
    }
}