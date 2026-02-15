module uim.sap.scl.exceptions.exception;

import uim.sap.scl;

mixin(ShowModule!());

@safe:

class SCLException : Exception {
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
        super(msg, file, line, next);
    }
}