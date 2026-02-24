module uim.sap.aas.exceptions.exception;

import uim.sap.aas;
@safe:

class AASException : Exception {
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
        super(msg, file, line, next);
    }
}
