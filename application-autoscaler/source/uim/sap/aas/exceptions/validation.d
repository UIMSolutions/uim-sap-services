module uim.sap.aas.exceptions.validation;

import uim.sap.aas;
@safe:

class AASValidationException : AASException {
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
        super(msg, file, line, next);
    }
}
