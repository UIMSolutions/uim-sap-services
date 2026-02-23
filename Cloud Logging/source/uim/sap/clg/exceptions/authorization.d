module uim.sap.clg.exceptions.authorization;

import uim.sap.clg;

mixin(ShowModule!());

@safe:

class CLGAuthorizationException : CLGException {
    this(string msg = "Unauthorized", string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
        super(msg, file, line, next);
    }
}
