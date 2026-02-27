module uim.sap.isa.exceptions.validation;

import uim.sap.isa.exceptions.exception;

class ISAValidationException : ISAException {
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
        super(msg, file, line, next);
    }
}
