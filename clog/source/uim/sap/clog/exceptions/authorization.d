module uim.sap.scl.exceptions.authorization;

import uim.sap.scl;

mixin(ShowModule!());

@safe:

class SCLAuthorizationException : SCLException {
    this(string msg = "Unauthorized", string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
        super(msg, file, line, next);
    }
}
