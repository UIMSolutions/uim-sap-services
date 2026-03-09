module uim.sap.cpi.exceptions.exception;

import uim.sap.cpi;

mixin(ShowModule!());

@safe:

class CPIException : SAPException {
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null)
    pure nothrow @safe @nogc {
        super(msg, file, line, next);
    }
}