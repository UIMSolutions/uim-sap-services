module uim.sap.isa.exceptions.authorization;

import uim.sap.isa.exceptions.exception;

class ISAAuthorizationException : ISAException {
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
        super(msg, file, line, next);
    }
}
