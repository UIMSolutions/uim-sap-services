module uim.sap.buh.exceptions.exception;

import uim.sap.buh;

mixin(ShowModule!());

@safe:
class BUHException : SAPException {
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
        super(msg, file, line, next);
    }
}